part of 'home_screen.dart';

abstract class HomeController extends State<HomeScreen>{
  late List<Widget> screens;
  var _currentIndex = 0;
  List<Product> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
    screens = [
      MealScreen(),
      RecipeScreen(allProducts: _allProducts),
      ShoppingListScreen(allProducts: _allProducts)
    ];
  }

  void _loadAllProducts() async {
    var products = await AppDatabase.instance.getAllProducts();
    setState(() {
      _allProducts = products;
    });
  }
}