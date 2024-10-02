import 'package:meal_planner/model/recipe_product.dart';

class Recipe {
  int? id;
  String title;
  int servings;
  List<RecipeProduct> recipeProducts;
  String? instruction;

  Recipe({
    this.id,
    required this.title,
    required this.servings,
    required this.recipeProducts,
    this.instruction,
  });

  // Konwersja z mapy na obiekt
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      servings: map['servings'],
      recipeProducts: map['recipeProducts'],
      instruction: map['instruction'],
    );
  }

  // Konwersja z obiektu na mapę
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'servings': servings,
      'recipeProducts': recipeProducts,
      'instruction': instruction,
    };
  }
}
