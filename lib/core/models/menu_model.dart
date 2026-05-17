// menu_model.dart atau di file model kamu

class MenuIngredient {
  final String id;
  final String name;
  final String unit; // Tambahkan ini
  final double quantityNeeded; // Tambahkan ini

  MenuIngredient({
    required this.id,
    required this.name,
    this.unit = '',
    this.quantityNeeded = 0.0,
  });
}

class MenuModel {
  final String id;
  final String name;
  final int price;
  final String imageUrl;
  final String description;
  final String categoryId; 
  final String categoryName;
  final List<MenuIngredient> ingredients; 

  MenuModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl = '',
    this.description = '',
    this.categoryId = '', 
    this.categoryName = '',
    this.ingredients = const [], 
  });

  String get formattedPrice => 'Rp $price';
}