import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuMainRepository {
  final _supabase = Supabase.instance.client;

  // 1. Fungsi mengambil daftar Menu beserta nama Kategorinya
  Future<List<Map<String, dynamic>>> fetchMenus() async {
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

  // 3. FUNGSI BARU: Mengambil maksimal 3 Banner Aktif
  Future<List<String>> fetchActiveBanners() async {
    try {
      final response = await _supabase
          .from('banners')
          .select('image_url')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(3); // Batasi maksimal 3 gambar

      List<String> imageUrls = [];
      for (var row in response) {
        imageUrls.add(row['image_url'] as String);
      }
      return imageUrls;
    } catch (e) {
      debugPrint('Error fetchActiveBanners: $e');
      return [];
    }
  }
}