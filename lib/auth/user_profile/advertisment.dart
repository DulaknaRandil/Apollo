import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailPage extends StatelessWidget {
  final _recipientController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      appBar: AppBar(
        title: Text('Advertisment'),
        backgroundColor: Colors.black, // Set the background color to black
      ),
      body: _buildEmailComposer(context),
    );
  }

  Widget _buildEmailComposer(BuildContext context) {
    final amberColor = Colors.amber;

    OutlineInputBorder _defaultBorder() {
      return OutlineInputBorder(
        borderSide: BorderSide(color: amberColor),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _recipientController,
            decoration: InputDecoration(
              labelText: 'Recipient Email',
              labelStyle: TextStyle(color: Colors.white),
              focusedBorder: _defaultBorder(),
              enabledBorder: _defaultBorder(),
            ),
            style: TextStyle(color: Colors.white),
            cursorColor: amberColor,
          ),
          SizedBox(
            height: 50,
          ),
          TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: 'Subject',
              labelStyle: TextStyle(color: Colors.white),
              focusedBorder: _defaultBorder(),
              enabledBorder: _defaultBorder(),
            ),
            style: TextStyle(color: Colors.white),
            cursorColor: amberColor,
          ),
          SizedBox(
            height: 50,
          ),
          TextField(
            controller: _bodyController,
            maxLines: 10,
            decoration: InputDecoration(
              labelText: 'Body',
              labelStyle: TextStyle(color: Colors.white),
              focusedBorder: _defaultBorder(),
              enabledBorder: _defaultBorder(),
            ),
            style: TextStyle(color: Colors.white),
            cursorColor: amberColor,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _sendEmail(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: amberColor,
            ),
            child: Text('Send Email', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  _sendEmail(BuildContext context) async {
    final String username = 'randildulakna@gmail.com';
    final String password = '03133149140718069187';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Your Name')
      ..recipients.add(_recipientController.text)
      ..subject = _subjectController.text
      ..text = _bodyController.text;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email sent successfully'),
      ));
    } catch (e, stackTrace) {
      print('Error: $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send email. Check logs for details.'),
      ));
    }
  }
}
