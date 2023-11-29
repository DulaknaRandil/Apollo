import 'package:apollodemo1/auth/login_screen.dart';
import 'package:apollodemo1/auth/registration_screen%20(2).dart';
import 'package:apollodemo1/pages/register_page.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LoginOrRegisterPage> {
  // initially show login page
  bool showLoginPage = true;

  //toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginScreen(
        onTap: togglePages,
      );
    } else {
      return RegistrationScreen(
        onTap: togglePages,
      );
    }
  }
}
