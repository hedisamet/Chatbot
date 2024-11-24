import 'package:wellbeingGuide/doctor/doctor_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class DoctorFormPage extends StatefulWidget {
  const DoctorFormPage({Key? key}) : super(key: key);

  @override
  _DoctorFormPageState createState() => _DoctorFormPageState();
}

enum Gender { male, female }

class _DoctorFormPageState extends State<DoctorFormPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  Gender? selectedGender;
  DateTime? selectedDate;
  String? selectedState;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Information',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal[300],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              SizedBox(height: 16.0),
              TextFormField(
                controller: nameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Name',
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
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<Gender>(
                value: selectedGender,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Gender',
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
                      value == Gender.male ? 'Male' : 'Female',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (Gender? value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a gender';
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
                  labelText: 'Experience',
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
                    return 'Please select your debut date';
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
              TextFormField(
                controller: addressController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Adresse',
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
                    return 'Veuillez saisir votre adresse';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: phoneNumberController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
                ],
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez saisir votre Numéro';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
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
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        selectedDate = picked;
        if (selectedDate != null) {
          final DateTime now = DateTime.now();
          final int experience = now.year - selectedDate!.year;
          ageController.text = experience.toString();
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (formKey.currentState!.validate()) {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          String? fcmToken = await FirebaseMessaging.instance.getToken();

          CollectionReference doctorsData =
              FirebaseFirestore.instance.collection('doctors');

          await doctorsData.doc(currentUser.uid).set({
            'name': nameController.text,
            'experience': int.tryParse(ageController.text) ?? 0,
            'gender': selectedGender.toString().split('.').last,
            'phone_number': phoneNumberController.text,
            'state': selectedState,
            'address': addressController.text,
            'email': currentUser.email, // Include email attribute
            'fcm_token': fcmToken,
          });

          nameController.clear();
          ageController.clear();
          phoneNumberController.clear();
          addressController.clear(); // Clear address field
          setState(() {
            selectedGender = null;
            selectedState = null; // Clear selected state
          });

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
        }
      } catch (e) {
        print('Error submitting form: $e');
      }
    }
  }
}
