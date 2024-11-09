import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/data/database.dart';
import 'package:meal_planner/data/models/shopping_list_item_with_details.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  final db = AppDatabase.instance;
  DateTimeRange? selectedDateRange;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 10),
          FutureBuilder<List<ShoppingListItemWithDetails>>(
            future: db.getShoppingListItemsWithDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
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
                    );
                  },
                );
              }
            },
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () => _selectDateRange(context),
                child: Text(selectedDateRange == null
                    ? 'Generuj listę zakupów'
                    : 'Wybrano: ${selectedDateRange!.start} - ${selectedDateRange!.end}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
