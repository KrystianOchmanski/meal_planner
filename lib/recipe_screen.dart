import 'package:flutter/material.dart';
import 'package:meal_planner/database.dart';
import 'add_edit_recipe_screen.dart';

class RecipeScreen extends StatefulWidget {
  final AppDatabase database;

  const RecipeScreen({super.key, required this.database});

  @override
  State<StatefulWidget> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddOrEditRecipeScreen(database: widget.database, recipe: null))
                );
              },
              child: Icon(Icons.add)),
    );
  }
}
