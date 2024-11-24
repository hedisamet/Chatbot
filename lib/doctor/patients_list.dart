import 'package:wellbeingGuide/doctor/doctor_home.dart';
import 'package:wellbeingGuide/doctor/patient_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientsList extends StatefulWidget {
  const PatientsList({Key? key}) : super(key: key);

  @override
  _PatientsListState createState() => _PatientsListState();
}

class _PatientsListState extends State<PatientsList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _patientList = [];

  @override
  void initState() {
    super.initState();
    _fetchPatientList();
  }

  Future<void> _fetchPatientList() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      DocumentSnapshot<Map<String, dynamic>> doctorDoc =
          await _firestore.collection('doctors').doc(currentUserId).get();
      if (doctorDoc.exists) {
        List<dynamic> patientList = doctorDoc.data()!['patient_list'];
        setState(() {
          _patientList = patientList.cast<String>();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patients'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _patientList.length,
        itemBuilder: (context, index) {
          String patientId = _patientList[index];
          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: _firestore.collection('user_info').doc(patientId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text('Loading...'),
                );
              }

              if (snapshot.hasError) {
                return ListTile(
                  leading: Icon(Icons.error),
                  title: Text('Error: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text('User not found'),
                );
              }

              var userData = snapshot.data!.data()!;
              var name = userData['name'] ?? 'Unknown';
              var avatarUrl =
                  userData['avatarUrl'] ?? 'assets/images/anonymous.png';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(avatarUrl),
                ),
                title: Text(name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PatientProfileScreen(patientId: patientId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
