// Jika Anda punya model Ingredient, bisa dimasukkan di sini atau di-import
class MenuIngredient {
  final String id;
  final String name;

  MenuIngredient({required this.id, required this.name});
}

class MenuModel {
  // --- Data Umum (Dipakai Customer & Kitchen) ---
  final String id;
  final String name;
  final int price;
  final String imageUrl;
  final String description;

  // --- Data Khusus Dapur (Kitchen) ---
  final String categoryId; 
  final String categoryName;
  final List<MenuIngredient> ingredients; 

  MenuModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl = '',
    this.description = '',
    
    // Beri nilai default kosong, sehingga Customer yang tidak butuh data ini tidak akan error!
    this.categoryId = '', 
    this.categoryName = '',
    this.ingredients = const [], 
  });

  // Helper formatting
  String get formattedPrice => 'Rp $price';
}