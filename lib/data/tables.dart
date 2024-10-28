import 'package:drift/drift.dart';

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

class Meals extends Table {
  IntColumn get id => integer().autoIncrement()(); // Primary Key
  DateTimeColumn get date => dateTime()();
  IntColumn get mealType => intEnum<MealType>()();
  IntColumn get recipeId =>
      integer().references(Recipes, #id)(); // Foreign Key
  IntColumn get servings => integer()();

  // Założenie klucza na kolumny date oraz mealType, aby zapewnić unikalność
  @override
  List<Set<Column>> get uniqueKeys => [
    {date, mealType}
  ];
}

enum MealType{
  breakfast,
  brunch,
  lunch,
  snack,
  dinner
}