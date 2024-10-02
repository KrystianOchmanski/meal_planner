import 'package:flutter/material.dart';
import 'package:meal_planner/database.dart';
import 'package:meal_planner/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper().database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      home: const HomePage(title: Strings.title),
    );
  }
}

class Strings {
  static const String title = "Meal Planner";
}
