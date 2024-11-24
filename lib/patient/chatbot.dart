import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeingGuide/patient/home_page.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure microphone permission is granted
  await Permission.microphone.request();

  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(Chatbot());
}

class Chatbot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Bot',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  String _selectedLanguage = 'en_US'; // Default language
  Timestamp? _interactionStart;

  @override
  void initState() {
    super.initState();
    // Initialize speech to text
    _initSpeechState();
    // Start interaction timer
    _startInteraction();
  }

  @override
  void dispose() {
    // End interaction timer
    _endInteraction();
    super.dispose();
  }

  void _initSpeechState() async {
    // Ensure microphone permission is granted
    await Permission.microphone.request();

    // Initialize speech recognition
    bool available = await _speech.initialize(
      onError: (error) {
        print('Error: $error');
        setState(() {
          _isListening = false;
        });
      },
      onStatus: (status) {
        print('Status: $status');
        setState(() {
          _isListening = status == stt.SpeechToText.listeningStatus;
        });
      },
    );

    if (!available) {
      print('Speech recognition not available');
    }
  }

  void startListening() {
    if (!_isListening) {
      _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords ?? '';
          });
        },
        localeId: _selectedLanguage, // Set the language for speech recognition
      );
      setState(() => _isListening = true);
    }
  }

  void stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _startInteraction() async {
    // Fetch current user ID
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      // Start interaction timer
      setState(() {
        _interactionStart = Timestamp.now();
      });

      // Update Firestore with current interaction start time
      await _firestore.collection('user_info').doc(userId).update({
        'current_interaction_start': Timestamp.now(),
      });
    }
  }

  void _endInteraction() async {
    if (_interactionStart == null) return;

    // Fetch current user ID
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      // Calculate the duration of the current interaction
      int currentDuration = Timestamp.now().seconds - _interactionStart!.seconds;

      DocumentSnapshot userSnapshot = await _firestore.collection('user_info').doc(userId).get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userInfo = userSnapshot.data() as Map<String, dynamic>;
        int totalInteractionDuration = userInfo['total_interaction_duration'] ?? 0;

        // Update the total interaction duration
        totalInteractionDuration += currentDuration;

        // Update Firestore with new total interaction duration and reset current interaction start time
        await _firestore.collection('user_info').doc(userId).update({
          'total_interaction_duration': totalInteractionDuration,
          'current_interaction_start': null,
        });
      }
    }
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;

    try {
      // Fetch current user ID
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userSnapshot = await _firestore.collection('user_info').doc(userId).get();
        
        if (!userSnapshot.exists) {
          // Initialize the user document with last_interaction if it doesn't exist
          await _firestore.collection('user_info').doc(userId).set({
            'last_interaction': Timestamp.now(),
            'total_interaction_duration': 0,
            'current_interaction_start': Timestamp.now(),
          });

          // Proceed with sending the message
          setState(() {
            _messages.insert(0, {'content': text, 'isUserMessage': true, 'shouldAnimate': true});
            _messageController.clear();
          });

          // Send user information along with the message to Flask server
          await sendToFlask(text, {'last_interaction': Timestamp.now()});
          return;
        }

        Map<String, dynamic> userInfo = userSnapshot.data() as Map<String, dynamic>;
        Timestamp lastInteraction = userInfo['last_interaction'] ?? Timestamp(0, 0);
        int totalInteractionDuration = userInfo['total_interaction_duration'] ?? 0;

        // Check if the total interaction duration has exceeded 15 minutes (900 seconds)
        if (totalInteractionDuration >= 900) {
          showMessage("You have reached the 15 minute interaction limit for today.");
          return;
        }

        // Proceed with sending the message
        setState(() {
          _messages.insert(0, {'content': text, 'isUserMessage': true, 'shouldAnimate': true});
          _messageController.clear();
        });

        // Send user information along with the message to Flask server
        await sendToFlask(text, userInfo);
      }
    } catch (e) {
      print('Error in sendMessage: $e');
    }
  }

  void showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Notice"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendToFlask(String text, Map<String, dynamic> userInfo) async {
    try {
      // Convert Timestamp objects to milliseconds
      userInfo = userInfo.map((key, value) {
        if (value is Timestamp) {
          return MapEntry(key, value.toDate().millisecondsSinceEpoch);
        }
        return MapEntry(key, value);
      });

      // Combine user input and user information
      Map<String, dynamic> requestData = {
        'user_input': text,
        'user_info': userInfo,
      };

      var response = await http.post(
        Uri.parse('http://10.0.2.2:5000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      var jsonResponse = jsonDecode(response.body);

      setState(() {
        _messages.insert(0, {'content': jsonResponse['ai_response'], 'isUserMessage': false, 'shouldAnimate': true});
      });
    } catch (e) {
      print('Error in sendToFlask: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _endInteraction();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            icon: Icon(Icons.language, color: Colors.white),
            dropdownColor: Colors.teal,
            onChanged: (String? newValue) {
              setState(() {
                _selectedLanguage = newValue!;
              });
            },
            items: <String>['en_US', 'ar_SA', 'fr_FR']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value == 'en_US'
                      ? 'English'
                      : value == 'ar_SA'
                          ? 'Arabic'
                          : 'French',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index]['content'];
                final isUserMessage = _messages[index]['isUserMessage'];
                final shouldAnimate = _messages[index]['shouldAnimate'];

                return AnimatedAlign(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  duration: Duration(milliseconds: shouldAnimate ? 500 : 0),
                  curve: shouldAnimate ? Curves.easeInOut : Curves.linear,
                  onEnd: () {
                    setState(() {
                      _messages[index]['shouldAnimate'] = false;
                    });
                  },
                  child: AnimatedContainer(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.teal : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    duration: Duration(milliseconds: shouldAnimate ? 500 : 0),
                    curve: shouldAnimate ? Curves.easeInOut : Curves.linear,
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isUserMessage ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () => sendMessage(_messageController.text),
                  child: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    _isListening ? stopListening() : startListening();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
