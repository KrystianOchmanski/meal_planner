import 'package:meal_planner/commons.dart';

class Strings {
  static const String title = "Meal Planner";
}

void showProductDialog({
  required BuildContext context,
  required List<Product> allProducts,
  required void Function(int productId, TextEditingController quantityController) onAddProduct,
  String? dialogTitle,
  String? initialProductUnit,
}) {
  int? productToAddId;
  String productUnit = initialProductUnit ?? '';
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
            title: Text(dialogTitle ?? '', style: GoogleFonts.poppins()),
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
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Product>.empty();
                      }
                      final input = textEditingValue.text.toLowerCase();
                      return allProducts
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
                    fieldViewBuilder: (context, fieldTextController,
                        fieldFocusNode, onFieldSubmitted) {
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
                          if (!allProducts
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
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
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
                            if (value.contains(',') || value.contains('.')) {
                              final parts = value.split(RegExp('[.,]'));
                              if (parts.length > 1 && parts[1].length > 2) {
                                productQuantityController.text =
                                '${parts[0]}.${parts[1].substring(0, 2)}';
                                productQuantityController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: productQuantityController.text.length));
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(productUnit),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                Text('Anuluj', style: GoogleFonts.poppins(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (dialogFormKey.currentState!.validate()) {
                    onAddProduct(productToAddId!, productQuantityController);
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
