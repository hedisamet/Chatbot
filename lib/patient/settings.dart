import 'package:wellbeingGuide/authentication/login.dart';
import 'package:wellbeingGuide/widgets/custom_app_bar.dart';
import 'package:wellbeingGuide/widgets/custom_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wellbeingGuide/widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 3; // Initial index for the "More" page
  String? username;

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
      appBar: CustomAppBar(
        fetchUsername: fetchUsername,
        onSearchPressed: () {
          // Handle search icon tap
        },
        onNotificationPressed: () {
          // Handle notification icon tap
        },
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsTile(
                  color: Colors.blue,
                  icon: Icons.account_circle_outlined,
                  title: "Compte",
                  onTap: () {},
                ),
                const SizedBox(
                  height: 10,
                ),
                SettingsTile(
                  color: Colors.green,
                  icon: Icons.edit_outlined,
                  title: "Modifier les Informations",
                  onTap: () {},
                ),
                const SizedBox(
                  height: 40,
                ),
                SettingsTile(
                  color: Colors.teal,
                  icon: Icons.chat_bubble_outlined,
                  title: "Chatter avec le chatbot",
                  onTap: () {},
                ),
                const SizedBox(
                  height: 10,
                ),
                SettingsTile(
                  color: Colors.orange,
                  icon: Icons.description_outlined,
                  title: "Formulaires",
                  onTap: () {},
                ),
                const SizedBox(
                  height: 10,
                ),
                SettingsTile(
                  color: Colors.deepPurple,
                  icon: Icons.psychology_outlined,
                  title: "Exercices",
                  onTap: () {},
                ),
                const SizedBox(
                  height: 10,
                ),
                SettingsTile(
                  color: Colors.purple,
                  icon: Icons.calendar_today_outlined,
                  title: "Rendez-vous",
                  onTap: () {},
                ),
                const SizedBox(
                  height: 40,
                ),
                SettingsTile(
                  color: Colors.red,
                  icon: Icons.logout_outlined,
                  title: "Se déconnecter",
                  onTap: () {
                    // Perform sign out
                    _signOut(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
