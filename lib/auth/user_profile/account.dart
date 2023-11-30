import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    getCurrentUserInfo();
    super.initState();
  }

  void getCurrentUserInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        nameController.text = user.displayName ?? "No Name";
        emailController.text = user.email ?? "No Email";
      } else {
        print("User not signed in");
      }
    } catch (e) {
      print("Error getting user information: $e");
    }
  }

  void _changeName(String newName) {
    setState(() {
      nameController.text = newName;
    });
  }

  void _changeEmail(String newEmail) {
    setState(() {
      emailController.text = newEmail;
    });
  }

  void _handleSubmit() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      if (user != null) {
        await user.updateDisplayName(nameController.text);
        await user.updateEmail(emailController.text);
        await firebaseFirestore.collection("users").doc(user.uid).update({
          'emailAddress': emailController.text,
          'firstName': nameController.text
        });

        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        print('Name: ${user?.displayName}, Email: ${user?.email}');

        // Show a success notification
        Fluttertoast.showToast(
          msg: "Successfully changed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        print("User not signed in");
      }
    } catch (e) {
      print("Error updating user information: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Account Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              style: TextStyle(color: Colors.white),
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              onChanged: (newName) {
                _changeName(newName);
              },
            ),
            const SizedBox(height: 20),
            TextField(
              style: TextStyle(color: Colors.white),
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              onChanged: (newEmail) {
                _changeEmail(newEmail);
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                ),
                onPressed: _handleSubmit,
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
