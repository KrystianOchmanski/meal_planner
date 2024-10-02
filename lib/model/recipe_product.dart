import 'package:meal_planner/model/product.dart';
import 'package:meal_planner/model/recipe.dart';

class RecipeProduct {
  int? id;
  int? recipeId;
  final int productId;
  double quantity;

  RecipeProduct(
      {this.id, this.recipeId, required this.productId, required this.quantity});

  // Konwersja z mapy na obiekt
  factory RecipeProduct.fromMap(Map<String, dynamic> map) {
    return RecipeProduct(
      id: map['id'],
      recipeId: map['recipeId'],
      productId: map['productId'],
      quantity: map['quantity']
    );
  }

  // Konwersja z obiektu na mapę
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'productId': productId,
      'quantity': quantity
    };
  }
}
