//in main.dart write thi
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sql_learning_app_final/login.dart';

void main() {
  databaseFactory = databaseFactoryFfiWeb;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQL Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  final String username;
  final int level;

  MainPage({required this.username, required this.level});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Database database;
  late List<String> questions;
  late List<String> correctAnswers;
  int currentQuestionIndex = 0;
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _loadQuestions();
  }

  Future<void> _initializeDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'sakila.db'),
      onCreate: (db, version) {
        // Create the database schema if needed
      },
      version: 1,
    );
  }

  void _loadQuestions() {
    // Simulate loading questions based on the level
    questions = [
      'SELECT first_name FROM actor WHERE actor_id = 1;',
      'SELECT title FROM film WHERE film_id = 1;',
      'SELECT name FROM category WHERE category_id = 1;'
    ];
    correctAnswers = [
      'Penelope', // Replace with actual expected answers
      'Academy Dinosaur',
      'Action'
    ];
  }

  Future<void> _updateUserLevel() async {
    final file = File('./users.json');
    if (await file.exists()) {
      String contents = await file.readAsString();
      Map<String, dynamic> users =
          Map<String, dynamic>.from(json.decode(contents));
      if (users.containsKey(widget.username)) {
        users[widget.username]['level'] = widget.level + 1;
        await file.writeAsString(json.encode(users));
      }
    }
  }

  Future<void> _checkAnswer(BuildContext context) async {
    String userAnswer = _answerController.text;
    String correctAnswer = correctAnswers[currentQuestionIndex];

    try {
      List<Map<String, dynamic>> result = await database.rawQuery(userAnswer);

      if (result.isNotEmpty &&
          result[0].values.first.toString() == correctAnswer) {
        setState(() {
          currentQuestionIndex++;
          _answerController.clear();
          if (currentQuestionIndex >= questions.length) {
            // Progress to the next level
            currentQuestionIndex = 0;
            _updateUserLevel();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Level up!')),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect answer')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error executing query')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main Page')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Level: ${widget.level}'),
            SizedBox(height: 20),
            if (currentQuestionIndex < questions.length)
              Text(questions[currentQuestionIndex]),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(labelText: 'Your SQL query'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _checkAnswer(context),
              child: Text('Submit Answer'),
            ),
          ],
        ),
      ),
    );
  }
}
