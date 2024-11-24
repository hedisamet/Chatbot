import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientProfileScreen extends StatefulWidget {
  final String patientId;

  const PatientProfileScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _PatientProfileScreenState createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  Map<String, dynamic> patientInfo = {};
  Map<String, dynamic> formData = {};

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  Future<void> fetchPatientData() async {
    final patientInfoDoc = await FirebaseFirestore.instance
        .collection('user_info')
        .doc(widget.patientId)
        .get();

    final formDataDoc = await FirebaseFirestore.instance
        .collection('user_form')
        .doc(widget.patientId)
        .get();

    if (patientInfoDoc.exists && formDataDoc.exists) {
      setState(() {
        patientInfo = patientInfoDoc.data()!;
        formData = formDataDoc.data()!;
      });
    }
  }

  String getGenderString(String? gender) {
    if (gender == null) return 'N/A';
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return 'Other';
    }
  }

  String getHasChromaticDiseaseString(bool? hasChromaticDisease) {
    if (hasChromaticDisease == null) return 'N/A';
    return hasChromaticDisease ? 'Yes' : 'No';
  }

  String getIsTakingMedicineString(bool? isTakingMedicine) {
    if (isTakingMedicine == null) return 'N/A';
    return isTakingMedicine ? 'Yes' : 'No';
  }

  String getSuicidalThoughtsString(String? suicidalThoughts) {
    if (suicidalThoughts == null) return 'N/A';
    switch (suicidalThoughts) {
      case 'نعم':
        return 'Patient has expressed suicidal thoughts';
      case 'لا':
        return 'Patient has not expressed suicidal thoughts';
      default:
        return 'N/A';
    }
  }

  void navigateToFormHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormHistoryScreen(patientId: widget.patientId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[300],
        title: const Text('Patient Profile'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                ListTile(
                  title: Text(
                    '${patientInfo['name'] ?? 'N/A'} ${patientInfo['family_name'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[300],
                    ),
                  ),
                  subtitle: Text(
                    'Patient ID: ${widget.patientId}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/anonymous.png'),
                  ),
                ),
                SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[300],
                          ),
                        ),
                        Divider(height: 20, thickness: 1),
                        ListTile(
                          title: Text('Age: ${patientInfo['age'] ?? 'N/A'}'),
                          subtitle: Text('Gender: ${getGenderString(patientInfo['gender'])}'),
                        ),
                        ListTile(
                          title: Text('Has Chromatic Disease: ${getHasChromaticDiseaseString(patientInfo['has_chromatic_disease'])}'),
                          subtitle: Text('Taking Medicine: ${getIsTakingMedicineString(patientInfo['is_taking_medicine'])}'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HAD Form Interpretation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[300],
                          ),
                        ),
                        Divider(height: 20, thickness: 1),
                        ListTile(
                          title: Text('Anxiety Interpretation: ${formData['anxietyInterpretation'] ?? 'N/A'}'),
                          subtitle: Text('Depression Interpretation: ${formData['depressionInterpretation'] ?? 'N/A'}'),
                        ),
                        ListTile(
                          title: Text(getSuicidalThoughtsString(formData['suicidalThoughts'])),
                          subtitle: Text('Last Form Submission: ${formData['timestamp']?.toDate().toString().split(' ').first ?? 'N/A'}'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: navigateToFormHistory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[300],
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'View Form History',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormHistoryScreen extends StatelessWidget {
  final String patientId;

  const FormHistoryScreen({Key? key, required this.patientId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement logic to fetch and display form history for the patient
    return Scaffold(
      appBar: AppBar(
        title: Text('Form History'),
      ),
      body: Center(
        child: Text('Form history for patient $patientId'),
      ),
    );
  }
}
