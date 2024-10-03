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
  List<Recipe> _recipesList = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if(_recipesList.isEmpty) const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Dodaj pierwszy przepis', style: TextStyle(color: Colors.grey)),
            ),
          )
          else Expanded(
            child: ListView.builder(
                itemCount: _recipesList.length,
                itemBuilder: (context, index) {
                  final recipe = _recipesList[index];
                  return ListTile(
                    title: Text(recipe.title),
                    onTap: () async {
                      // Przekierowanie do ekranu edycji przepisu i oczekiwanie na wynik
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddOrEditRecipeScreen(
                            database: widget.database,
                            recipe: recipe,
                          ),
                        ),
                      );
                      // Odświeżenie listy przepisów po powrocie
                      _loadRecipes();
                      setState(() {});  // Zaktualizowanie stanu, aby zaktualizować UI
                    },
                  );
                }),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Przekierowanie do AddOrEditRecipeScreen i oczekiwanie na wynik
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddOrEditRecipeScreen(
                database: widget.database,
                recipe: null,
              ),
            ),
          );
          // Odświeżenie listy przepisów po powrocie
          _loadRecipes();
          setState(() {});  // Zaktualizowanie stanu, aby zaktualizować UI
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _loadRecipes() async {
    _recipesList = await widget.database.getAllRecipes();
    setState(() {});
  }
}
