import 'package:flutter/material.dart';
import 'db_helper.dart'; // Import the database helper

class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registerUser(String username, String password) async {
    final dbHelper = DatabaseHelper.instance;
    final existingUser = await dbHelper.getUser(username);

    if (existingUser != null) {
      throw Exception('User already exists');
    }

    final newUser = {
      'username': username,
      'password': password,
      'level': 0,
    };

    await dbHelper.insertUser(newUser);
  }

  void _register(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    try {
      await _registerUser(username, password);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())), // Provide specific error message
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _register(context),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
