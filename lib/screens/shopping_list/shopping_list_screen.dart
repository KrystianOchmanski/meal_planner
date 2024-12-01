import 'package:meal_planner/commons.dart';

part 'shopping_list_controller.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<StatefulWidget> createState() => ShoppingListScreenState();
}

class ShoppingListScreenState extends ShoppingListController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(flex: 1),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: showGenerateShoppingListDialog,
                  child: Text('Generuj listę zakupów'),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: showDeleteAllItemsDialog,
                    icon: Icon(Icons.delete),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<ShoppingListItemWithDetails>>(
              future: db.getShoppingListItemsWithDetails(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Błąd: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                        'Brak produktów', style: TextStyle(color: Colors.grey)),
                  );
                } else {
                  final items = snapshot.data!;
                  final groupedItems = groupBy(items, (item) => item.category);

                  return ListView.builder(
                    itemCount: groupedItems.length,
                    itemBuilder: (context, index) {
                      final category = groupedItems.keys.elementAt(index);
                      final products = groupedItems[category]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                          ),
                          ...products.map((item) {
                            return ListTile(
                              title: Text(item.productName),
                              subtitle: Text(
                                '${item.quantity == item.quantity.toInt() ? item
                                    .quantity.toInt() : item.quantity
                                    .toStringAsFixed(2)} ${item.unit}',
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  deleteProduct(item.productId);
                                },
                                icon: Icon(Icons.cancel_outlined),
                              ),
                            );
                          }),
                        ],
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
        onPressed: showAddProductDialog,
        tooltip: 'Dodaj produkt',
        child: Icon(Icons.add),
      ),
    );
  }
}