import 'package:supabase_flutter/supabase_flutter.dart';

class MenuAllRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchMenusByCategory(
    String categoryName,
    String searchQuery,
  ) async {
    // Inner join dengan kategori
    var query = _supabase.from('menus').select('''
          id, 
          name, 
          price, 
          image_path, 
          description, 
          category_id, 
          menu_categories!inner(name),
          menu_ingredients( ingredients(id, name) ) // <--- TAMBAHKAN RELASI INI
        ''');

    // Jika masuk ke kategori spesifik (bukan "Semua")
    if (categoryName.isNotEmpty && categoryName.toLowerCase() != 'semua') {
      query = query.eq('menu_categories.name', categoryName);
    }

    // Filter pencarian jika ada teks yang diinput
    if (searchQuery.isNotEmpty) {
      query = query.ilike('name', '%$searchQuery%');
    }

    return await query;
  }
}
