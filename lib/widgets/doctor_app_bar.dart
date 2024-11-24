import 'dart:io';
import 'package:wellbeingGuide/patient/notifications.dart';
import 'package:wellbeingGuide/patient/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_platform_interface/src/types/image_source.dart' as ImageSource;

class DoctorAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Future<String?> Function() fetchUsername;
  final Function()? onSearchPressed;
  final Function()? onNotificationPressed;

  const DoctorAppBar({
    Key? key,
    required this.fetchUsername,
    this.onSearchPressed,
    this.onNotificationPressed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CustomAppBarState();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<DoctorAppBar> {
  Future<File?> pickImage(ImageSource.ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String?> uploadImageToFirebaseStorage(
      File imageFile, String userId, String fileExtension) async {
    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('doctor_avatar/$userId.$fileExtension');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Update the user's avatar URL in Firestore
      await FirebaseFirestore.instance
          .collection('user_info')
          .doc(userId)
          .update({'avatarUrl': downloadUrl});

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> deleteOldImageFromFirebaseStorage(String userId) async {
    try {
      Reference storageRef =
          FirebaseStorage.instance.ref().child('doctor_avatar/$userId');
      await storageRef.delete();
    } catch (e) {
      print('Error deleting old image: $e');
    }
  }

  Future<String?> fetchAvatarUrl() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot<Map<String, dynamic>> userInfoDoc =
            await FirebaseFirestore.instance
                .collection('doctors')
                .doc(currentUser.uid)
                .get();
        if (userInfoDoc.exists) {
          String? avatarUrl = userInfoDoc['avatarUrl'] as String?;
          if (avatarUrl != null) {
            return avatarUrl;
          } else {
            // Default picture for users without avatars
            return 'assets/images/anonymous.png';
          }
        }
      }

      return null;
    } catch (e) {
      print('Error fetching avatar URL: $e');
      return null;
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
          child: Stack(
            children: [
              GestureDetector(
                onTap: () async {
                  ImageSource.ImageSource source = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Choisir une Photo de Profil'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, ImageSource.ImageSource.camera),
                          child: Text('Camera'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, ImageSource.ImageSource.gallery),
                          child: Text('Gallerie'),
                        ),
                      ],
                    ),
                  );

                  if (source != null) {
                    File? imageFile = await pickImage(source);
                    if (imageFile != null) {
                      User? currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        String? userId = currentUser.uid;
                        await deleteOldImageFromFirebaseStorage(userId);
                        String? downloadUrl =
                            await uploadImageToFirebaseStorage(imageFile, userId, 'png');
                        if (downloadUrl != null) {
                          // Update the user's avatar URL in Firestore
                          await FirebaseFirestore.instance
                              .collection('doctors')
                              .doc(userId)
                              .update({'avatarUrl': downloadUrl});
                        }
                      }
                    }
                  }
                },
                child: FutureBuilder<String?>(
                  future: fetchAvatarUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                      );
                    } else if (snapshot.hasError) {
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                      );
                    } else if (snapshot.data != null) {
                      return CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(snapshot.data!),
                      );
                    } else {
                      // Default picture for users who haven't changed their avatars
                      return CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/anonymous.png'),
                      );
                    }
                  },
                ),
              ),
              Positioned(
                bottom: -1,
                right: 0,
                child: Icon(
                  Icons.add_a_photo,
                  color: Colors.black54,
                  size: 15, // Adjust the size as needed
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to SearchPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
            icon: const Icon(
              Icons.search,
              color: Colors.black54,
            ),
          ),
          IconButton(
            onPressed: () {
              // Navigate to Notifications
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Notifications()),
              );
            },
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.black54,
            ),
          ),
          IconButton(
            onPressed: () {
              // Open the sidebar drawer
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(
              Icons.settings,
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
                FutureBuilder<String?>(
                  future: widget.fetchUsername(),
                  builder: (context, usernameSnapshot) {
                    return Text(
                      usernameSnapshot.data ?? 'Loading...',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    );
                  },
                ),
              ],
            ),
            // Add other widgets if needed in the Row
          ],
        ),
      ),
    );
  }
}

Future<String?> fetchUsername() async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> userInfoDoc =
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(currentUser.uid)
              .get();
      if (userInfoDoc.exists) {
        // Check if the document exists
        var name = userInfoDoc['name'] ?? '';

        if (name.isNotEmpty) {
          return name;
        }
      }
    }

    return 'Loading...';
  } catch (e) {
    print('Error fetching username: $e');
    return 'Error';
  }
}