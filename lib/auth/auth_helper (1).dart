import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class AuthHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final Function()? onTap;
  // Singleton pattern to ensure a single instance of AuthHelper
  static AuthHelper? _instance;
  static AuthHelper get instance {
    _instance ??= AuthHelper();
    return _instance!;
  }

// Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = authResult.user;
      return user;
    } catch (e) {
      print("Error signing in with email and password: $e");
      return null;
    }
  }

//logout Method
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Set the 'isLoggedIn' flag to false when the user logs out

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => LoginScreen(
                onTap: onTap,
              )),
    );
  }
}


// //login function
//   void signIn(String email, String password) async {
//     if (_formKey.currentState!.validate()) {
//       await _auth
//           .signInWithEmailAndPassword(email: email, password: password)
//           .then((uid) => {
//                 Fluttertoast.showToast(msg: "Login Successfull"),
//                 Navigator.of(context).pushReplacement(
//                     MaterialPageRoute(builder: (context) => HomeScreen())),
//               })
//           .catchError((e) {
//         Fluttertoast.showToast(msg: e!.message);
//       });
//     }
//   }
   
