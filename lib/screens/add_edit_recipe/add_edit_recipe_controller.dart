part of 'add_edit_recipe_screen.dart';

abstract class AddEditRecipeController extends State<AddOrEditRecipeScreen>{
  final db = AppDatabase.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();
  int _servings = 1;
  List<RecipeProductsCompanion> _recipeProductsCompanion = [];

  NumberFormat formatter = NumberFormat('#.##');

  @override
  void initState() {
    super.initState();

    if(widget.recipe != null){
      _titleController.text = widget.recipe!.title;
      _instructionController.text = (widget.recipe!.instruction ?? '');
      _servings = widget.recipe!.servings;
      _loadRecipeProducts();
    }
  }

  void showAddProductDialog() {
    showProductDialog(
      context: context,
      allProducts: widget.allProducts,
      onAddProduct: addRecipeProduct,
      dialogTitle: 'Dodaj produkt',
    );
  }

  void addRecipeProduct(int productToAddId, TextEditingController productQuantityController) {
    final quantity = double.parse(productQuantityController.text.replaceAll(',', '.'));

    RecipeProductsCompanion newRecipeProduct = RecipeProductsCompanion(
        productId: Value(productToAddId),
        quantity: Value(quantity));
    setState(() {
      _recipeProductsCompanion.add(newRecipeProduct);
    });
  }

  void backBtnPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text("Czy na pewno chcesz anulować dodawanie przepisu?",
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Nie"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("Tak"),
            ),
          ],
        );
      },
    );
  }

  void _loadRecipeProducts() async {
    final products = await db.getProductsForRecipe(widget.recipe!.id);
    setState(() {
      _recipeProductsCompanion = products.map((product) {
        return RecipeProductsCompanion(
          productId: Value(product.productId),
          quantity: Value(product.quantity),
        );
      }).toList();
    });
  }


  Future<void> saveRecipe() async {
    // walidacja formularza
    if(!_formKey.currentState!.validate()){
      return;
    }

    if(_recipeProductsCompanion.isNotEmpty){
      //dodanie nowego przepisu
      if(widget.recipe == null) {
        final addedRecipeId = await db.insertRecipe(RecipesCompanion(
            title: Value(_titleController.text),
            servings: Value(_servings),
            instruction: Value(_instructionController.text)
        ));

        // dodanie powiązanych składników
        await saveRecipeProducts(addedRecipeId);

        Navigator.pop(context);
      }
      // edycja istniejącego przepisu
      else {
        await db.updateRecipe(
            widget.recipe!.copyWith(
                title: _titleController.text,
                servings: _servings,
                instruction: Value(_instructionController.text)
            )
        );

        // usunięcie starych składników i zapisanie nowych
        await db.deleteRecipeProductsByRecipeId(widget.recipe!.id);
        await saveRecipeProducts(widget.recipe!.id);

        Navigator.pop(context);
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Dodaj składniki!'),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('OK'))
              ],
            );
          });
    }
  }

  Future<void> saveRecipeProducts(int addedRecipeId) async {
    for(var product in _recipeProductsCompanion){
      await db.insertRecipeProduct(RecipeProductsCompanion(
          recipeId: Value(addedRecipeId),
          productId: product.productId,
          quantity: product.quantity
      ));
    }
  }

  deleteRecipeProduct(int index) {
    setState(() {
      _recipeProductsCompanion.removeAt(index);
    });
  }

  deleteRecipe(Recipe recipe) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Czy na pewno chcesz usunąć przepis?'),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Anuluj')
              ),
              TextButton(
                  onPressed: () async {
                    await db.deleteRecipe(recipe.id);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Usuń'))
            ],
          );
        });
  }
}