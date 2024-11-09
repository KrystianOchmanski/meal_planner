import 'package:flutter/material.dart';
import 'package:meal_planner/data/database.dart';
import 'package:meal_planner/data/models/shopping_list_item_with_details.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  final db = AppDatabase.instance;

  ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista Produktów'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<ShoppingListItemWithDetails>>(
            future: db.getShoppingListItemsWithDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Błąd: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('Brak produktów');
              } else {
                final items = snapshot.data!;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.productName),
                      subtitle: Text('${item.quantity} ${item.unit}'),
                    );
                  },
                );
              }
            },
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                  onPressed: null, 
                  child: Text('Generuj')),
            ),
          )
        ],
      ),
    );
  }
}
