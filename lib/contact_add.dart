import 'package:flutter/material.dart';

import 'contact.dart';
import 'database.dart';

class AddContactScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  void _addContact(BuildContext context) async {
    final name = nameController.text;
    final phone = phoneController.text;
    final email = emailController.text;

    print('Name: $name');
    print('Phone: $phone');
    print('Email: $email');

    if (name.isNotEmpty && phone.isNotEmpty && email.isNotEmpty) {
      final newContact = Contact(name: name, phone: phone, email: email);

      print('Adding new contact: $newContact');

      await DatabaseHelper.instance.insertContact(newContact);
      Navigator.pop(context, newContact);
    } else {
      print('Validation error: All fields must be filled.');

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('All fields must be filled.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Contact'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _addContact(context);
              },
              child: Text('Add Contact'),
            ),
          ],
        ),
      ),
    );
  }
}
