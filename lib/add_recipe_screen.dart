import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/database.dart';
import 'package:meal_planner/model/recipe.dart';
import 'package:meal_planner/model/recipe_product.dart';
import 'package:intl/intl.dart';

import 'model/product.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipe;

  const AddRecipeScreen({super.key, this.recipe});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();
  int _servings = 1;
  List<RecipeProduct> _recipeProducts =  [];

  List<Product> _allProducts = [];
  NumberFormat formatter = NumberFormat('#.##');

  @override
  void initState() {
    super.initState();

    loadProductsFromDb();

    if(widget.recipe != null){
      _titleController.text = widget.recipe!.title;
      _instructionController.text = (widget.recipe!.instruction ?? '');
      _servings = widget.recipe!.servings;
      _recipeProducts = widget.recipe!.recipeProducts;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: BackButton(
          onPressed: backBtnPressed,
        ),
        centerTitle: true,
        title: Text(
            widget.recipe == null ? 'Dodaj przepis' : 'Edytuj przepis',
            style: GoogleFonts.poppins()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(onPressed: saveRecipe, icon: const Icon(Icons.check))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Tytuł',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return "Wprowadź tytuł";
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Liczba porcji'),
                    IconButton(
                        onPressed: (){
                          if(_servings > 1){
                            setState(() {
                              _servings--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle)
                    ),
                    Text(_servings.toString()),
                    IconButton(
                        onPressed: (){
                          setState(() {
                            _servings++;
                          });
                        },
                        icon: const Icon(Icons.add_circle)
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                        'Składniki',
                        style: TextStyle(fontSize: 24)
                    ),
                    IconButton(
                        onPressed: showAddProductDialog,
                        icon: const Icon(Icons.add_circle_outline))
                  ],
                ),
                if (_recipeProducts.isEmpty) const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Text('Dodaj składniki', style: TextStyle(color: Colors.grey)),
                  ),
                ) else ListView.builder(
                    shrinkWrap: true, //aby ListView zajmował minimalną ilość miejsca
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recipeProducts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                  _allProducts
                                      .firstWhere((Product product){return product.id == _recipeProducts[index].productId;})
                                      .name,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                                  '${formatter.format(_recipeProducts[index].quantity)} ${_allProducts.firstWhere((product) => product.id == _recipeProducts[index].productId).unit}')
                            ],
                        ),
                      );
                    }
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _instructionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Instrukcje...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  showAddProductDialog() {
    int? productToAddId;
    String productUnit = '';
    TextEditingController productIdController = TextEditingController();
    TextEditingController productQuantityController = TextEditingController();
    final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
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
                      if(value == null || value.isEmpty || int.tryParse(value) == null || int.tryParse(value)! < 0){
                        return 'Nieprawidłowe ID produktu';
                      }
                      return null;
                    },
                  )
                ),
                Autocomplete(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if(textEditingValue.text == ''){
                      return const Iterable<Product>.empty();
                    }
                    return _allProducts.where((product){
                      return product.name
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (Product product) => product.name,
                  fieldViewBuilder:
                      (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Wpisz nazwę produktu',
                      ),
                      validator: (value) {
                        if(value == null || value.isEmpty) {
                          return 'Nazwa produktu nie może być pusta';
                        }
                        if(!_allProducts
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
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        controller: productQuantityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*$'))
                        ],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Wprowadź ilość';
                          }
                          if (double.tryParse(value.replaceAll(',', '.')) == null ||
                              double.tryParse(value.replaceAll(',', '.'))! <= 0) {
                            return 'Ilość musi być większa od 0';
                          }
                          return null;
                        },
                      )
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
                child: const Text('Anuluj')
            ),
            TextButton(
                onPressed: () {
                  if(dialogFormKey.currentState!.validate()){
                    addRecipeProduct(productToAddId!, productQuantityController);
                  }
                },
                child: const Text('Dodaj'))
          ],
        ))
    );
  }

  void loadProductsFromDb() async {
    _allProducts = await DatabaseHelper().getProducts();
    setState(() {
    });
  }

  void addRecipeProduct(int productToAddId, TextEditingController productQuantityController) {
    double quantity = double.parse(productQuantityController.text);

    RecipeProduct newRecipeProduct = RecipeProduct(productId: productToAddId, quantity: quantity);
    setState(() {
      _recipeProducts.add(newRecipeProduct);
    });
  }

  saveRecipe() async {
    if(_formKey.currentState?.validate() ?? false){
      _formKey.currentState?.save();

      if(_recipeProducts.isEmpty){
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text('Dodaj składniki!',
                  style: TextStyle(fontSize: 16)),
                actions: [
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: const Text('OK'))
                ],
              );
            });
        return;
      }

      Recipe recipeToAdd = Recipe(title: _titleController.text, servings: _servings, recipeProducts: _recipeProducts, instruction: _instructionController.text);

      DatabaseHelper db = DatabaseHelper();
      int? result = await db.insertRecipe(recipeToAdd);

      if(result != null){
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Przepis dodany pomyślnie'))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wystąpił błąd przy dodawaniu przepisu'))
        );
      }
    }
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
}
