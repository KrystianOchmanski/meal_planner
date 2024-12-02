import 'package:drift/drift.dart' hide Column;
import 'package:meal_planner/commons.dart';

class RecipeSelectionDialog extends StatefulWidget {
  final DateTime selectedDay;
  final MealType mealType;
  final VoidCallback onMealAdded;
  final MealWithRecipe? meal;

  const RecipeSelectionDialog({
    super.key,
    required this.selectedDay,
    required this.mealType,
    required this.onMealAdded,
    this.meal
  });

  @override
  State<RecipeSelectionDialog> createState() => _RecipeSelectionDialogState();
}

class _RecipeSelectionDialogState extends State<RecipeSelectionDialog> {
  List<Recipe>? _allRecipes;
  List<Recipe>? _filteredRecipes;
  final TextEditingController _filterController = TextEditingController();
  bool _isLoading = true;
  Recipe? selectedRecipe;
  int servings = 1;

  @override
  void initState() {
    super.initState();
    _loadAllRecipes();

    print(selectedRecipe);
  }

  Future<void> _loadAllRecipes() async {
    final recipes = await AppDatabase.instance.getAllRecipes();
    if (mounted) {
      setState(() {
        _allRecipes = recipes;
        _filteredRecipes = recipes;
        selectedRecipe = _allRecipes?.firstWhereOrNull((recipe) => recipe.id == widget.meal?.recipeId);
        _isLoading = false;
      });
    }
  }

  void _filterRecipes(String query) {
    setState(() {
      _filteredRecipes = _allRecipes?.where((recipe) =>
          recipe.title.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  Future<void> _saveRecipe(DateTime date, MealType mealType, int recipeId, int servings) async {
    await AppDatabase.instance.insertMeal(MealsCompanion(
      date: Value(date),
      mealType: Value(mealType),
      recipeId: Value(recipeId),
      servings: Value(servings),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Wybierz przepis', style: GoogleFonts.poppins()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Liczba porcji'),
                IconButton(
                  onPressed: servings > 1 ? () => setState(() => servings--) : null,
                  icon: const Icon(Icons.remove_circle),
                ),
                Text(servings.toString()),
                IconButton(
                  onPressed: () => setState(() => servings++),
                  icon: const Icon(Icons.add_circle),
                ),
              ],
            ),
            TextField(
              controller: _filterController,
              decoration: InputDecoration(
                labelText: 'Filtruj przepisy',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterRecipes,
            ),
            const SizedBox(height: 10),
            _isLoading
                ? CircularProgressIndicator()
                : SizedBox(
              height: 200,
              child: SingleChildScrollView(
                child: Column(
                  children: _filteredRecipes!.map((recipe) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selectedRecipe == recipe ? Colors.lightGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          recipe.title,
                          style: GoogleFonts.poppins(
                            color: selectedRecipe == recipe ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: selectedRecipe == recipe,
                        onTap: () => setState(() => selectedRecipe = recipe),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Anuluj', style: GoogleFonts.poppins(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: selectedRecipe == null
              ? null
              : () {
            _saveRecipe(widget.selectedDay, widget.mealType, selectedRecipe!.id, servings);
            widget.onMealAdded();
            Navigator.of(context).pop();
          },
          child: Text('Dodaj', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}

