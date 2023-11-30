import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPassScreen extends StatefulWidget {
  const ResetPassScreen({super.key});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      autofocus: false,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        } else if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
            .hasMatch(value)) {
          return "Please Enter a valid Email";
        }
        return null;
      },
      onSaved: (value) {
        _emailController.text = value!;
      },
      style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: "Email",

        //style: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white),
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(
                255, 255, 255, 255), // Change border color to white
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final resetBtn = Material(
      elevation: 5,
      color: Color.fromRGBO(246, 242, 243, 1),
      borderRadius: BorderRadius.circular(30),
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width * 0.5,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _auth
                .sendPasswordResetEmail(email: _emailController.text)
                .then((value) {
              print("Password reset email sent.");
              Fluttertoast.showToast(msg: "Password reset email sent.");
              Navigator.of(context).pop();
            }).catchError((error) {
              print("Password reset failed: Enter valid Email");
              Fluttertoast.showToast(
                  msg: "Password reset failed: Enter valid Email");
            });
          }
        },
        child: const Text(
          "Reset Password",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Forget Password',
          style: TextStyle(color: Color.fromARGB(255, 248, 246, 246)),
        ),
        backgroundColor: Color.fromRGBO(10, 10, 0, 1),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 200,
                        child: Image.asset(
                          "assets/unlock.png",
                          width: 90,
                          fit: BoxFit.contain, //
                        ),
                      ),
                      Text(
                        "Please enter your email",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 65,
                      ),
                      emailField,
                      const SizedBox(
                        height: 40,
                      ),
                      resetBtn,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
