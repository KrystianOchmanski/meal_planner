import 'package:meal_planner/model/product.dart';
import 'package:meal_planner/model/recipe.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'meal_planner_database.db');
    deleteDatabase(path); //usuwanie bazy (tylko do testów)

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NUll,
        category TEXT NOT NULL,
        unit TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Recipes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        servings INTEGER NOT NULL,
        instruction TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE RecipeProducts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        FOREIGN KEY(recipe_id) REFERENCES Recipes(id) ON DELETE CASCADE,
        FOREIGN KEY(product_id) REFERENCES Products(id) ON DELETE CASCADE
      )
    ''');

    await insertStandardProducts(db);
  }

  Future<int?> insertProduct(Product product) async {
    try {
      Database db = await database;
      return await db.insert('Products', product.toMap());
    } catch (e) {
      print('Error inserting product: $e');
      return null;
    }
  }

  Future<int?> insertRecipe(Recipe recipe) async {
    try {
      Database db = await database;
      return await db.insert('Recipes', recipe.toMap());
    } catch (e) {
      print('Error inserting recipe: $e');
      return null;
    }
  }

  Future<List<Product>> getProducts() async {
    List<Product> products = [];
    try {
      Database db = await database;
      var productMaps = await db.query('Products');
      for (var prodMap in productMaps) {
        products.add(Product.fromMap(prodMap));
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
    return products;
  }

  Future<List<Recipe>> getRecipes() async {
    List<Recipe> recipes = [];
    try {
      Database db = await database;
      var recipeMaps = await db.query('Recipes');
      for (var recMap in recipeMaps) {
        recipes.add(Recipe.fromMap(recMap));
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
    return recipes;
  }


  Future<void> insertStandardProducts(Database db) async {
    List<Product> standardProducts = [
      Product(name: 'Ziemniaki', category: 'Warzywa', unit: 'g'),
      Product(name: 'Pomidor', category: 'Warzywa', unit: 'szt'),
      Product(name: 'Ogórek', category: 'Warzywa', unit: 'szt'),
      Product(name: 'Marchew', category: 'Warzywa', unit: 'g'),
      Product(name: 'Cebula', category: 'Warzywa', unit: 'g'),
      Product(name: 'Czosnek', category: 'Warzywa', unit: 'szt'),
      Product(name: 'Papryka', category: 'Warzywa', unit: 'szt'),
      Product(name: 'Brokuł', category: 'Warzywa', unit: 'szt'),
      Product(name: 'Kalafior', category: 'Warzywa', unit: 'szt'),
      Product(name: 'Szpinak', category: 'Warzywa', unit: 'g'),
      Product(name: 'Sałata', category: 'Warzywa', unit: 'szt'),
      Product(name: 'Kapusta', category: 'Warzywa', unit: 'g'),
      Product(name: 'Dynia', category: 'Warzywa', unit: 'g'),
      Product(name: 'Bakłażan', category: 'Warzywa', unit: 'szt'),
      Product(name: 'Cukinia', category: 'Warzywa', unit: 'g'),
      Product(name: 'Rzodkiewka', category: 'Warzywa', unit: 'g'),
      Product(name: 'Por', category: 'Warzywa', unit: 'szt'),
      Product(name: 'Burak', category: 'Warzywa', unit: 'g'),
      Product(name: 'Banany', category: 'Owoce', unit: 'szt'),
      Product(name: 'Jabłka', category: 'Owoce', unit: 'szt'),
      Product(name: 'Pomarańcze', category: 'Owoce', unit: 'szt'),
      Product(name: 'Cytryny', category: 'Owoce', unit: 'szt'),
      Product(name: 'Truskawki', category: 'Owoce', unit: 'g'),
      Product(name: 'Gruszki', category: 'Owoce', unit: 'szt'),
      Product(name: 'Winogrona', category: 'Owoce', unit: 'g'),
      Product(name: 'Brzoskwinie', category: 'Owoce', unit: 'szt'),
      Product(name: 'Morele', category: 'Owoce', unit: 'szt'),
      Product(name: 'Śliwki', category: 'Owoce', unit: 'szt'),
      Product(name: 'Maliny', category: 'Owoce', unit: 'g'),
      Product(name: 'Jagody', category: 'Owoce', unit: 'g'),
      Product(name: 'Ananas', category: 'Owoce', unit: 'szt'),
      Product(name: 'Mango', category: 'Owoce', unit: 'szt'),
      Product(name: 'Arbuz', category: 'Owoce', unit: 'szt'),
      Product(name: 'Melon', category: 'Owoce', unit: 'szt'),
      Product(name: 'Kiwi', category: 'Owoce', unit: 'szt'),
      Product(name: 'Mleko', category: 'Nabiał', unit: 'szt'),
      Product(name: 'Masło', category: 'Nabiał', unit: 'g'),
      Product(name: 'Ser żółty', category: 'Nabiał', unit: 'g'),
      Product(name: 'Ser biały', category: 'Nabiał', unit: 'g'),
      Product(name: 'Jogurt', category: 'Nabiał', unit: 'g'),
      Product(name: 'Śmietana', category: 'Nabiał', unit: 'g'),
      Product(name: 'Twaróg', category: 'Nabiał', unit: 'g'),
      Product(name: 'Serek wiejski', category: 'Nabiał', unit: 'g'),
      Product(name: 'Kefir', category: 'Nabiał', unit: 'g'),
      Product(name: 'Maślanka', category: 'Nabiał', unit: 'g'),
      Product(name: 'Kurczak', category: 'Mięso', unit: 'g'),
      Product(name: 'Wołowina', category: 'Mięso', unit: 'g'),
      Product(name: 'Wieprzowina', category: 'Mięso', unit: 'g'),
      Product(name: 'Indyk', category: 'Mięso', unit: 'g'),
      Product(name: 'Kiełbasa', category: 'Mięso', unit: 'g'),
      Product(name: 'Szynka', category: 'Mięso', unit: 'g'),
      Product(name: 'Boczek', category: 'Mięso', unit: 'g'),
      Product(name: 'Ryby', category: 'Ryby', unit: 'g'),
      Product(name: 'Łosoś', category: 'Ryby', unit: 'g'),
      Product(name: 'Tuńczyk', category: 'Ryby', unit: 'g'),
      Product(name: 'Makrela', category: 'Ryby', unit: 'g'),
      Product(name: 'Śledź', category: 'Ryby', unit: 'g'),
      Product(name: 'Chleb', category: 'Pieczywo', unit: 'szt'),
      Product(name: 'Bułki', category: 'Pieczywo', unit: 'szt'),
      Product(name: 'Bagietka', category: 'Pieczywo', unit: 'szt'),
      Product(name: 'Tortilla', category: 'Pieczywo', unit: 'szt'),
      Product(name: 'Mąka', category: 'Produkty zbożowe', unit: 'g'),
      Product(name: 'Ryż', category: 'Produkty zbożowe', unit: 'g'),
      Product(name: 'Makaron', category: 'Produkty zbożowe', unit: 'g'),
      Product(name: 'Kasza', category: 'Produkty zbożowe', unit: 'g'),
      Product(name: 'Płatki owsiane', category: 'Produkty zbożowe', unit: 'g'),
      Product(name: 'Woda', category: 'Napoje', unit: 'g'),
      Product(name: 'Sok pomarańczowy', category: 'Napoje', unit: 'g'),
      Product(name: 'Sok jabłkowy', category: 'Napoje', unit: 'g'),
      Product(name: 'Herbata', category: 'Napoje', unit: 'g'),
      Product(name: 'Kawa', category: 'Napoje', unit: 'g'),
      Product(name: 'Cola', category: 'Napoje', unit: 'szt'),
      Product(name: 'Piwo', category: 'Napoje', unit: 'szt'),
      Product(name: 'Wino', category: 'Napoje', unit: 'szt'),
      Product(name: 'Sól', category: 'Przyprawy', unit: 'g'),
      Product(name: 'Pieprz', category: 'Przyprawy', unit: 'g'),
      Product(name: 'Papryka słodka', category: 'Przyprawy', unit: 'g'),
      Product(name: 'Cukier', category: 'Dodatki', unit: 'g'),
      Product(name: 'Miód', category: 'Dodatki', unit: 'g'),
      Product(name: 'Oliwa z oliwek', category: 'Dodatki', unit: 'g'),
      Product(name: 'Ocet balsamiczny', category: 'Dodatki', unit: 'g'),
      Product(name: 'Musztarda', category: 'Dodatki', unit: 'g'),
      Product(name: 'Majonez', category: 'Dodatki', unit: 'g'),
      Product(name: 'Ketchup', category: 'Dodatki', unit: 'g'),
      Product(name: 'Papier toaletowy', category: 'Domowe', unit: 'szt'),
      Product(name: 'Mydło', category: 'Domowe', unit: 'szt'),
      Product(name: 'Szampon', category: 'Domowe', unit: 'szt'),
      Product(name: 'Pasta do zębów', category: 'Domowe', unit: 'szt'),
      Product(name: 'Płyn do naczyń', category: 'Domowe', unit: 'szt'),
      Product(name: 'Proszek do prania', category: 'Domowe', unit: 'szt'),
      Product(name: 'Ręczniki papierowe', category: 'Domowe', unit: 'szt'),
      Product(name: 'Worki na śmieci', category: 'Domowe', unit: 'szt'),
      Product(name: 'Chusteczki higieniczne', category: 'Domowe', unit: 'szt'),
      Product(name: 'Ściereczki kuchenne', category: 'Domowe', unit: 'szt'),
      Product(name: 'Płyn do okien', category: 'Domowe', unit: 'szt'),

    ];

    for (var product in standardProducts) {
      await db.insert('Products', product.toMap());
    }
  }
}
