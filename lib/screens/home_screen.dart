import 'package:meal_planner/commons.dart';

part 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends HomeController {
  @override
  Widget build(BuildContext context) {
    screens = [
      MealScreen(),
      RecipeScreen(allProducts: _allProducts),
      ShoppingListScreen(allProducts: _allProducts)
    ];

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
