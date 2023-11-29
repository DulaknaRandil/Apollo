import 'package:flutter/material.dart';

import '../Payment.dart';
import '../user_profile.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Apollo Premium Plan'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Plan information
            Card(
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
                        color: Colors.black, // Yellow color
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'LKRO.00',
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '1 Premium Account',
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'FOR 1 MONTH',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),

            // Start free month button
            SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.play_arrow),
              label: Text('Start free month'),
            ),

            // Billing information
            SizedBox(height: 16.0),
            Card(
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
                        color: Colors.black, // Yellow color
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Start billing date',
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '12 Dec 2023',
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '- Only LKR529.00/month after 1 month trial',
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'You won\'t be charged until 12 Dec 2023',
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'O Cancel at any time. Offer terms apply.',
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '• We\'ll remind you 7 days before you get charged.',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),

            // Choose how to pay
            SizedBox(height: 16.0),
            Card(
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
                        color: Colors.black, 
                        //backgroundColor:Color(yellow)
                        
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'You can pay for your Premium plan directly through Credit/Debit Cards.',
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 8.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder:(context) => MySample()));
                          },
                          icon: Icon(Icons.apple_sharp),
                          label: Text('Card Payments'),
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

void main() {
  runApp(const MaterialApp(
    home: MyWidget(),
  ));
}
