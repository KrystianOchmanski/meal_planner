part of 'shopping_list_screen.dart';

abstract class ShoppingListController extends State<ShoppingListScreen>{
  final db = AppDatabase.instance;

  @override
  void initState() {
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

  void showAddProductDialog() {
    int? productToAddId;
    String productUnit = '';
    TextEditingController productIdController = TextEditingController();
    TextEditingController productNameController = TextEditingController();
    TextEditingController productQuantityController = TextEditingController();
    final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();

    FocusNode quantityFocusNode = FocusNode();
    FocusNode productFocusNode = FocusNode();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Form(
                key: dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: false,
                      child: TextFormField(
                        controller: productIdController,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! < 0) {
                            return 'Nieprawidłowe ID produktu';
                          }
                          return null;
                        },
                      ),
                    ),
                    Autocomplete<Product>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<Product>.empty();
                        }
                        final input = textEditingValue.text.toLowerCase();
                        return widget.allProducts
                            .where((product) =>
                            product.name.toLowerCase().contains(input))
                            .toList()
                          ..sort((a, b) {
                            final nameA = a.name.toLowerCase();
                            final nameB = b.name.toLowerCase();
                            final startsWithA = nameA.startsWith(input) ? 0 : 1;
                            final startsWithB = nameB.startsWith(input) ? 0 : 1;
                            final result = startsWithA.compareTo(startsWithB);
                            return result == 0
                                ? nameA.compareTo(nameB)
                                : result;
                          });
                      },
                      displayStringForOption: (Product product) => product.name,
                      fieldViewBuilder:
                          (BuildContext context,
                          TextEditingController fieldTextController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted) {
                        productNameController = fieldTextController;
                        productFocusNode = fieldFocusNode;
                        return TextFormField(
                          focusNode: fieldFocusNode,
                          textCapitalization: TextCapitalization.sentences,
                          controller: fieldTextController,
                          decoration: const InputDecoration(
                            labelText: 'Wpisz nazwę produktu',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nazwa produktu nie może być pusta';
                            }
                            if (!widget.allProducts
                                .map((e) => e.name.toLowerCase())
                                .contains(value.toLowerCase())) {
                              return 'Produkt nie znajduje się na liście produktów';
                            }
                            return null;
                          },
                        );
                      },
                      onSelected: (Product product) {
                        setState(() {
                          productIdController.text = product.id.toString();
                          productToAddId = product.id;
                          productUnit = product.unit;
                        });
                        FocusScope.of(context).requestFocus(quantityFocusNode);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            focusNode: quantityFocusNode,
                            controller: productQuantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[0-9]*[.,]?[0-9]*$'))
                            ],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Wprowadź ilość';
                              }
                              if (double.tryParse(value.replaceAll(',', '.')) ==
                                  null ||
                                  double.tryParse(value.replaceAll(',', '.'))! <=
                                      0) {
                                return 'Ilość musi być większa od 0';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Zapobiegamy wprowadzeniu trzeciej cyfry po przecinku
                              if (value.contains(',') || value.contains('.')) {
                                final parts = value.split(RegExp('[.,]'));
                                if (parts.length > 1 && parts[1].length > 2) {
                                  productQuantityController.text = '${parts[0]}.${parts[1].substring(0, 2)}';
                                  productQuantityController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: productQuantityController.text.length));
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(productUnit),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Anuluj', style: GoogleFonts.poppins(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (dialogFormKey.currentState!.validate()) {
                      addProductToList(
                          productToAddId!, productQuantityController);
                      productUnit = '';
                      productIdController.clear();
                      productNameController.clear();
                      productQuantityController.clear();
                      FocusScope.of(context).requestFocus(productFocusNode);
                    }
                  },
                  child: Text('Dodaj', style: GoogleFonts.poppins()),
                ),
              ],
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          ),
        );
      },
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