import 'dart:io';

import 'package:apollodemo1/auth/user_profile/freeplan.dart';
import 'package:apollodemo1/home_screen/home_screen.dart';
import 'package:apollodemo1/pages/auth_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:apollodemo1/auth/update_profile.dart';
import 'package:apollodemo1/auth/user_profile/account.dart';
import 'package:apollodemo1/home_screen/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_helper (1).dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? profileImage;
  String? uName;
  String? eMail;
  final ImagePicker _picker = ImagePicker();

  String downloadURL = '';
  File? profileImageFile;

  //firebase
  final _auth = FirebaseAuth.instance;
  final _storageRef = FirebaseStorage.instance.ref();

  @override
  void initState() {
    getProfilePhoto();
    super.initState();
  }

  void getProfilePhoto() async {
    setState(() {
      _isLoading = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      final db = FirebaseFirestore.instance;

      if (user != null) {
        DocumentSnapshot documentSnapshot =
            await db.collection('users').doc(user.uid).get();
        Map<String, dynamic> userData =
            documentSnapshot.data() as Map<String, dynamic>;
        profileImage = userData['profileImage'];
        eMail = userData['emailAddress'];
        uName = userData['firstName'];
        setState(() {
          _isLoading = false;
        });
        print(profileImage);
      } else {
        setState(() {
          _isLoading = false;
        });
        print("User not signed in");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error getting user information: $e");
    }
  }

  Widget imageProfile(String original) {
    return Stack(
      children: <Widget>[
        CircleAvatar(
          radius: 80.0,
          child: ClipOval(
              child: profileImageFile != null
                  ? Image.file(
                      profileImageFile!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      '$original',
                      fit: BoxFit.fill,
                      width: 400,
                    )),
        ),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: IconButton(
            icon: Icon(
              Icons.camera_alt,
              color: Colors.teal,
              size: 28.0,
            ),
            onPressed: () {
              _openImagePicker();
            },
          ),
        ),
      ],
    );
  }

  void _openImagePicker() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        print(pickedImage.path);
        profileImageFile = File(pickedImage.path);
        _uploadImage(File(pickedImage.path));
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage(File file) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    try {
      String fileName = file.path.split('/').last;
      Reference dataRef = _storageRef.child('profilePictures/$fileName');
      await dataRef.putFile(file);
      final downloadURL = await dataRef.getDownloadURL();
      print('Image uploaded. Download URL: $downloadURL');
      await firebaseFirestore.collection("users").doc(user!.uid).update({
        'profileImage': downloadURL,
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.black,
        /* leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),*/
        title: const Center(
          child: Text(
            "Profile",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.star_border_purple500_outlined,
                color: (Colors.white),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : Container(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      imageProfile(profileImage ?? 'https://picsum.photos/200'),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        uName ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        eMail ?? "",
                        style: TextStyle(fontSize: 19),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyWidget()),
                            );
                          },
                          child: const Text("Go Premium"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              side: BorderSide.none,
                              shape: const StadiumBorder()),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      ///Menu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const Divider(),
                            proMod(
                              title: "Account",
                              icon: Icons.settings,
                              onPress: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => AccountPage()),
                                );
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            proMod(
                                title: "Notification",
                                icon: Icons.person_outline_outlined,
                                onPress: () {
                                  Navigator.of(context).pop();
                                }),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(),
                            const SizedBox(
                              height: 10,
                            ),
                            proMod(
                                title: "Advertisement",
                                icon: Icons.info_outline,
                                onPress: () {}),
                            const SizedBox(
                              height: 10,
                            ),
                            proMod(
                              title: "About",
                              icon: Icons.info_outline,
                              onPress: () {},
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            proMod(
                                title: "LogOut",
                                icon: Icons.logout,
                                textColor: Colors.orange,
                                endIcon: false,
                                onPress: () {
                                  AuthPage();
                                }),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class proMod extends StatelessWidget {
  const proMod({
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor = Colors.white,
    super.key,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.blueGrey.withOpacity(0.3),
        ),
        child: Icon(
          icon,
          color: Colors.orange,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: endIcon
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color:
                    const Color.fromARGB(255, 255, 255, 255).withOpacity(0.05),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
