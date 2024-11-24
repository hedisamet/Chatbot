import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wellbeingGuide/patient/loading_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  try {
    // Retrieve Firebase App Check token
    var appCheckToken = await FirebaseAppCheck.instance.getToken(false);
    print(appCheckToken);
    if (appCheckToken == null) {
      // If token is null, set a placeholder token
      appCheckToken = "D8149899-A341-47B1-ACA4-74378BE88B71";
    }
  } catch (error) {
    // Handle errors when fetching App Check token
    log("Error fetching app check token: $error");
    // You might want to handle different types of errors separately
    // For now, we're just logging the error
  }

  print('***FIREBASE LOADED SUCCESSFULLY***');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Check if first time opening the app
  Future<bool> isFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = (prefs.getBool('isFirstLaunch') ?? true);
    return isFirstLaunch;
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wellbeing Guide',
      home: LoadingScreen(),
    );
  }
}
