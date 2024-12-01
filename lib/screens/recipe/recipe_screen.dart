import 'package:meal_planner/commons.dart';

part 'recipe_controller.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends RecipeController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_isSelectionMode)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Wybrano ${_selectedRecipes.length}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _deleteSelectedRecipes,
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                  IconButton(
                    onPressed: _selectAllRecipes,
                    icon: Icon(Icons.select_all_sharp, color: Colors.green),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSelectionMode = false;
                        _selectedRecipes.clear();
                      });
                    },
                    child: Text('Anuluj', style: TextStyle(color: Colors.grey)),
                  )
                ],
              ),
            ),
          if (_recipesList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Dodaj pierwszy przepis',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _recipesList.length,
                itemBuilder: (context, index) {
                  final recipe = _recipesList[index];
                  final isSelected = _selectedRecipes.contains(recipe.id);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: _isSelectionMode
                          ? Checkbox(
                        value: isSelected,
                        onChanged: null,
                        activeColor: Colors.green,
                      )
                          : Icon(Icons.food_bank, color: Colors.green),
                      title: Text(
                        recipe.title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        "Kliknij, aby edytować",
                        style: TextStyle(color: Colors.grey),
                      ),
                      selected: isSelected,
                      tileColor: isSelected ? Colors.green[50] : null,
                      onTap: () async {
                        if (_isSelectionMode) {
                          setState(() {
                            if (isSelected) {
                              _selectedRecipes.remove(recipe.id);
                              if (_selectedRecipes.isEmpty) {
                                _isSelectionMode = false;
                                _willSelectAll = true;
                              }
                            } else {
                              _selectedRecipes.add(recipe.id);
                            }
                          });
                        } else {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddOrEditRecipeScreen(
                                recipe: recipe,
                              ),
                            ),
                          );
                          _loadRecipes();
                          setState(() {});
                        }
                      },
                      onLongPress: () {
                        setState(() {
                          _isSelectionMode = true;
                          _willSelectAll = true;
                          _selectedRecipes.add(recipe.id);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addRecipeFAB',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddOrEditRecipeScreen(recipe: null),
            ),
          );
          _loadRecipes();
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
