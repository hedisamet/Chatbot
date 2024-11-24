import 'package:wellbeingGuide/exercises/breathing.dart';
import 'package:wellbeingGuide/exercises/meditation.dart';
import 'package:wellbeingGuide/exercises/relaxation.dart';
import 'package:wellbeingGuide/exercises/yoga.dart';
import 'package:wellbeingGuide/patient/RelaxationExerciseScreen.dart';
import 'package:wellbeingGuide/patient/home_page.dart';
import 'package:wellbeingGuide/widgets/doctor_item.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tableau de bord des exercices',
          style: TextStyle(
            color: Colors.white, // Change text color to cyan
          ),
        ),
        backgroundColor: Colors.teal[300],
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 30,
                  childAspectRatio: 0.9, 
                  children: [
                    GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BreathingExercisePage()),
                      );
                    },
                    child: ExerciseItem(
                      image: "assets/images/breathing.png",
                      title: "Respiration",
                      description: "Sophrologie et angoisse",
                    ),
                  ),
                    GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MeditationExercisePage()),
                      );
                    },
                    child: ExerciseItem(
                      image: "assets/images/lotus-position.png",
                      title: "Méditation",
                      description: "Focalisez l'esprit, détendez-vous.",
                    ),
                  ),
                    GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VideoRelaxationPage()),
                      );
                    },
                    child: ExerciseItem(
                      image: "assets/images/relaxing.png",
                      title: "Relaxation",
                      description: "Calme intérieur",
                    ),
                  ),
                    GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => YogaPage()),
                      );
                    },
                    child: ExerciseItem(
                      image: "assets/images/yoga.png",
                      title: "Yoga",
                      description: "Pratiquez des postures apaisantes.",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RelaxationExerciseScreen()),
                      );
                    },
                    child: ExerciseItem(
                      image: "assets/images/jacobson.png",
                      title: "Jacobson",
                      description: "Détendez-vous avec cet exercice.",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RelaxationExerciseScreen()),
                      );
                    },
                    child: ExerciseItem(
                      image: "assets/images/colonnes_beck.png",
                      title: "Colonnes de Beck",
                      description: "Gérer vos émotions & pensées",
                    ),
                  )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
