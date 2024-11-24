import 'package:wellbeingGuide/patient/chatbot.dart';
import 'package:wellbeingGuide/patient/more.dart';
import 'package:wellbeingGuide/patient/settings.dart';
import 'package:wellbeingGuide/widgets/custom_app_bar.dart';
import 'package:wellbeingGuide/widgets/custom_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RelaxationExerciseScreen extends StatefulWidget {
  const RelaxationExerciseScreen({Key? key}) : super(key: key);

  @override
  _RelaxationExerciseScreenState createState() =>
      _RelaxationExerciseScreenState();
}

class _RelaxationExerciseScreenState extends State<RelaxationExerciseScreen> {
  List<bool> muscleStates = List.generate(5, (index) => false);

  void toggleMuscleState(int index) {
    setState(() {
      muscleStates[index] = !muscleStates[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        fetchUsername: fetchUsername, // You can customize this as needed
        onSearchPressed: () {
          // Handle search icon tap
        },
        onNotificationPressed: () {
          // Handle notification icon tap
        },
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.cyan[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      "assets/images/relaxation.png", // Replace with your image
                      width: 92,
                      height: 100,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Exercice de Relaxation",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        const SizedBox(
                          width: 120,
                          child: Text(
                            "Détendez-vous avec cet exercice",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            // You can customize the action when the button is tapped
                          },
                          child: Container(
                            width: 150,
                            height: 35,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.cyan[300],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: const Center(
                              child: Text(
                                "Commencer",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Instructions:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Asseyez-vous confortablement dans un endroit calme.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '2. Fermez les yeux et respirez profondément.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '3. Commencez par contracter puis relâcher chaque groupe musculaire.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Groupes musculaires:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              buildMuscleGroup('Mâchoires', 0),
              buildMuscleGroup('Épaules', 1),
              buildMuscleGroup('Poitrine', 2),
              buildMuscleGroup('Ventre', 3),
              buildMuscleGroup('Pieds', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMuscleGroup(String muscleName, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: muscleStates[index],
            onChanged: (bool? value) {
              toggleMuscleState(index);
            },
            activeColor: Colors.cyan[300],
          ),
          Text(
            muscleName,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
