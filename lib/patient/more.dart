import 'package:wellbeingGuide/authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MorePage extends StatelessWidget {
  const MorePage({Key? key, required this.username}) : super(key: key);

  final String? username;

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // After signing out, navigate to the registration page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
      );
    } catch (e) {
      print('Error signing out: $e');
      // Handle error if necessary
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("assets/images/pm.png"),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Handle search icon tap
            },
            icon: Icon(
              Icons.search,
              color: Colors.black54,
            ),
          ),
          IconButton(
            onPressed: () {
              // Handle notification icon tap
            },
            icon: Icon(
              Icons.notifications_none_outlined,
              color: Colors.black54,
            ),
          ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username ?? 'Loading...',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            // Add other widgets if needed in the Row
          ],
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        currentIndex: 3, // Set the index to the "More" page
        onTap: (int index) {
          if (index == 3) {
            // Do nothing, already on the "More" page
          } else {
            // Handle navigation for other icons
            Navigator.pushReplacementNamed(context, '/'); // Replace with the home page route
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              color: Colors.black54,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_month_outlined,
              color: Colors.black54,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat_bubble_outline,
              color: Colors.black54,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.more_horiz_outlined,
              color: Colors.black54,
            ),
            label: '',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to ProfilePage
                  Navigator.pushNamed(context, '/profile');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Change button color
                ),
                child: Text('Profile'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to ParametresPage
                  Navigator.pushNamed(context, '/parametres');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Change button color
                ),
                child: Text('Paramètres'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Perform sign out
                  _signOut(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Change button color
                ),
                child: Text('Se déconnecter'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to ChatbotPage
                  Navigator.pushNamed(context, '/chatter');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Change button color
                ),
                child: Text('Chatter avec le chatbot'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to FormulairesPage
                  Navigator.pushNamed(context, '/formulaires');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Change button color
                ),
                child: Text('Formulaires'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to ExercicesPage
                  Navigator.pushNamed(context, '/exercices');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Change button color
                ),
                child: Text('Exercices'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to RendezVousPage
                  Navigator.pushNamed(context, '/rendezvous');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo, // Change button color
                ),
                child: Text('Rendez-vous'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}