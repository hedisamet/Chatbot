import 'package:wellbeingGuide/authentication/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  bool isPasswordNotEmpty = false;
  bool isConfirmPasswordNotEmpty = false;
  bool _obscureTextConfirm = true;

  Future<void> _registerAndSendVerificationEmail() async {
    try {
      if (formKey.currentState!.validate()) {
        if (passwordController.text != confirmPasswordController.text) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Password Mismatch'),
                content: const Text('Passwords do not match.'),
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
          return;
        }

        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Send email verification
        await userCredential.user!.sendEmailVerification();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Email Verification'),
              content: const Text(
                  'Please check your email and verify your account to proceed.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Créer un compte',
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
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre adresse mail',
                      labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white, // Background color of the input field
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Veuillez entrer un e-mail valide'; // Change 'Please enter a valid email' to 'Veuillez entrer un e-mail valide'
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  child: TextFormField(
                    controller: passwordController,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {
                        isPasswordNotEmpty = value.isNotEmpty;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty || value.length < 6) {
                        return 'Le mot de passe doit comporter au moins 6 caractères';
                      }
                      return null;
                    },
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white, // Background color of the input field
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      hintText: 'Entrez votre mot de passe',
                      suffixIcon: isPasswordNotEmpty
                          ? IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.cyan,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            )
                          : null, // If password is empty, hide the icon
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  child: TextFormField(
                    controller: confirmPasswordController,
                    obscureText:
                        _obscureTextConfirm, // New boolean for confirming password visibility
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white, // Background color of the input field
                      hintText: 'Confirmez votre mot de passe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      suffixIcon: isConfirmPasswordNotEmpty
                          ? IconButton(
                              icon: Icon(
                                _obscureTextConfirm
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.cyan,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureTextConfirm = !_obscureTextConfirm;
                                });
                              },
                            )
                          : null,
                    ),
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value != passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        isConfirmPasswordNotEmpty = value.isNotEmpty;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _registerAndSendVerificationEmail,
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(), backgroundColor: Colors.white,
                    minimumSize: const Size(120, 40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'S\'inscrire',
                      style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
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
