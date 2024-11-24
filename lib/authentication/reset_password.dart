// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> _sendPasswordResetEmail() async {
    if (formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text,
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Email Sent'),
              content: const Text('Password reset email has been sent.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Close the current screen
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Error sending password reset email: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Error sending password reset email: $e'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mot de passe oubliée',
          style: TextStyle(
            color: Colors.cyan, // Change text color to cyan
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.cyan), // Change back arrow color to cyan
      ),
      body: Container(
        decoration: BoxDecoration(
        color: Colors.teal[300], // Set your desired color here
        ),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Veuillez entrer un e-mail valide';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white, // Background color of the input field
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    hintText: 'Entrez votre e-mail',
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
            onPressed: _sendPasswordResetEmail,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Envoyer',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
