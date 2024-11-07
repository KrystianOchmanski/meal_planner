import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:meal_planner/data/tables.dart';

import '../models/meal_with_recipe.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Products, Recipes, RecipeProducts, Meals])
class AppDatabase extends _$AppDatabase {
  // 1. Tworzenie prywatnego konstruktora
  AppDatabase._privateConstructor() : super(_openConnection());

  // 2. Singleton
  static final AppDatabase _instance = AppDatabase._privateConstructor();

  // 3. Getter, który zwraca instancję
  static AppDatabase get instance => _instance;

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'meal_planner_database');
  }

  // CRUD
  //  PRODUCTS
  //    Create
  Future<int> insertProduct(ProductsCompanion product) {
    return into(products).insert(product);
  }

//      Read
  Future<List<Product>> getAllProducts() {
    return select(products).get();
  }

  Future<Product?> getProductById(int id) {
    return (select(products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

//      Update
  Future<bool> updateProduct(Product product) {
    return update(products).replace(product);
  }

//      Delete
  Future<int> deleteProduct(int id) {
    return (delete(products)..where((tbl) => tbl.id.equals(id))).go();
  }

  //  RECIPES
  //    Create
  Future<int> insertRecipe(RecipesCompanion recipe) {
    return into(recipes).insert(recipe);
  }

//      Read
  Future<List<Recipe>> getAllRecipes() {
    return select(recipes).get();
  }

  Future<Recipe?> getRecipeById(int id) {
    return (select(recipes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

//      Update
  Future<bool> updateRecipe(Recipe recipe) {
    return update(recipes).replace(recipe);
  }

//      Delete
  Future<int> deleteRecipe(int id) {
    return (delete(recipes)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> deleteSelectedRecipes(List<int> selectedRecipeIds) async {
    if (selectedRecipeIds.isNotEmpty) {
      await (delete(recipes)
        ..where((tbl) => tbl.id.isIn(selectedRecipeIds))
      ).go();
    }
  }

  //  RECIPE_PRODUCTS
  //    Create
  Future<int> insertRecipeProduct(RecipeProductsCompanion recipeProduct) {
    return into(recipeProducts).insert(recipeProduct);
  }

//      Read
  Future<List<RecipeProduct>> getAllRecipeProducts() {
    return select(recipeProducts).get();
  }

  Future<List<RecipeProduct>> getProductsForRecipe(int recipeId) {
    return (select(recipeProducts)..where((tbl) => tbl.recipeId.equals(recipeId))).get();
  }

  Future<RecipeProduct?> getRecipeProductById(int id) {
    return (select(recipeProducts)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

//      Update
  Future<bool> updateRecipeProduct(RecipeProduct recipeProduct) {
    return update(recipeProducts).replace(recipeProduct);
  }

//      Delete
  Future<int> deleteRecipeProduct(int id) {
    return (delete(recipeProducts)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> deleteRecipeProductsByRecipeId(int recipeId){
    return (delete(recipeProducts)..where((tbl) => tbl.recipeId.equals(recipeId))).go();
  }

  //  MEALS
  //    Create
  Future<int> insertMeal(MealsCompanion meal) async {
    return await into(meals).insert(meal);
  }

  //    Read
  Future<List<Meal>> getAllMeals() async {
    return await select(meals).get();
  }

  Future<List<Meal>> getMealsByDate(DateTime date) async {
    return await (select(meals)..where((tbl) => tbl.date.equals(date))).get();
  }

  Future<List<MealWithRecipe>> getMealsWithRecipeTitleForDate(DateTime selectedDate) {
    // Ustawienie zakresu na dany dzień
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

    final query = select(meals).join([
      innerJoin(recipes, recipes.id.equalsExp(meals.recipeId))
    ])
      ..where(meals.date.isBetweenValues(startOfDay, endOfDay));

    return query.map((row) {
      final meal = row.readTable(meals);
      final recipe = row.readTable(recipes);

      return MealWithRecipe(
        id: meal.id,
        date: meal.date,
        mealType: meal.mealType,
        servings: meal.servings,
        recipeTitle: recipe.title,
      );
    }).get();
  }

  //    Update
  Future<bool> updateMeal(Meal meal) async {
    return await update(meals).replace(meal);
  }

  // Delete
  Future<int> deleteMeal(int id) async {
    return await (delete(meals)..where((tbl) => tbl.id.equals(id))).go();
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
