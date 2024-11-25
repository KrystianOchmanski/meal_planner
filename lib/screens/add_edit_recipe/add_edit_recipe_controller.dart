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

  showAddProductDialog() {
    int? productToAddId;
    String productUnit = '';
    TextEditingController productIdController = TextEditingController();
    TextEditingController productNameController = TextEditingController();
    TextEditingController productQuantityController = TextEditingController();
    final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();

    FocusNode quantityFocusNode = FocusNode();
    FocusNode productFocusNode = FocusNode();

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
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
                              if (value == null || value.isEmpty ||
                                  int.tryParse(value) == null || int.tryParse(
                                  value)! < 0) {
                                return 'Nieprawidłowe ID produktu';
                              }
                              return null;
                            },
                          )
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
                              // Produkty zaczynające się od wprowadzonego tekstu mają priorytet
                              final startsWithA = nameA.startsWith(input) ? 0 : 1;
                              final startsWithB = nameB.startsWith(input) ? 0 : 1;
                              // Najpierw sortuj według tego, czy zaczynają się od wprowadzonego tekstu
                              final result = startsWithA.compareTo(startsWithB);
                              // Jeśli oba mają ten sam wynik, sortuj alfabetycznie
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
                            // Ustawienie FocusNode
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
                              // FocusNode dla ilości
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
                                    double.tryParse(
                                        value.replaceAll(',', '.'))! <= 0) {
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
                          addRecipeProduct(
                              productToAddId!, productQuantityController);

                          // Resetowanie formularza i przywracanie kursora na Autocomplete
                          productUnit = '';
                          productIdController.clear();
                          productNameController.clear();
                          productQuantityController.clear();

                          FocusScope.of(context).requestFocus(
                              productFocusNode); // Przeniesienie kursora na Autocomplete
                        }
                      },
                      child: Text('Dodaj', style: GoogleFonts.poppins())
                  )
                ],
              );
            }
        ));
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