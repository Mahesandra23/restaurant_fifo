import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BannerRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAllBanners() async {
    try {
      // Tarik data banner beserta nama admin yang membuatnya (Join tabel)
      return await _supabase
          .from('banners')
          .select('*, profiles:created_by(display_name)')
          .order('created_at', ascending: false);
    } catch (e) {
      debugPrint('Error fetchAllBanners: $e');
      return [];
    }
  }

  Future<void> addBanner({
    required String title,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      final String? userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      // 1. Buat nama file unik untuk menghindari bentrok
      final String uniquePath = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // 2. Upload file ke Supabase Storage (Bucket: 'banner')
      await _supabase.storage.from('banner').uploadBinary(uniquePath, fileBytes);

      // 3. Ambil URL Publik dari gambar yang baru diupload
      final String imageUrl = _supabase.storage.from('banner').getPublicUrl(uniquePath);

      // 4. Simpan data ke tabel database
      await _supabase.from('banners').insert({
        'title': title,
        'image_url': imageUrl,
        'image_path': uniquePath, // Simpan path agar mudah dihapus nanti
        'is_active': true,
        'created_by': userId,
      });
    } catch (e) {
      debugPrint('Error addBanner: $e');
      rethrow;
    }
  }

  Future<void> toggleBannerStatus(String id, bool currentStatus) async {
    try {
      await _supabase.from('banners').update({'is_active': !currentStatus}).eq('id', id);
    } catch (e) {
      debugPrint('Error toggleBannerStatus: $e');
    }
  }

  Future<void> deleteBanner(String id, String imagePath) async {
    try {
      // 1. Hapus gambar fisik dari Storage terlebih dahulu
      await _supabase.storage.from('banner').remove([imagePath]);
      // 2. Hapus baris data dari tabel Database
      await _supabase.from('banners').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleteBanner: $e');
    }
  }
}