import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class MenuRepository {
  final _supabase = Supabase.instance.client;

  // --- KATEGORI ---
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    // Ubah urutan berdasarkan sort_order
    return await _supabase.from('menu_categories').select().order('sort_order', ascending: true);
  }

  Future<void> addCategory(String name, int sortOrder) async {
    // Masukkan kategori baru beserta urutannya
    await _supabase.from('menu_categories').insert({
      'name': name,
      'sort_order': sortOrder, 
    });
  }

  // --- FUNGSI BARU UNTUK UPDATE URUTAN KATEGORI BATCH ---
  Future<void> updateCategoryOrders(List<Map<String, dynamic>> updates) async {
    // Kita melakukan looping update berdasarkan ID
    for (var update in updates) {
      await _supabase
          .from('menu_categories')
          .update({'sort_order': update['sort_order']})
          .eq('id', update['id']);
    }
  }

  Future<void> deleteCategory(String id) async {
    await _supabase.from('menu_categories').delete().eq('id', id);
  }

  // --- INGREDIENTS ---
  Future<List<Map<String, dynamic>>> fetchIngredients() async {
    return await _supabase.from('ingredients').select('id, name, unit').order('name');
  }

  // --- MENU ---
  Future<List<Map<String, dynamic>>> fetchMenus() async {
    return await _supabase.from('menus').select('''
      id, name, description, price, image_path, category_id,
      menu_categories(name, sort_order), 
      menu_ingredients(ingredient_id, quantity_needed, ingredients(name, unit))
    ''').order('created_at', ascending: false);
  }

  Future<void> addMenu(Map<String, dynamic> menuData, Map<String, double> ingredientQuantities) async {
    final response = await _supabase.from('menus').insert(menuData).select('id').single();
    final newMenuId = response['id'];

    if (ingredientQuantities.isNotEmpty) {
      final List<Map<String, dynamic>> relations = ingredientQuantities.entries.map((entry) {
        return {
          'menu_id': newMenuId,
          'ingredient_id': entry.key,
          'quantity_needed': entry.value,
        };
      }).toList();
      await _supabase.from('menu_ingredients').insert(relations);
    }
  }

  Future<void> updateMenu(String menuId, Map<String, dynamic> menuData, Map<String, double> ingredientQuantities) async {
    await _supabase.from('menus').update(menuData).eq('id', menuId);

    // Hapus relasi lama
    await _supabase.from('menu_ingredients').delete().eq('menu_id', menuId);

    // Masukkan relasi baru dengan takaran terupdate
    if (ingredientQuantities.isNotEmpty) {
      final List<Map<String, dynamic>> relations = ingredientQuantities.entries.map((entry) {
        return {
          'menu_id': menuId,
          'ingredient_id': entry.key,
          'quantity_needed': entry.value,
        };
      }).toList();
      await _supabase.from('menu_ingredients').insert(relations);
    }
  }

  Future<void> deleteMenu(String id) async {
    await _supabase.from('menus').delete().eq('id', id);
  }

  Future<String?> uploadMenuImage(File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      await _supabase.storage.from('menu_images').upload(
        fileName, 
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final publicUrl = _supabase.storage.from('menu_images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Error upload image: $e');
      return null;
    }
  }
}