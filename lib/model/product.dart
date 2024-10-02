class Product {
  int? id;
  String name;
  String category;
  String unit;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.unit
  });

  // Konwersja z mapy na obiekt
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      unit: map['unit'],
    );
  }

  // Konwersja z obiektu na mapę
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit': unit,
    };
  }
}
