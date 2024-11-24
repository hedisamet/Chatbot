import 'package:wellbeingGuide/widgets/custom_app_bar.dart';
import 'package:wellbeingGuide/widgets/custom_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class Event {
  final String title;
  final String patientId;
  final DateTime time;

  Event({
    required this.title,
    required this.patientId,
    required this.time,
  });

  String toString() => this.title;
}

class _CalendarState extends State<Calendar> {
  late Map<DateTime, List<Event>> selectedEvents;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  TextEditingController _eventController = TextEditingController();
  String? selectedPatientId;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _patientList = [];

  @override
  void initState() {
    selectedEvents = {};
    _fetchPatientList();
    super.initState();
  }

  Future<void> _fetchPatientList() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      DocumentSnapshot<Map<String, dynamic>> doctorDoc =
          await _firestore.collection('doctors').doc(currentUserId).get();
      if (doctorDoc.exists) {
        List<dynamic> patientList = doctorDoc.data()!['patient_list'];
        setState(() {
          _patientList = patientList.cast<String>();
        });
      }
    }
  }

  List<Event> _getEventsfromDay(DateTime date) {
    return selectedEvents[date] ?? [];
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _selectedIndex = 0;
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              focusedDay: selectedDay,
              firstDay: DateTime(1990),
              lastDay: DateTime(2050),
              calendarFormat: format,
              onFormatChanged: (CalendarFormat _format) {
                setState(() {
                  format = _format;
                });
              },
              startingDayOfWeek: StartingDayOfWeek.sunday,
              daysOfWeekVisible: true,

              //Day Changed
              onDaySelected: (DateTime selectDay, DateTime focusDay) {
                setState(() {
                  selectedDay = selectDay;
                  focusedDay = focusDay;
                });
                print(focusedDay);
              },
              selectedDayPredicate: (DateTime date) {
                return isSameDay(selectedDay, date);
              },

              eventLoader: _getEventsfromDay,

              //To style the Calendar
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(
                  color: Colors.cyan,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
                todayDecoration: BoxDecoration(
                  color: Colors.purpleAccent,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ..._getEventsfromDay(selectedDay).map(
              (Event event) => ListTile(
                title: Text(
                  event.title,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
      onPressed: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Fixer date"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _eventController,
                decoration: InputDecoration(
                  hintText: "Enter event title",
                ),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
  hint: Text("Select patient"),
  value: selectedPatientId,
  onChanged: (String? value) {
    setState(() {
      selectedPatientId = value;
    });
  },
  items: _patientList.map((patientId) {
    return DropdownMenuItem<String>(
      value: patientId,
      child: StatefulBuilder(
        builder: (context, setState) {
          return FutureBuilder<String?>(
            future: fetchUserName(patientId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!);
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator(); // Show a loading indicator while fetching the name
              }
            },
          );
        },
      ),
    );
  }).toList(),
),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Annuler"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Confirmer"),
              onPressed: () {
                if (_eventController.text.isEmpty || selectedPatientId == null) {
                  // Handle empty fields
                } else {
                  DateTime currentDateTime = DateTime.now();
                  TimeOfDay currentTime = TimeOfDay.now();
                  DateTime appointmentDateTime = DateTime(
                    currentDateTime.year,
                    currentDateTime.month,
                    currentDateTime.day,
                    currentTime.hour,
                    currentTime.minute,
                  );

                  if (selectedEvents[selectedDay] != null) {
                    selectedEvents[selectedDay]?.add(
                      Event(
                        title: _eventController.text,
                        patientId: selectedPatientId!,
                        time: appointmentDateTime,
                      ),
                    );
                  } else {
                    selectedEvents[selectedDay] = [
                      Event(
                        title: _eventController.text,
                        patientId: selectedPatientId!,
                        time: appointmentDateTime,
                      )
                    ];
                  }
                }
                Navigator.pop(context);
                _eventController.clear();
                selectedPatientId = null;
                setState(() {});

                // Send notification to the patient
                sendNotificationToPatient(selectedPatientId!);
                return;
              },
            ),
          ],
        ),
      ),
      label: Text("Fixer date"),
      icon: Icon(Icons.add),
      backgroundColor: Colors.cyan,
    ),
    );
  }

  Future<String?> fetchUserName(String userId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> userInfoDoc =
        await _firestore.collection('user_info').doc(userId).get();
    if (userInfoDoc.exists) {
      var name = userInfoDoc['name'] ?? '';
      var familyName = userInfoDoc['family_name'] ?? '';
      if (name.isNotEmpty && familyName.isNotEmpty) {
        return '$name $familyName';
      } else {
        return 'Unknown'; // Return a default value if name and familyName are empty
      }
    }
  } catch (e) {
    print('Error fetching username: $e');
  }
  return null;
}

  Future<void> sendNotificationToPatient(String patientId) async {
    try {
      String? fcmToken = await _fetchPatientFCMToken(patientId);
      if (fcmToken != null) {
        await _firebaseMessaging.sendMessage(
          to: fcmToken,
          data: {
            'title': 'Appointment Request',
            'body': 'You have a new appointment request.',
          },
        );
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<String?> _fetchPatientFCMToken(String patientId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userInfoDoc =
          await _firestore.collection('user_info').doc(patientId).get();
      if (userInfoDoc.exists) {
        return userInfoDoc['fcmToken'] as String?;
      }
    } catch (e) {
      print('Error fetching FCM token: $e');
    }
    return null;
  }
}