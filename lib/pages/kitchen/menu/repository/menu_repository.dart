import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class MenuRepository {
  final _supabase = Supabase.instance.client;

  // --- KATEGORI ---
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    return await _supabase.from('menu_categories').select().order('name');
  }

  Future<void> addCategory(String name) async {
    await _supabase.from('menu_categories').insert({'name': name});
  }

  Future<void> deleteCategory(String id) async {
    await _supabase.from('menu_categories').delete().eq('id', id);
  }

  // --- INGREDIENTS (Bahan Baku) ---
  Future<List<Map<String, dynamic>>> fetchIngredients() async {
    return await _supabase.from('ingredients').select('id, name').order('name');
  }

  // --- MENU ---
  Future<List<Map<String, dynamic>>> fetchMenus() async {
    // Mengambil data menu sekaligus relasi kategori dan bahan bakunya
    return await _supabase.from('menus').select('''
      id, name, description, price, image_path, category_id,
      menu_categories(name),
      menu_ingredients(ingredient_id, ingredients(name))
    ''').order('created_at', ascending: false);
  }

  Future<void> addMenu(Map<String, dynamic> menuData, List<String> ingredientIds) async {
    // 1. Insert Menu dan ambil ID barunya
    final response = await _supabase.from('menus').insert(menuData).select('id').single();
    final newMenuId = response['id'];

    // 2. Insert ke tabel jembatan (menu_ingredients)
    if (ingredientIds.isNotEmpty) {
      final List<Map<String, dynamic>> relations = ingredientIds.map((ingId) {
        return {
          'menu_id': newMenuId,
          'ingredient_id': ingId,
          'quantity_needed': 1.0, // Default 1.0, nanti bisa diubah jika butuh takaran spesifik
        };
      }).toList();
      await _supabase.from('menu_ingredients').insert(relations);
    }
  }

  Future<void> updateMenu(String menuId, Map<String, dynamic> menuData, List<String> ingredientIds) async {
    // 1. Update data menu utama
    await _supabase.from('menus').update(menuData).eq('id', menuId);

    // 2. Hapus relasi bahan lama
    await _supabase.from('menu_ingredients').delete().eq('menu_id', menuId);

    // 3. Masukkan relasi bahan yang baru
    if (ingredientIds.isNotEmpty) {
      final List<Map<String, dynamic>> relations = ingredientIds.map((ingId) {
        return {'menu_id': menuId, 'ingredient_id': ingId, 'quantity_needed': 1.0};
      }).toList();
      await _supabase.from('menu_ingredients').insert(relations);
    }
  }

  Future<void> deleteMenu(String id) async {
    // Karena kita pakai ON DELETE CASCADE di SQL sebelumnya, 
    // hapus menu otomatis menghapus data di menu_ingredients.
    await _supabase.from('menus').delete().eq('id', id);
  }

  Future<String?> uploadMenuImage(File imageFile) async {
    try {
      // Bikin nama file unik berdasarkan waktu saat ini
      final fileExt = imageFile.path.split('.').last;
      final fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // Upload ke bucket 'menu_images'
      await _supabase.storage.from('menu_images').upload(
        fileName, 
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Ambil Link URL Publik-nya
      final publicUrl = _supabase.storage.from('menu_images').getPublicUrl(fileName);
      return publicUrl;
      
    } catch (e) {
      // Kalau error, cetak di console dan kembalikan null
      print('Error upload image: $e');
      return null;
    }
  }
}