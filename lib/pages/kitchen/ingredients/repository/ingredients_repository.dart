import 'package:supabase_flutter/supabase_flutter.dart';

class IngredientsRepository {
  final _supabase = Supabase.instance.client;

  // 1. READ: Tarik data Ingredients BESERTA total stoknya dari tabel 'stocks'
  Future<List<Map<String, dynamic>>> fetchIngredients() async {
    // Kita gunakan relasi Supabase untuk menarik data stocks sekaligus
    final response = await _supabase
        .from('ingredients')
        .select('*, stocks(current_quantity, unit)') // Tarik relasi dari gambar ERD Anda
        .order('category', ascending: true) 
        .order('name', ascending: true);    
    return response;
  }

  // 2. CREATE: Simpan Master Bahan + Stok Awal FIFO
  Future<void> addIngredient({
    required String name,
    required String category,
    required String unit,
    required double currentStock,
    required double reorderPoint,
    required String abc,
    required String hml,
    required String sde,
    required String fsn,
  }) async {
    // A. Insert ke tabel Master Ingredients
    final ingredientResponse = await _supabase.from('ingredients').insert({
      'name': name,
      'category': category,
      'unit': unit,
      'reorder_point': reorderPoint,
      'abc_class': abc,
      'hml_class': hml,
      'sde_class': sde,
      'fsn_class': fsn,
    }).select('id').single(); // Ambil ID yang baru dibuat

    final String newIngredientId = ingredientResponse['id'];

    // B. Jika user menginput stok awal > 0, masukkan ke tabel Stocks (Sebagai Batch Pertama FIFO)
    if (currentStock > 0) {
      await _supabase.from('stocks').insert({
        'ingredient_id': newIngredientId,
        'current_quantity': currentStock,
        'unit': unit,
        'entry_date': DateTime.now().toIso8601String(), // Waktu masuk barang
        // expiry_date bisa dikosongkan atau diatur nanti
      });
    }
  }

  Future<void> deleteIngredient(String id) async {
    await _supabase.from('ingredients').delete().eq('id', id);
  }
}