import 'package:supabase_flutter/supabase_flutter.dart';

class MenuRepository {
  final _supabase = Supabase.instance.client;

  // 1. Fungsi mengambil daftar Menu beserta nama Kategorinya
  Future<List<Map<String, dynamic>>> fetchMenus() async {
    // Sintaks 'menu_categories(name)' adalah cara Supabase melakukan relasi (JOIN)
    // Kita filter hanya menu yang is_available = true agar yang habis tidak tampil di Customer
    final response = await _supabase
        .from('menus')
        .select('id, name, description, price, image_path, menu_categories(name)')
        .eq('is_available', true)
        .order('created_at', ascending: false);
        
    return response;
  }

  // 2. Fungsi mengambil daftar Kategori untuk Bottom Sheet Filter
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await _supabase
        .from('menu_categories')
        .select('name')
        .order('name');
        
    return response;
  }
}