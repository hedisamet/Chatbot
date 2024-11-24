import 'package:wellbeingGuide/patient/formulaire.dart';
import 'package:wellbeingGuide/patient/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  _FilePageState createState() => _FilePageState();
}

enum Gender { male, female }

class _FilePageState extends State<FilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController diseasesController = TextEditingController();
  final TextEditingController medicinesController = TextEditingController();

  Gender? selectedGender;
  bool hasChromaticDisease = false;
  bool isTakingMedicine = false;
  DateTime? selectedDate; // Added a DateTime variable to store selected date
  String? selectedState; // Added a variable to store selected state
  List<String> tunisiaStates = [
    'Ariana',
    'Béja',
    'Ben Arous',
    'Bizerte',
    'Gabès',
    'Gafsa',
    'Jendouba',
    'Kairouan',
    'Kasserine',
    'Kébili',
    'Le Kef',
    'Mahdia',
    'La Manouba',
    'Médenine',
    'Monastir',
    'Nabeul',
    'Sfax',
    'Sidi Bouzid',
    'Siliana',
    'Sousse',
    'Tataouine',
    'Tozeur',
    'Tunis',
    'Zaghouan',
  ];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<bool> checkIfUserFilledForm(String userId) async {
    try {
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('user_form');

      DocumentSnapshot userDoc = await userCollection.doc(userId).get();

      return userDoc.exists; // Return true if the document exists (form filled)
    } catch (e) {
      print('Error checking user form: $e');
      return false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked; // Set the selected date
        if (selectedDate != null) {
          final DateTime now = DateTime.now();
          final int age = now.year - selectedDate!.year;
          ageController.text = age.toString(); // Display the calculated age
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Informations utilisateur',
          style: TextStyle(
            color: Colors.white, // Change text color to cyan
          ),
        ),
        backgroundColor: Colors.teal[300],
        iconTheme: IconThemeData(
            color: Colors.white), // Change back arrow color to cyan
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              SizedBox(
                height: 16.0,
              ),
              TextFormField(
                controller: nameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: familyNameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Nom de famille',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer votre nom de famille';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                readOnly: true,
                onTap: () {
                  _selectDate(context);
                },
                controller: ageController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Age',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.cyan),
                ),
                validator: (value) {
                  if (selectedDate == null) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: selectedState,
                style: TextStyle(
                    color: Colors.black), // Text color for the input field
                decoration: InputDecoration(
                  labelText: 'Gouvernorat',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  suffixIcon: Icon(Icons.location_on, color: Colors.cyan),
                ),
                items:
                    tunisiaStates.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.black, // Text color for dropdown items
                      ),
                    ),
                  );
                }).toList(),
                dropdownColor:
                    Colors.white, // Background color for dropdown menu
                onChanged: (String? value) {
                  setState(() {
                    selectedState = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner votre gouvernorat';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<Gender>(
                value: selectedGender,
                style: TextStyle(
                    color: Colors.black), // Text color for the input field
                decoration: InputDecoration(
                  labelText: 'Genre',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                items:
                    Gender.values.map<DropdownMenuItem<Gender>>((Gender value) {
                  return DropdownMenuItem<Gender>(
                    value: value,
                    child: Text(
                      value == Gender.male ? 'Masculin' : 'Féminin',
                      style: TextStyle(
                        color: Colors.black, // Text color for dropdown items
                      ),
                    ),
                  );
                }).toList(),
                dropdownColor:
                    Colors.white, // Background color for dropdown menu
                onChanged: (Gender? value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a genre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              CheckboxListTile(
                title: const Text(
                  'Avez-vous des maladies chroniques ?',
                  style: TextStyle(color: Colors.black),
                ),
                value: hasChromaticDisease,
                onChanged: (bool? value) {
                  setState(() {
                    hasChromaticDisease = value!;
                  });
                },
                activeColor: Colors.cyan, // Change checkbox color to cyan
              ),
              if (hasChromaticDisease)
                TextFormField(
                  controller: diseasesController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Maladies chroniques',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              SizedBox(height: 16.0),
              CheckboxListTile(
                title: const Text(
                  'Prenez-vous des médicaments ?',
                  style: TextStyle(color: Colors.black),
                ),
                value: isTakingMedicine,
                onChanged: (bool? value) {
                  setState(() {
                    isTakingMedicine = value!;
                  });
                },
                activeColor: Colors.cyan, // Change checkbox color to cyan
              ),
              if (isTakingMedicine)
                TextFormField(
                  controller: medicinesController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Médicaments',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity, // Set the desired width
                height: 40, // Set the desired height
                child: ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Soumettre',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (formKey.currentState!.validate()) {
      try {
        // Get the current authenticated user
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          // Get FCM token
          String? fcmToken = await FirebaseMessaging.instance.getToken();

          // Reference to the users collection in Firestore
          CollectionReference patientsData =
              FirebaseFirestore.instance.collection('user_info');

          // Add the form data to the user's document in the 'patientsData' collection
          await patientsData.doc(currentUser.uid).set({
            'name': nameController.text,
            'family_name': familyNameController.text,
            'age': int.tryParse(ageController.text) ?? 0,
            'gender': selectedGender.toString().split('.').last,
            'has_chromatic_disease': hasChromaticDisease,
            'chromatic_diseases':
                hasChromaticDisease ? diseasesController.text : null,
            'is_taking_medicine': isTakingMedicine,
            'medicines': isTakingMedicine ? medicinesController.text : null,
            'fcm_token': fcmToken, // Store FCM token
          });

          // Clear the text fields after submission
          nameController.clear();
          familyNameController.clear();
          ageController.clear();
          diseasesController.clear();
          medicinesController.clear();

          setState(() {
            selectedGender = null;
            hasChromaticDisease = false;
            isTakingMedicine = false;
          });
          if (await checkIfUserFilledForm(currentUser.uid)) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyForm(),
              ),
            );
          }
        }
      } catch (e) {
        print('Error submitting form: $e');
      }
    }
  }
}
