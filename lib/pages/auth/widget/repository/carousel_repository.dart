import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CarouselRepository {
  final _supabase = Supabase.instance.client;

  Future<List<String>> fetchActiveBanners() async {
    try {
      // Ambil hanya banner yang aktif, urutkan dari yang terbaru, batasi maksimal 3
      final response = await _supabase
          .from('banners')
          .select('image_url')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(3);

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