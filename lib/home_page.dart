import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/database.dart';
import 'package:meal_planner/meal_screen.dart';
import 'package:meal_planner/recipe_screen.dart';
import 'package:meal_planner/shopping_list_screen.dart';

class HomePage extends StatefulWidget {
  final String title;
  final AppDatabase database;

  const HomePage({super.key, required this.title, required this.database});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppDatabase database;
  late List<Widget> screens;
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    database = widget.database;
    screens = [
      MealScreen(),
      RecipeScreen(database: database),
      ShoppingListScreen(database: database)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: GoogleFonts.poppins()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
          // selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.black38,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() {
                _currentIndex = index;
              }),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.restaurant), label: "Posiłki"),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book), label: "Przepisy"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket), label: "Lista zakupów"),
          ]),
    );
  }
}
