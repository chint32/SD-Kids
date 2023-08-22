import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmitEventScreen extends StatefulWidget {
  const SubmitEventScreen({super.key});

  @override
  State<SubmitEventScreen> createState() => _SubmitEventScreenState();
}

class _SubmitEventScreenState extends State<SubmitEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String orgName = '';
  String orgEmail = '';
  String title = '';
  String subtitle = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      hintText: 'Organizer Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Organizer Name';
                    }
                    orgName = value;
                    return null;
                  },
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Organizer Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Organizer Email';
                  }
                  orgEmail = value;
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Event Title';
                  }
                  title = value;
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Event Subtitle'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Event Subtitle';
                  }
                  subtitle = value;
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Event Image Url'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Event Image Url';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Event Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Event Price';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    _sendEmail(orgName, orgEmail, title, subtitle);
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _sendEmail(String orgName, String orgEmail, String title, String subtitle) async {
  String email = 'hinton.c32@gmail.com';
  String subject = 'EVENT SUBMISSION';
  String body = 'Organizer Name: $orgName\nOrganizer Email: $orgEmail\nEvent Title: $title\nEvent Subtitle: $subtitle';
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: email,
    query: encodeQueryParameters(<String, String>{
      'subject': subject,
      'body': body
    }),
  );

  launchUrl(emailLaunchUri);
}
