import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class MenuDetailRepository {
  final _supabase = Supabase.instance.client;

  // Mengambil data menu ter-update dari database berdasarkan ID
  Future<Map<String, dynamic>?> fetchMenuDetail(String menuId) async {
    try {
      final response = await _supabase
          .from('menus')
          .select('id, name, description, price, image_path, is_available')
          .eq('id', menuId)
          .single();
      return response;
    } catch (e) {
      debugPrint('Error fetchMenuDetail: $e');
      return null;
    }
  }
}