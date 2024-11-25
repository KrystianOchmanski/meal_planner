part of 'recipe_screen.dart';

abstract class RecipeController extends State<RecipeScreen>{
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