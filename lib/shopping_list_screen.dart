import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/data/database.dart';
import 'package:meal_planner/data/models/shopping_list_item_with_details.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ShoppingListScreen extends StatefulWidget {
  final List<Product> allProducts;

  const ShoppingListScreen({super.key, required this.allProducts});

  @override
  State<StatefulWidget> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final db = AppDatabase.instance;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () => _selectDateRange(context),
              child: Text(selectedDateRange == null
                  ? 'Generuj listę zakupów'
                  : 'Wybrano: ${selectedDateRange!.start} - ${selectedDateRange!.end}'),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<ShoppingListItemWithDetails>>(
              future: db.getShoppingListItemsWithDetails(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Błąd: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Brak produktów', style: TextStyle(color: Colors.grey)));
                } else {
                  final items = snapshot.data!;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.productName),
                        subtitle: Text('${item.quantity} ${item.unit}'),
                        trailing: IconButton(
                          onPressed: (){
                            _deleteProduct(item.productId);
                          },
                          icon: Icon(Icons.cancel_outlined))
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        tooltip: 'Dodaj produkt',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wybierz zakres dat'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Anuluj', style: GoogleFonts.poppins(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: null,
              child: Text('Generuj', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showAddProductDialog() {
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
                      _addProductToList(
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

  void _addProductToList(int productId, TextEditingController productQuantityController) async {
    final quantity = double.parse(productQuantityController.text.replaceAll(',', '.'));

    await db.addOrUpdateShoppingListItem(productId, quantity);

    setState(() {
      db.getShoppingListItemsWithDetails();
    });
  }

  void _deleteProduct(int productId) async {
    await db.deleteShoppingListItem(productId);
    setState(() {
      db.getShoppingListItemsWithDetails();
    });
  }
}
