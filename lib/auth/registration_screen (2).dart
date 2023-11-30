import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:apollodemo1/auth/model/user_model.dart';
import 'package:apollodemo1/home_screen/home_page.dart';
import 'package:apollodemo1/home_screen/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final Function()? onTap;
  const RegistrationScreen({super.key, required this.onTap});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // form key
  final _formKey = GlobalKey<FormState>();

  //firebase
  final _auth = FirebaseAuth.instance;
  final _storageRef = FirebaseStorage.instance.ref();

  bool _isLoading = false; // Track loading state

  //editting controllers

  final userNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final ImagePicker _picker = ImagePicker();
  String downloadURL = '';
  File? profileImage;

  @override
  Widget build(BuildContext context) {
    //First Name Field

    final userNameField = TextFormField(
      autofocus: false,
      controller: userNameController,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = RegExp(r'^.{5,}$'); //entering minimum value 5
        if (value!.isEmpty) {
          return ("User Name Is Required");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid User Name (Min. 5 Characters)");
        }
        return null;
      },
      onSaved: (value) {
        userNameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.account_circle),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "First Name",
        hintStyle: TextStyle(color: Colors.white),
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white, // Change border color to white
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white, // Change border color to white
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );

    //Last Name Field
    final residentialAddressField = TextFormField(
      autofocus: false,
      controller: lastNameController,
      keyboardType: TextInputType.streetAddress,
      validator: (value) {
        RegExp regex = RegExp(r'^.{5,}$'); //entering minimum value
        if (value!.isEmpty) {
          return ("Last NameIs Required");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Name(Min. 5 Characters)");
        }
        return null;
      },
      onSaved: (value) {
        lastNameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Last Name",
        hintStyle: TextStyle(color: Colors.white),
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(
                255, 255, 255, 255), // Change border color to red
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );

    //Email field
    final emailField = TextFormField(
      autofocus: false,
      controller: emailAddressController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }
        //reg exression for email validation
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please Enter valid Email");
        }
        return null;
      },
      onSaved: (value) {
        emailAddressController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        hintStyle: TextStyle(color: Colors.white),
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(
                255, 255, 255, 255), // Change border color to white
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );

    //Password field
    final passwordField = Stack(
      children: [
        TextFormField(
          autofocus: false,
          controller: passwordController,
          obscureText: !_isPasswordVisible, // Toggle password visibility
          validator: (value) {
            RegExp regex = RegExp(r'^.{6,}$'); //entering minimum value 8
            if (value!.isEmpty) {
              return ("Password Is Required");
            }
            if (!regex.hasMatch(value)) {
              return ("Enter Valid Password (Min. 8 Characters)");
            }
            return null;
          },
          onSaved: (value) {
            passwordController.text = value!;
          },
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock),
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Password",
            hintStyle: TextStyle(color: Colors.white),
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(
                    255, 255, 255, 255), // Change border color to red
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue, // Change border color to blue when focused
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey, // Set the eye icon's color to gray
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
              });
            },
          ),
        ),
      ],
    );

    //ConfirmPAssword field
    final confirmPasswordField = Stack(
      children: [
        TextFormField(
          autofocus: false,
          controller: confirmPasswordController,
          obscureText:
              !_isConfirmPasswordVisible, // Toggle confirm password visibility
          validator: (value) {
            if (confirmPasswordController.text != passwordController.text) {
              return "Password Don't Match";
            }
            return null;
          },
          onSaved: (value) {
            confirmPasswordController.text = value!;
          },
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock),
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Confirm Password",
            hintStyle: TextStyle(color: Colors.white),
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(
                    255, 255, 255, 255), // Change border color to red
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue, // Change border color to blue when focused
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.grey, // Set the eye icon's color to gray
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible =
                    !_isConfirmPasswordVisible; // Toggle visibility
              });
            },
          ),
        ),
      ],
    );

    ///signup button
    final signUpButton = Material(
      elevation: 5,
      color: Color.fromRGBO(252, 250, 250, 1),
      borderRadius: BorderRadius.circular(30),
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          signUp(emailAddressController.text, passwordController.text);
        },
        child: const Text(
          "SignUp",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
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
                        // Image Profile Widget
                        imageProfile(),
                        SizedBox(height: 5),
                        Text(
                          "Let's create an account for you!",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        userNameField,
                        const SizedBox(
                          height: 20,
                        ),

                        residentialAddressField,
                        const SizedBox(
                          height: 20,
                        ),
                        emailField,
                        const SizedBox(
                          height: 20,
                        ),
                        passwordField,
                        const SizedBox(
                          height: 20,
                        ),
                        confirmPasswordField,
                        const SizedBox(
                          height: 40,
                        ),
                        signUpButton,
                        const SizedBox(
                          height: 15,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 255, 166, 82)),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) // Display loading indicator with a semi-transparent background
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget imageProfile() {
    return Stack(
      children: <Widget>[
        CircleAvatar(
          radius: 80.0,
          child: ClipOval(
              child: profileImage != null
                  ? Image.file(
                      profileImage!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Image.asset('assets/me1.jpg')),
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
        profileImage = File(pickedImage.path);
        _uploadImage(File(pickedImage.path));
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage(File file) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String fileName = file.path.split('/').last;
      Reference dataRef = _storageRef.child('profilePictures/$fileName');
      await dataRef.putFile(file);
      downloadURL = await dataRef.getDownloadURL();
      print('Image uploaded. Download URL: $downloadURL');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error uploading image: $e');
    }
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        await postDetailToFirestore();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Homepage(),
          ),
          (route) => false,
        );
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      } finally {
        if (mounted) {
          // Check if the widget is still mounted before calling setState
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
        }
      }
    }
  }

  postDetailToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    //writting all the values
    userModel.emailAddress = user!.email;
    userModel.firstName = userNameController.text;
    userModel.lastName = lastNameController.text;
    userModel.confirmPassword = confirmPasswordController.text;
    userModel.password = passwordController.text;
    userModel.profileImage = downloadURL;

    //creating new collection in firestore
    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "Account Created Successfully !");

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false);
  }
}
