part of 'shopping_list_screen.dart';

abstract class ShoppingListController extends State<ShoppingListScreen>{
  final db = AppDatabase.instance;
  List<Product> _allProducts = [];

  @override
  void initState() {
    loadAllProducts();
    super.initState();
  }

  void showGenerateShoppingListDialog(){
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Wybierz zakres dat'),
                content: SizedBox(
                  width: 300,
                  height: 300,
                  child: SfDateRangePicker(
                    selectionMode: DateRangePickerSelectionMode.range,
                    backgroundColor: Colors.transparent,
                    onSelectionChanged: (args){
                      setState(() {
                        startDate = args.value.startDate;
                        endDate = args.value.endDate ?? args.value.startDate;
                      });
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Anuluj', style: GoogleFonts.poppins(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: (startDate == null) ? null : (){
                      generateShoppingList(startDate!, endDate!);
                      Navigator.pop(context);
                    },
                    child: Text('Generuj', style: GoogleFonts.poppins()),
                  ),
                ],
              );
            }
        )
    );
  }

  Future<void> loadAllProducts() async {
    var allProducts = await db.getAllProducts();
    setState(() {
      _allProducts = allProducts;
    });
  }

  void showAddProductDialog() {
    showProductDialog(
      context: context,
      allProducts: _allProducts,
      onAddProduct: addProductToList,
      dialogTitle: "Dodaj produkt",
      onCustomProductAdded: loadAllProducts
    );
  }

  void addProductToList(int productId, TextEditingController productQuantityController) async {
    final quantity = double.parse(productQuantityController.text.replaceAll(',', '.'));

    await db.addOrUpdateShoppingListItem(productId, quantity);

    setState(() {
      db.getShoppingListItemsWithDetails();
    });
  }

  void deleteProduct(int productId) async {
    await db.deleteShoppingListItem(productId);
    setState(() {
      db.getShoppingListItemsWithDetails();
    });
  }

  void deleteAllProducts() async {
    await db.deleteAllShoppingListItems();
    setState(() {
      db.getShoppingListItemsWithDetails();
    });
  }

  void showDeleteAllItemsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Czy na pewno chcesz usunąć wszystkie produkty z listy?',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Anuluj')
              ),
              ElevatedButton(
                onPressed: () {
                  deleteAllProducts();
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                ),
                child: Text('Usuń'),
              )
            ],
          );
        }
    );
  }

  Future<void> generateShoppingList(DateTime startDate, DateTime endDate) async {
    // Pobieramy wszystkie posiłki w zadanym zakresie dat
    final mealsInRange = await db.getMealsByDateRange(startDate, endDate);
    if(mealsInRange.isEmpty) {
      return;
    }

    // Tworzymy mapę produktów i ich ilości
    final Map<int, double> shoppingList = {};

    // Iterujemy przez każde danie w tabeli Meals
    for(var meal in mealsInRange){
      // Pobieramy przepis dla danego posiłku
      final recipe = await db.getRecipeById(meal.recipeId);
      // Pobieramy produkty związane z danym przepisem
      final recipeProducts = await db.getProductsForRecipe(meal.recipeId);

      // Iterujemy przez produkty w przepisie
      for(var recipeProduct in recipeProducts){
        // Obliczamy ilość produktu dla tego dania
        final productQuantity = (meal.servings / recipe!.servings) * recipeProduct.quantity;

        // Dodajemy lub aktualizujemy ilość produktu w liście zakupów
        if (shoppingList.containsKey(recipeProduct.productId)) {
          shoppingList[recipeProduct.productId] =
              shoppingList[recipeProduct.productId]! + productQuantity;
        } else {
          shoppingList[recipeProduct.productId] = productQuantity;
        }
      }
    }

    for(var item in shoppingList.entries){
      await db.addOrUpdateShoppingListItem(item.key, item.value);
    }

    // Odświeżamy widok listy
    setState(() {
      db.getShoppingListItemsWithDetails();
    });
  }
}