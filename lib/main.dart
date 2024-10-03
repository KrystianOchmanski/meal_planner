import 'package:flutter/material.dart';
import 'package:meal_planner/database.dart';
import 'package:meal_planner/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();

  runApp(MyApp(database: db));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp({super.key, required this.database});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      home: HomePage(title: Strings.title, database: database),
    );
  }
}

class Strings {
  static const String title = "Meal Planner";
}
