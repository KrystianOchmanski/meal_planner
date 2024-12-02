import 'package:meal_planner/commons.dart';

class MealWithRecipe {
  final int id;
  final int recipeId;
  final DateTime date;
  final MealType mealType;
  final int servings;
  final String recipeTitle;

  MealWithRecipe({
    required this.id,
    required this.recipeId,
    required this.date,
    required this.mealType,
    required this.servings,
    required this.recipeTitle,
  });
}
