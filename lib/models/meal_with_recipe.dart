import '../data/tables.dart';

class MealWithRecipe {
  final int id;
  final DateTime date;
  final MealType mealType;
  final int servings;
  final String recipeTitle;

  MealWithRecipe({
    required this.id,
    required this.date,
    required this.mealType,
    required this.servings,
    required this.recipeTitle,
  });
}
