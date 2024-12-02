import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:meal_planner/data/tables.dart';

import 'DTOs/meal_with_recipe.dart';
import 'DTOs/shopping_list_item_with_details.dart';
import 'initialData.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Products, Recipes, RecipeProducts, Meals, ShoppingListItems])
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
  Future<int> insertProduct(ProductsCompanion product) {
    return into(products).insert(product);
  }
  Future<List<Product>> getAllProducts() {
    return select(products).get();
  }
  Future<Product?> getProductById(int id) {
    return (select(products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }
  Future<bool> updateProduct(Product product) {
    return update(products).replace(product);
  }
  Future<int> deleteProduct(int id) {
    return (delete(products)..where((tbl) => tbl.id.equals(id))).go();
  }

  // SHOPPINGLISTITEMS
  Future<int> insertShoppingListItem(int id, double quantity){
    return into(shoppingListItems).insert(
      ShoppingListItemsCompanion(
        productId: Value(id),
        quantity: Value(quantity)
      )
    );
  }
  Future<List<ShoppingListItem>> getAllShoppingListItems(){
    return select(shoppingListItems).get();
  }
  Future<ShoppingListItem?> getShoppingListItemByProductId(int id){
    return (select(shoppingListItems)..where((tbl) => tbl.productId.equals(id))).getSingleOrNull();
  }
  Future<List<ShoppingListItemWithDetails>> getShoppingListItemsWithDetails() async {
    final query = select(shoppingListItems).join([
      innerJoin(products, products.id.equalsExp(shoppingListItems.productId)),
    ]);

    final result = await query.map((row) {
      return ShoppingListItemWithDetails(
        productId: row.readTable(shoppingListItems).productId,
        quantity: row.readTable(shoppingListItems).quantity,
        productName: row.readTable(products).name,
        category: row.readTable(products).category,
        unit: row.readTable(products).unit,
      );
    }).get();

    return result;
  }
  Future<void> updateShoppingListItemQuantity(int productId, double newQuantity) async {
    await (update(shoppingListItems)
      ..where((item) => item.productId.equals(productId)))
        .write(ShoppingListItemsCompanion(quantity: Value(newQuantity)));
  }
  Future<void> addOrUpdateShoppingListItem(int productId, double quantity) async {
    // Sprawdź, czy produkt o danym ID już istnieje na liście zakupów
    final existingItem = await getShoppingListItemByProductId(productId);

    if (existingItem != null) {
      // Jeśli produkt już istnieje, zwiększ jego ilość
      final newQuantity = existingItem.quantity + quantity;
      await updateShoppingListItemQuantity(productId, newQuantity);
    } else {
      // Jeśli produkt nie istnieje, dodaj nowy produkt do bazy
      await insertShoppingListItem(productId, quantity);
    }
  }
  Future<int> deleteShoppingListItem(int id){
    return (delete(shoppingListItems)..where((tbl) => tbl.productId.equals(id))).go();
  }
  Future<void> deleteAllShoppingListItems() async {
    await (delete(shoppingListItems)).go();
  }


  //  RECIPES
  Future<int> insertRecipe(RecipesCompanion recipe) {
    return into(recipes).insert(recipe);
  }
  Future<List<Recipe>> getAllRecipes() {
    return select(recipes).get();
  }
  Future<Recipe?> getRecipeById(int id) {
    return (select(recipes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }
  Future<bool> updateRecipe(Recipe recipe) {
    return update(recipes).replace(recipe);
  }
  Future<int> deleteRecipe(int id) async {
    // Usuń posiłki powiązane z danym recipe
    await (delete(meals)..where((tbl) => tbl.recipeId.equals(id))).go();
    return (delete(recipes)..where((tbl) => tbl.id.equals(id))).go();
  }
  Future<void> deleteSelectedRecipes(List<int> selectedRecipeIds) async {
    if (selectedRecipeIds.isNotEmpty) {
      await (delete(meals)
        ..where((tbl) => tbl.recipeId.isIn(selectedRecipeIds))
      ).go();
      await (delete(recipes)
        ..where((tbl) => tbl.id.isIn(selectedRecipeIds))
      ).go();
    }
  }

  //  RECIPE_PRODUCTS
  Future<int> insertRecipeProduct(RecipeProductsCompanion recipeProduct) {
    return into(recipeProducts).insert(recipeProduct);
  }
  Future<List<RecipeProduct>> getAllRecipeProducts() {
    return select(recipeProducts).get();
  }
  Future<List<RecipeProduct>> getProductsForRecipe(int recipeId) {
    return (select(recipeProducts)..where((tbl) => tbl.recipeId.equals(recipeId))).get();
  }
  Future<RecipeProduct?> getRecipeProductById(int id) {
    return (select(recipeProducts)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }
  Future<bool> updateRecipeProduct(RecipeProduct recipeProduct) {
    return update(recipeProducts).replace(recipeProduct);
  }
  Future<int> deleteRecipeProduct(int id) {
    return (delete(recipeProducts)..where((tbl) => tbl.id.equals(id))).go();
  }
  Future<int> deleteRecipeProductsByRecipeId(int recipeId){
    return (delete(recipeProducts)..where((tbl) => tbl.recipeId.equals(recipeId))).go();
  }

  //  MEALS
  Future<int> insertMeal(MealsCompanion meal) async {
    return await into(meals).insert(meal);
  }
  Future<List<Meal>> getAllMeals() async {
    return await select(meals).get();
  }
  Future<List<Meal>> getMealsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return await (select(meals)..where((tbl) => tbl.date.isBetweenValues(startOfDay, endOfDay))).get();
  }
  Future<List<Meal>> getMealsByDateRange(DateTime startDate, DateTime endDate) async {
    endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return await (select(meals)..where((tbl) => tbl.date.isBetweenValues(startDate, endDate))).get();
  }
  Future<List<MealWithRecipe>> getMealsWithRecipeTitleForDate(DateTime selectedDate) {
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
        recipeId: recipe.id,
        date: meal.date,
        mealType: meal.mealType,
        servings: meal.servings,
        recipeTitle: recipe.title,
      );
    }).get();
  }
  Future<bool> updateMeal(Meal meal) async {
    return await update(meals).replace(meal);
  }
  Future<int> deleteMeal(int id) async {
    return await (delete(meals)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // Sprawdzenie, czy baza danych została właśnie utworzona
      if(details.wasCreated){
        // Wstawianie produktów do bazy danych
        for (var product in initialProducts) {
          await into(products).insert(product);
        }
      }
    }
  );
}
