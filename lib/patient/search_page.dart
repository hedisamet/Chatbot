import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _searchResults;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _searchResults = _searchDoctors('');
    _firebaseMessaging.requestPermission();
  }

  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _searchDoctors(String query) {
    CollectionReference<Map<String, dynamic>> doctorsCollection =
        FirebaseFirestore.instance.collection('doctors');

    // Convert the search query to lowercase for case-insensitive matching
    String searchTerm = query.trim().toLowerCase();
    print('Search term: $searchTerm');

    // Return the stream of all documents in the 'doctors' collection
    // Filter the documents locally based on the search query
    return doctorsCollection.snapshots().map((snapshot) => snapshot.docs.where((doc) {
      String name = doc['name']?.toLowerCase() ?? '';
      return name.contains(searchTerm);
    }).toList());
  }

  Future<String?> fetchAvatarUrl(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userInfoDoc =
          await FirebaseFirestore.instance.collection('doctor').doc(userId).get();
      if (userInfoDoc.exists) {
        return userInfoDoc['avatarUrl'] as String?;
      }
    } catch (e) {
      print('Error fetching avatar URL: $e');
    }
    return null;
  }

  Future<void> _requestDoctor(String doctorId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentReference userInfoRef = FirebaseFirestore.instance.collection('user_info').doc(currentUser.uid);
        DocumentReference doctorRef = FirebaseFirestore.instance.collection('doctors').doc(doctorId);

        // Update the patient's 'doctor' field
        await userInfoRef.update({'doctor': doctorId});

        // Create a notification in the doctor's 'notifications' collection
        await doctorRef.collection('notifications').doc(currentUser.uid).set({
          'patientId': currentUser.uid,
          'avatarUrl': await fetchAvatarUrl(currentUser.uid),
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Send a notification to the doctor
        String? fcmToken = await _fetchDoctorFCMToken(doctorId);
        if (fcmToken != null) {
          await _firebaseMessaging.sendMessage(
            to: fcmToken,
            data: {
              'title': 'New Doctor Request',
              'body': 'You have a new doctor request from a patient.',
            },
          );
        }

        // Show a success message or navigate to a different screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doctor request sent successfully.'),
          ),
        );
      }
    } catch (e) {
      print('Error requesting doctor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending doctor request.'),
        ),
      );
    }
  }

  Future<String?> _fetchDoctorFCMToken(String doctorId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doctorDoc =
          await FirebaseFirestore.instance.collection('doctors').doc(doctorId).get();
      if (doctorDoc.exists) {
        return doctorDoc['fcmToken'] as String?;
      }
    } catch (e) {
      print('Error fetching FCM token: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Chercher un docteur...',
            hintStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          onChanged: (query) {
            setState(() {
              _searchResults = _searchDoctors(query);
            });
          },
        ),
        backgroundColor: Colors.teal[300],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
        stream: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No results found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var doctor = snapshot.data![index];
              var name = doctor['name']?.toString() ?? 'No Name';
              var doctorId = doctor.id;

              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: FutureBuilder<String?>(
                    future: fetchAvatarUrl(doctorId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.teal[300],
                        );
                      }
                      if (snapshot.hasData && snapshot.data != null) {
                        return CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(snapshot.data!),
                        );
                      } else {
                        return CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage('assets/images/anonymous.png'),
                        );
                      }
                    },
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Location: ${doctor['state'] ?? 'Not specified'}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.person_add,
                      color: Colors.teal[300],
                    ),
                    onPressed: () {
                      _requestDoctor(doctorId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
