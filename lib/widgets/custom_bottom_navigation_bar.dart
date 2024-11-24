import 'package:wellbeingGuide/doctor/appointment.dart';
import 'package:wellbeingGuide/patient/home_page.dart';
import 'package:wellbeingGuide/patient/settings.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      iconSize: 24,
      currentIndex: currentIndex,
      onTap: (int index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (index == 1) {
          // Navigate to the calendar page when the calendar icon is tapped
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Calendar()), // Assuming Calendar is the name of your calendar page
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );
        } else {
          onTap(index);
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
    );
  }
}
