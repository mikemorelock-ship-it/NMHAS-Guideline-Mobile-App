import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contacts, size: 64),
            SizedBox(height: 16),
            Text(
              'Contact directory coming soon',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
