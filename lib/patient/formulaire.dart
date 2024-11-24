import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:wellbeingGuide/patient/home_page.dart';

void main() {
  runApp(const MyForm());
}

class MyForm extends StatelessWidget {
  const MyForm({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const HADSurveyScreen(),
    );
  }
}

class HADSurveyScreen extends StatefulWidget {
  const HADSurveyScreen({super.key});

  @override
  _HADSurveyScreenState createState() => _HADSurveyScreenState();
}

class _HADSurveyScreenState extends State<HADSurveyScreen> {
  final Map<String, String?> _formData = {};
  int _anxietyScore = 0;
  int _depressionScore = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerRight, // Align the title to the right
          child: const Text(
            'استبيان HAD',
            style: TextStyle(
              color: Colors.white, // Change text color to cyan
            ),
          ),
        ),
        backgroundColor: Colors.teal[300],
        iconTheme: const IconThemeData(
          color: Colors.white, // Change back arrow color to cyan
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // Align to the right
              children: [
                Text(
                  'الرجاء الإجابة على الأسئلة التالية استنادًا إلى كيف كنت تشعر في الأسبوع الماضي.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.right, // Align text to the right
                ),
                const SizedBox(height: 20),
                ..._buildQuestions(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _calculateScores,
                  child: const Text('التالي'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildQuestions() {
    return [
      _buildSegmentedButton(
        'هل شعرت بتوتر أو إجهاد خلال الأسبوع الماضي؟',
        'anxiety',
        examples: ['ضغوط العمل', 'القلق بشأن الأحداث القادمة'],
      ),
      _buildSegmentedButton(
        'هل شعرت ببطء في التصرفات أو الحركات؟',
        'depression',
        examples: ['الشعور بالإرهاق', 'التفكير البطيء'],
      ),
      _buildSegmentedButton(
        'هل شعرت بقلق أو هموم خلال الأسبوع الماضي؟',
        'worry_anxiety',
        examples: ['القلق بشأن الصحة', 'القلق بشأن المستقبل'],
      ),
      _buildSegmentedButton(
        'هل شعرت بقلق زائد أو هلع خلال الأسبوع الماضي؟',
        'panic_anxiety',
        examples: ['الهلع الشديد', 'الشعور بفقدان السيطرة'],
      ),
      _buildSegmentedButton(
        'هل شعرت برغبة في البكاء خلال الأسبوع الماضي؟',
        'cry',
        examples: ['الشعور بالضعف العاطفي', 'الرغبة في التخلص من الضغوط'],
      ),
      _buildSegmentedButton(
        'هل شعرت بتوتر عصبي خلال الأسبوع الماضي؟',
        'nervous_tension',
        examples: ['التوتر الشديد', 'الشعور بالتجاعيد العصبية'],
      ),
      _buildSegmentedButton(
        'هل شعرت بالهم والتوتر خلال الأسبوع الماضي؟',
        'panic',
        examples: ['الشعور بالتوتر العصبي', 'الهم والقلق'],
      ),
      _buildSegmentedButton(
        'هل شعرت بالكآبة خلال الأسبوع الماضي؟',
        'mood_depressed',
        examples: ['الشعور بالحزن', 'التشاؤم بشكل عام'],
      ),
      _buildSegmentedButton(
        'هل شعرت بالإرهاق البدني خلال الأسبوع الماضي؟',
        'physical_fatigue',
        examples: ['الإرهاق العضلي', 'الشعور بالتعب الشديد'],
      ),
      _buildSegmentedButton(
        'هل شعرت بالإرهاق النفسي خلال الأسبوع الماضي؟',
        'mental_fatigue',
        examples: ['التعب العقلي', 'صعوبة التركيز'],
      ),
      _buildSegmentedButton(
        'هل شعرت بصعوبة في الاستمتاع بالأشياء خلال الأسبوع الماضي؟',
        'enjoyment_difficulty',
        examples: [
          'فقدان الاهتمام بالهوايات',
          'عدم القدرة على الاستمتاع بالأنشطة'
        ],
      ),
      _buildSegmentedButton(
        'هل شعرت بالتوجس خلال الأسبوع الماضي؟',
        'apprehension',
        examples: ['الشعور بالتوتر المستمر', 'القلق بشكل مفرط'],
      ),
      _buildSegmentedButton(
        'هل شعرت بالهلع خلال الأسبوع الماضي؟',
        'panic_attack',
        examples: ['الهلع الشديد', 'الشعور بالخوف الشديد'],
      ),
    ];
  }

  Widget _buildSegmentedButton(String question, String fieldName,
      {List<String> examples = const []}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Align to the right
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.right, // Align text to the right
        ),
        if (examples.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'أمثلة: ${examples.join(", ")}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.right, // Align text to the right
            ),
          ),
        SegmentedButton(
          segments: const [
            ButtonSegment(
                value: 'لا أبداً',
                label: Text('لا أبداً', textAlign: TextAlign.right)),
            ButtonSegment(
                value: 'أحياناً',
                label: Text('أحياناً', textAlign: TextAlign.right)),
            ButtonSegment(
                value: 'غالباً',
                label: Text('غالباً', textAlign: TextAlign.right)),
            ButtonSegment(
                value: 'معظم الوقت',
                label: Text('معظم الوقت', textAlign: TextAlign.right)),
          ],
          selected: <String>{_formData[fieldName] ?? ''},
          onSelectionChanged: (Set<String> selection) {
            setState(() {
              _formData[fieldName] =
                  selection.isNotEmpty ? selection.first : null;
            });
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _calculateScores() async {
    int anxiety = 0;
    int depression = 0;

    _formData.forEach((key, value) {
      if (key == 'anxiety' ||
          key == 'worry_anxiety' ||
          key == 'panic_anxiety' ||
          key == 'nervous_tension' ||
          key == 'panic' ||
          key == 'apprehension' ||
          key == 'panic_attack') {
        anxiety += _getScore(value);
      } else if (key == 'depression' ||
          key == 'cry' ||
          key == 'mood_depressed' ||
          key == 'physical_fatigue' ||
          key == 'mental_fatigue' ||
          key == 'enjoyment_difficulty') {
        depression += _getScore(value);
      }
    });

    _anxietyScore = anxiety;
    _depressionScore = depression;

    if (_anxietyScore >= 11 || _depressionScore >= 11) {
      await _showSuicidalThoughtsDialog();
    }

    await _saveFormDataToFirestore();
    await _saveFormDataToJson(); // Save to JSON file

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  int _getScore(String? value) {
    switch (value) {
      case 'لا أبداً':
        return 0;
      case 'أحياناً':
        return 1;
      case 'غالباً':
        return 2;
      case 'معظم الوقت':
        return 3;
      default:
        return 0;
    }
  }

  String _getInterpretation(int score) {
    if (score <= 7) {
      return 'مستوى منخفض من الاضطراب';
    } else if (score >= 8 && score <= 10) {
      return 'مستوى متوسط من الاضطراب';
    } else {
      return 'مستوى عالٍ من الاضطراب';
    }
  }

  Future<void> _saveFormDataToFirestore() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('hadsurveys')
            .doc(currentUser.uid)
            .set({
          'userId': currentUser.uid,
          'anxietyScore': _anxietyScore,
          'depressionScore': _depressionScore,
          'timestamp': DateTime.now(),
          'formData': _formData,
        }, SetOptions(merge: true));

        print('Form data saved to Firestore for user: ${currentUser.uid}');
      } else {
        print('Error: Current user is null');
      }
    } catch (e) {
      print('Error saving form data to Firestore: $e');
    }
  }

  Future<void> _saveFormDataToJson() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Create a Map from the form data
        Map<String, dynamic> formData = {
          'userId': currentUser.uid,
          'anxietyInterpretation': _getInterpretation(_anxietyScore),
          'depressionInterpretation': _getInterpretation(_depressionScore),
          'timestamp': DateTime.now().toIso8601String(),
        };

        // Add form responses
        formData.addAll(_formData);

        // Convert the Map to JSON
        String jsonString = jsonEncode(formData);

        // Get the directory to save the file
        Directory directory = await getApplicationDocumentsDirectory();
        String path = '${directory.path}/user_form_${currentUser.uid}.json';

        // Save the JSON string to the file
        File file = File(path);
        await file.writeAsString(jsonString);

        print('Form data saved to JSON file for user: ${currentUser.uid}');
      } else {
        print('Error: Current user is null');
      }
    } catch (e) {
      print('Error saving form data to JSON file: $e');
    }
  }

  Future<void> _showSuicidalThoughtsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تحذير'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('نحن نلاحظ أنك قد تعاني من مستويات عالية من القلق أو الاكتئاب.'),
                Text('هل تعاني من أفكار انتحارية؟'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('لا'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('نعم'),
              onPressed: () {
                Navigator.of(context).pop();
                // Handle 'Yes' response if needed
              },
            ),
          ],
        );
      },
    );
  }
}
