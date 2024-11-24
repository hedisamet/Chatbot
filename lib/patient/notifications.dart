import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.teal[300],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('notifications')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No notifications.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var notificationData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/anonymous.png'),
                ),
                title: FutureBuilder<String?>(
                  future: fetchUserName(notificationData['patientId']),
                  builder: (context, usernameSnapshot) {
                    return Text(
                      usernameSnapshot.data ?? 'Loading...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                subtitle: Text('Sent you a doctor request'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        acceptRequest(notificationData['patientId']);
                      },
                      icon: Icon(Icons.check),
                    ),
                    IconButton(
                      onPressed: () {
                        declineRequest(notificationData['patientId']);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> fetchUserName(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userInfoDoc =
          await FirebaseFirestore.instance.collection('user_info').doc(userId).get();
      if (userInfoDoc.exists) {
        var name = userInfoDoc['name'] ?? '';
        var familyName = userInfoDoc['family_name'] ?? '';
        if (name.isNotEmpty && familyName.isNotEmpty) {
          return '$name $familyName';
        }
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
    return null;
  }

void acceptRequest(String patientId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentReference doctorRef =
            FirebaseFirestore.instance.collection('doctors').doc(currentUser.uid);
        DocumentReference userInfoRef =
            FirebaseFirestore.instance.collection('user_info').doc(patientId);

        // Update the doctor's 'patient_list' field
        await doctorRef.update({
          'patient_list': FieldValue.arrayUnion([patientId])
        });

        // Update the patient's 'doctor' field
        await userInfoRef.update({'doctor': currentUser.uid});

        // Remove the notification from the 'notifications' collection
        await doctorRef
            .collection('notifications')
            .doc(patientId)
            .delete();

        // Send a notification to the patient
        String? fcmToken = await _fetchPatientFCMToken(patientId);
        if (fcmToken != null) {
          await _firebaseMessaging.sendMessage(
            to: fcmToken,
            data: {
              'title': 'Doctor Request Accepted',
              'body': 'Your doctor request has been accepted.',
            },
          );
        }
      }
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  void declineRequest(String patientId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentReference doctorRef =
            FirebaseFirestore.instance.collection('doctors').doc(currentUser.uid);

        // Remove the notification from the 'notifications' collection
        await doctorRef
            .collection('notifications')
            .doc(patientId)
            .delete();

        // Send a notification to the patient
        String? fcmToken = await _fetchPatientFCMToken(patientId);
        if (fcmToken != null) {
          await _firebaseMessaging.sendMessage(
            to: fcmToken,
            data: {
              'title': 'Doctor Request Declined',
              'body': 'Your doctor request has been declined.',
            },
          );
        }
      }
    } catch (e) {
      print('Error declining request: $e');
    }
  }

  Future<String?> _fetchPatientFCMToken(String patientId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userInfoDoc =
          await FirebaseFirestore.instance.collection('user_info').doc(patientId).get();
      if (userInfoDoc.exists) {
        return userInfoDoc['fcmToken'] as String?;
      }
    } catch (e) {
      print('Error fetching FCM token: $e');
    }
    return null;
  }
}