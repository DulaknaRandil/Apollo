import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Payment.dart';
import '../user_profile.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to start a free month?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _startFreeMonth();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  void _startFreeMonth() async {
    // TODO: Replace with your actual logic to get the current user's UID
    String currentUserUID = 'your_current_user_uid';

    // Update Firestore with user information
    await FirebaseFirestore.instance
        .collection('free_plan')
        .doc(currentUserUID)
        .set({
      'subscriptionStatus': false, // User accepted the free month
      'startDate': FieldValue.serverTimestamp(), // Set the start date
    });

    // Schedule a job to set 'subscriptionStatus' to true after 30 days
    await Future.delayed(Duration(days: 30));
    FirebaseFirestore.instance
        .collection('free_plan')
        .doc(currentUserUID)
        .update({
      'subscriptionStatus': true, // Set to true after 30 days
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Apollo Premium Plan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Plan information
            Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.amber, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Color.fromARGB(255, 32, 32, 32),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Individual',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'LKRO.00',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '1 Premium Account',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'FOR 1 MONTH',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // Start free month button
            SizedBox(height: 16.0),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              onPressed: () {
                _showConfirmationDialog(context);
              },
              icon: Icon(Icons.play_arrow),
              label: Text('Start free month'),
            ),

            // Billing information
            SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.amber, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: const Color.fromARGB(255, 31, 30, 30),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Billing information',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Start billing date',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '12 Dec 2023',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '- Only LKR529.00/month after 1 month trial',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'You won\'t be charged until 12 Dec 2023',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'O Cancel at any time. Offer terms apply.',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '• We\'ll remind you 7 days before you get charged.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // Choose how to pay
            SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.amber, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: const Color.fromARGB(255, 32, 31, 31),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose how to pay',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'You can pay for your Premium plan directly through Credit/Debit Cards.',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MySample()),
                            );
                          },
                          icon: Icon(Icons.apple_sharp),
                          label: Text('Card Payments'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
