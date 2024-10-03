import 'package:flutter/material.dart';
import 'package:meal_planner/database.dart';

class ShoppingListScreen extends StatefulWidget {
  final AppDatabase database;

  const ShoppingListScreen({super.key, required this.database});

  @override
  State<StatefulWidget> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductListScreen(database: widget.database),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  final AppDatabase database;

  const ProductListScreen({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista Produktów'),
      ),
      body: FutureBuilder<List<Product>>(
        future: database.select(database.products).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Błąd: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('Brak produktów');
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('${product.category} ${product.unit}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
