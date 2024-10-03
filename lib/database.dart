import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()(); // Primary Key
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get category => text().withLength(min: 1, max: 255)();
  TextColumn get unit => text().withLength(min: 1, max: 50)();
}

class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()(); // Primary Key
  TextColumn get title => text().withLength(min: 1, max: 255)();
  IntColumn get servings => integer()();
  TextColumn get instruction => text().nullable()();
}

class RecipeProducts extends Table {
  IntColumn get id => integer().autoIncrement()(); // Primary Key
  IntColumn get recipeId => 
      integer().references(Recipes, #id)(); // Foreign Key
  IntColumn get productId =>
      integer().references(Products, #id)(); // Foreign Key
  RealColumn get quantity => real()();
}

@DriftDatabase(tables: [Products, Recipes, RecipeProducts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'my_database');
  }

  // CRUD
  //  Products
  //    CREATE
  Future<int> insertProduct(ProductsCompanion product) {
    return into(products).insert(product);
  }

//      READ
  Future<List<Product>> getAllProducts() {
    return select(products).get();
  }

  Future<Product?> getProductById(int id) {
    return (select(products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

//      UPDATE
  Future<bool> updateProduct(Product product) {
    return update(products).replace(product);
  }

//      DELETE
  Future<int> deleteProduct(int id) {
    return (delete(products)..where((tbl) => tbl.id.equals(id))).go();
  }

  //  Recipes
  //    CREATE
  Future<int> insertRecipe(RecipesCompanion recipe) {
    return into(recipes).insert(recipe);
  }

//      READ
  Future<List<Recipe>> getAllRecipes() {
    return select(recipes).get();
  }

  Future<Recipe?> getRecipeById(int id) {
    return (select(recipes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

//      UPDATE
  Future<bool> updateRecipe(Recipe recipe) {
    return update(recipes).replace(recipe);
  }

//      DELETE
  Future<int> deleteRecipe(int id) {
    return (delete(recipes)..where((tbl) => tbl.id.equals(id))).go();
  }

  //  RecipeProducts
  //    CREATE
  Future<int> insertRecipeProduct(RecipeProductsCompanion recipeProduct) {
    return into(recipeProducts).insert(recipeProduct);
  }

//      READ
  Future<List<RecipeProduct>> getAllRecipeProducts() {
    return select(recipeProducts).get();
  }

  Future<List<RecipeProduct>> getProductsForRecipe(int recipeId) {
    return (select(recipeProducts)..where((tbl) => tbl.recipeId.equals(recipeId))).get();
  }

  Future<RecipeProduct?> getRecipeProductById(int id) {
    return (select(recipeProducts)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

//      UPDATE
  Future<bool> updateRecipeProduct(RecipeProduct recipeProduct) {
    return update(recipeProducts).replace(recipeProduct);
  }

//      DELETE
  Future<int> deleteRecipeProduct(int id) {
    return (delete(recipeProducts)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> deleteRecipeProductsByRecipeId(int recipeId){
    return (delete(recipeProducts)..where((tbl) => tbl.recipeId.equals(recipeId))).go();
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // Sprawdzenie, czy baza danych została właśnie utworzona
      if(details.wasCreated){
        final initialProducts = [
          ProductsCompanion(name: Value('Ziemniaki'), category: Value('Warzywa'), unit: Value('g')),
          ProductsCompanion(name: Value('Pomidor'), category: Value('Warzywa'), unit: Value('szt')),
          ProductsCompanion(name: Value('Ogórek'), category: Value('Warzywa'), unit: Value('szt')),
          ProductsCompanion(name: Value('Marchew'), category: Value('Warzywa'), unit: Value('g')),
          ProductsCompanion(name: Value('Cebula'), category: Value('Warzywa'), unit: Value('g')),
          ProductsCompanion(name: Value('Czosnek'), category: Value('Warzywa'), unit: Value('szt')),
          ProductsCompanion(name: Value('Papryka'), category: Value('Warzywa'), unit: Value('szt')),
          ProductsCompanion(name: Value('Brokuł'), category: Value('Warzywa'), unit: Value('szt')),
          ProductsCompanion(name: Value('Kalafior'), category: Value('Warzywa'), unit: Value('szt')),
          ProductsCompanion(name: Value('Szpinak'), category: Value('Warzywa'), unit: Value('g')),
          ProductsCompanion(name: Value('Sałata'), category: Value('Warzywa'), unit: Value('szt')),
          ProductsCompanion(name: Value('Kapusta'), category: Value('Warzywa'), unit: Value('g')),
          ProductsCompanion(name: Value('Dynia'), category: Value('Warzywa'), unit: Value('g')),
          ProductsCompanion(name: Value('Bakłażan'), category: Value('Warzywa'), unit: Value('szt')),
          ProductsCompanion(name: Value('Cukinia'), category: Value('Warzywa'), unit: Value('g')),
          ProductsCompanion(name: Value('Rzodkiewka'), category: Value('Warzywa'), unit: Value('g')),
          ProductsCompanion(name: Value('Por'), category: Value('Warzywa'), unit: Value('szt')),
          ProductsCompanion(name: Value('Burak'), category: Value('Warzywa'), unit: Value('g')),
          ProductsCompanion(name: Value('Banany'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Jabłka'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Pomarańcze'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Cytryny'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Truskawki'), category: Value('Owoce'), unit: Value('g')),
          ProductsCompanion(name: Value('Gruszki'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Winogrona'), category: Value('Owoce'), unit: Value('g')),
          ProductsCompanion(name: Value('Brzoskwinie'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Morele'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Śliwki'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Maliny'), category: Value('Owoce'), unit: Value('g')),
          ProductsCompanion(name: Value('Jagody'), category: Value('Owoce'), unit: Value('g')),
          ProductsCompanion(name: Value('Ananas'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Mango'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Arbuz'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Melon'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Kiwi'), category: Value('Owoce'), unit: Value('szt')),
          ProductsCompanion(name: Value('Mleko'), category: Value('Nabiał'), unit: Value('szt')),
          ProductsCompanion(name: Value('Masło'), category: Value('Nabiał'), unit: Value('g')),
          ProductsCompanion(name: Value('Ser żółty'), category: Value('Nabiał'), unit: Value('g')),
          ProductsCompanion(name: Value('Ser biały'), category: Value('Nabiał'), unit: Value('g')),
          ProductsCompanion(name: Value('Jogurt'), category: Value('Nabiał'), unit: Value('g')),
          ProductsCompanion(name: Value('Śmietana'), category: Value('Nabiał'), unit: Value('g')),
          ProductsCompanion(name: Value('Twaróg'), category: Value('Nabiał'), unit: Value('g')),
          ProductsCompanion(name: Value('Serek wiejski'), category: Value('Nabiał'), unit: Value('g')),
          ProductsCompanion(name: Value('Kefir'), category: Value('Nabiał'), unit: Value('g')),
          ProductsCompanion(name: Value('Maślanka'), category: Value('Nabiał'), unit: Value('g')),
          ProductsCompanion(name: Value('Kurczak'), category: Value('Mięso'), unit: Value('g')),
          ProductsCompanion(name: Value('Wołowina'), category: Value('Mięso'), unit: Value('g')),
          ProductsCompanion(name: Value('Wieprzowina'), category: Value('Mięso'), unit: Value('g')),
          ProductsCompanion(name: Value('Indyk'), category: Value('Mięso'), unit: Value('g')),
          ProductsCompanion(name: Value('Kiełbasa'), category: Value('Mięso'), unit: Value('g')),
          ProductsCompanion(name: Value('Szynka'), category: Value('Mięso'), unit: Value('g')),
          ProductsCompanion(name: Value('Boczek'), category: Value('Mięso'), unit: Value('g')),
          ProductsCompanion(name: Value('Ryby'), category: Value('Ryby'), unit: Value('g')),
          ProductsCompanion(name: Value('Łosoś'), category: Value('Ryby'), unit: Value('g')),
          ProductsCompanion(name: Value('Tuńczyk'), category: Value('Ryby'), unit: Value('g')),
          ProductsCompanion(name: Value('Makrela'), category: Value('Ryby'), unit: Value('g')),
          ProductsCompanion(name: Value('Śledź'), category: Value('Ryby'), unit: Value('g')),
          ProductsCompanion(name: Value('Chleb'), category: Value('Pieczywo'), unit: Value('szt')),
          ProductsCompanion(name: Value('Bułki'), category: Value('Pieczywo'), unit: Value('szt')),
          ProductsCompanion(name: Value('Bagietka'), category: Value('Pieczywo'), unit: Value('szt')),
          ProductsCompanion(name: Value('Tortilla'), category: Value('Pieczywo'), unit: Value('szt')),
          ProductsCompanion(name: Value('Mąka'), category: Value('Produkty zbożowe'), unit: Value('g')),
          ProductsCompanion(name: Value('Ryż'), category: Value('Produkty zbożowe'), unit: Value('g')),
          ProductsCompanion(name: Value('Makaron'), category: Value('Produkty zbożowe'), unit: Value('g')),
          ProductsCompanion(name: Value('Kasza'), category: Value('Produkty zbożowe'), unit: Value('g')),
          ProductsCompanion(name: Value('Płatki owsiane'), category: Value('Produkty zbożowe'), unit: Value('g')),
          ProductsCompanion(name: Value('Woda'), category: Value('Napoje'), unit: Value('g')),
          ProductsCompanion(name: Value('Sok pomarańczowy'), category: Value('Napoje'), unit: Value('g')),
          ProductsCompanion(name: Value('Sok jabłkowy'), category: Value('Napoje'), unit: Value('g')),
          ProductsCompanion(name: Value('Herbata'), category: Value('Napoje'), unit: Value('g')),
          ProductsCompanion(name: Value('Kawa'), category: Value('Napoje'), unit: Value('g')),
          ProductsCompanion(name: Value('Cola'), category: Value('Napoje'), unit: Value('szt')),
          ProductsCompanion(name: Value('Piwo'), category: Value('Napoje'), unit: Value('szt')),
          ProductsCompanion(name: Value('Wino'), category: Value('Napoje'), unit: Value('szt')),
          ProductsCompanion(name: Value('Sól'), category: Value('Przyprawy'), unit: Value('g')),
          ProductsCompanion(name: Value('Pieprz'), category: Value('Przyprawy'), unit: Value('g')),
          ProductsCompanion(name: Value('Papryka słodka'), category: Value('Przyprawy'), unit: Value('g')),
          ProductsCompanion(name: Value('Cukier'), category: Value('Dodatki'), unit: Value('g')),
          ProductsCompanion(name: Value('Miód'), category: Value('Dodatki'), unit: Value('g')),
          ProductsCompanion(name: Value('Oliwa z oliwek'), category: Value('Dodatki'), unit: Value('g')),
          ProductsCompanion(name: Value('Ocet balsamiczny'), category: Value('Dodatki'), unit: Value('g')),
          ProductsCompanion(name: Value('Musztarda'), category: Value('Dodatki'), unit: Value('g')),
          ProductsCompanion(name: Value('Majonez'), category: Value('Dodatki'), unit: Value('g')),
          ProductsCompanion(name: Value('Ketchup'), category: Value('Dodatki'), unit: Value('g')),
          ProductsCompanion(name: Value('Papier toaletowy'), category: Value('Domowe'), unit: Value('szt')),
          ProductsCompanion(name: Value('Mydło'), category: Value('Domowe'), unit: Value('szt')),
          ProductsCompanion(name: Value('Szampon'), category: Value('Domowe'), unit: Value('szt')),
          ProductsCompanion(name: Value('Pasta do zębów'), category: Value('Domowe'), unit: Value('szt')),
          ProductsCompanion(name: Value('Płyn do naczyń'), category: Value('Domowe'), unit: Value('szt')),
          ProductsCompanion(name: Value('Proszek do prania'), category: Value('Domowe'), unit: Value('szt')),
          ProductsCompanion(name: Value('Ręczniki papierowe'), category: Value('Domowe'), unit: Value('szt')),
          ProductsCompanion(name: Value('Worki na śmieci'), category: Value('Domowe'), unit: Value('szt')),
          ProductsCompanion(name: Value('Chusteczki higieniczne'), category: Value('Domowe'), unit: Value('szt')),
          ProductsCompanion(name: Value('Ściereczki kuchenne'), category: Value('Domowe'), unit: Value('szt')),
          ProductsCompanion(name: Value('Płyn do okien'), category: Value('Domowe'), unit: Value('szt')),
        ];

        // Wstawianie produktów do bazy danych
        for (var product in initialProducts) {
          await into(products).insert(product);
        }
      }
    }
  );
}
