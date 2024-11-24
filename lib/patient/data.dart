import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientDataScreen extends StatefulWidget {
  @override
  _PatientDataScreenState createState() => _PatientDataScreenState();
}

class _PatientDataScreenState extends State<PatientDataScreen> {
  late String userName = '';

  @override
  void initState() {
    super.initState();
    // Call the method to fetch user data when the widget is initialized
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Get the current authenticated user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Reference to the users collection in Firestore
        CollectionReference patientsData = FirebaseFirestore.instance.collection('patientsData');

        // Get the document reference for the specific user using the user ID
        DocumentReference userDocumentRef = patientsData.doc(currentUser.uid);

        // Get the document snapshot
        DocumentSnapshot userDocument = await userDocumentRef.get();

        // Check if the document exists
        if (userDocument.exists) {
          // Get the 'name' field from the document
          userName = userDocument['name'];
        } else {
          // Handle the case where the document does not exist
          print('User data not found for ID: ${currentUser.uid}');
        }
      } else {
        // Handle the case where no user is currently authenticated
        print('No user is currently authenticated');
      }

      // Set the state to trigger a rebuild of the widget with the retrieved data
      setState(() {});
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Data'),
      ),
      body: Center(
        child: Text('User Name: $userName'),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: PatientDataScreen(),
    ),
  );
}