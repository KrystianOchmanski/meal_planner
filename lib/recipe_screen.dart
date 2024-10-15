import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/database.dart';
import 'add_edit_recipe_screen.dart';

class RecipeScreen extends StatefulWidget {

  const RecipeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final db = AppDatabase.instance;
  List<Recipe> _recipesList = [];
  final Set<int> _selectedRecipes = {};
  bool _isSelectionMode = false;
  bool _willSelectAll = true;

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
          if(_isSelectionMode)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Wybrano ${_selectedRecipes.length}',
                    style: TextStyle(fontSize: 18),
                  ),
                  IconButton(
                      onPressed: _deleteSelectedRecipes, 
                      icon: Icon(Icons.delete)
                  ),
                  IconButton(
                      onPressed: _selectAllRecipes, 
                      icon: Icon(Icons.select_all_sharp)
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _isSelectionMode = false;
                          _selectedRecipes.clear();
                        });
                      },
                      child: Text('Anuluj'))
                ],
              ),
            ),
          if(_recipesList.isEmpty)
            const Center(
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
                  final isSelected = _selectedRecipes.contains(recipe.id);
                  return ListTile(
                    leading: _isSelectionMode ?
                      Checkbox(
                          value: isSelected,
                          onChanged: null)
                      : null,
                    title: Text(
                      recipe.title,
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    selected: isSelected,
                    onTap: () async {
                      if(_isSelectionMode){
                        // Jeśli jesteśmy w trybie zaznaczania, zaznaczamy/odznaczamy element
                        setState(() {
                          if(isSelected){
                            _selectedRecipes.remove(recipe.id);
                            if(_selectedRecipes.isEmpty){
                              _isSelectionMode = false; // Wyłącz tryb zaznaczania jeśli nic nie jest zaznaczone
                              _willSelectAll = true;
                            }
                          } else {
                            _selectedRecipes.add(recipe.id);
                          }
                        });
                      } else {
                        // Przekierowanie do ekranu edycji przepisu i oczekiwanie na wynik
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddOrEditRecipeScreen(
                              recipe: recipe,
                            ),
                          ),
                        );
                        // Odświeżenie listy przepisów po powrocie
                        _loadRecipes();
                        setState(() {});  // Zaktualizowanie stanu, aby zaktualizować UI
                      }
                    },
                    onLongPress: () {
                      setState(() {
                        _isSelectionMode = true;
                        _willSelectAll = true;
                        _selectedRecipes.add(recipe.id);
                      });
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
    _recipesList = await db.getAllRecipes();
    setState(() {});
  }

  void _deleteSelectedRecipes() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Czy na pewno chcesz usunąć wszystkie zaznaczone przepisy?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Anuluj')
              ),
              TextButton(
                  onPressed: () async {
                    await db.deleteSelectedRecipes(_selectedRecipes.toList());
                    setState(() {
                      _loadRecipes();
                      _isSelectionMode = false;
                      _willSelectAll = true;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Usuń'))
            ],
          );
        }
    );
  }

  void _selectAllRecipes() {
    setState(() {
      if(_willSelectAll){
        for(var recipe in _recipesList){
          _selectedRecipes.add(recipe.id);
        }
        _willSelectAll = false;
      } else {
        for(var recipe in _recipesList){
          _selectedRecipes.remove(recipe.id);
        }
        _willSelectAll = true;
      }
    });
  }
}
