import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Add this import

import 'main.dart';
import 'register.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<File> _getUserFile() async {
    final directory =
        await getApplicationDocumentsDirectory(); // Use app directory
    return File('${directory.path}/users.json');
  }

  Future<Map<String, dynamic>> _loadUsers() async {
    try {
      final file = await _getUserFile();
      if (await file.exists()) {
        String contents = await file.readAsString();
        return Map<String, dynamic>.from(json.decode(contents));
      }
    } catch (e) {
      print('Error reading users file: $e');
    }
    return {};
  }

  void _login(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    final users = await _loadUsers();
    print(users);
    if (users.containsKey(username) &&
        users[username]['password'] == password) {
      int userLevel = users[username]['level'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(username: username, level: userLevel),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
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
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
