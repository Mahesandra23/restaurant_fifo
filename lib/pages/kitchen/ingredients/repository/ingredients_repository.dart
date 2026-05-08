import 'package:supabase_flutter/supabase_flutter.dart';

class IngredientsRepository {
  final _supabase = Supabase.instance.client;

  // 1. READ: Mengambil semua data bahan baku
  Future<List<Map<String, dynamic>>> fetchIngredients() async {
    final response = await _supabase
        .from('ingredients')
        .select()
        .order('category', ascending: true) // Urutkan berdasarkan Kategori
        .order('name', ascending: true);    // Lalu urutkan berdasarkan Nama
    return response;
  }

  // 2. CREATE: Menambahkan bahan baku baru
  Future<void> addIngredient(String name, String category) async {
    await _supabase.from('ingredients').insert({
      'name': name,
      'category': category,
      // 'code': bisa ditambahkan jika Anda menggunakan format kode khusus
    });
  }

  // 3. DELETE: Menghapus bahan baku berdasarkan UUID
  Future<void> deleteIngredient(String id) async {
    await _supabase.from('ingredients').delete().eq('id', id);
  }
}