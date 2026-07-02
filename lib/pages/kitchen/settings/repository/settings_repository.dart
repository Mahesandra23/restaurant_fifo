import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsRepository {
  final _supabase = Supabase.instance.client;

  // 1. Ambil Total Pendapatan Hari Ini
  Future<double> fetchDailyRevenue() async {
    try {
      final now = DateTime.now();

      final startOfDay = DateTime(
        now.year,
        now.month,
        now.day,
      ).toUtc().toIso8601String();
      final endOfDay = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      ).toUtc().toIso8601String();

      // Query pesanan yang statusnya 'completed' pada hari ini
      final response = await _supabase
          .from('orders')
          .select('total_price')
          .eq(
            'status',
            'completed',
          )
          .gte('created_at', startOfDay)
          .lte('created_at', endOfDay);


      double total = 0;
      for (var row in response) {
        total += (row['total_price'] as num).toDouble();
      }
      return total;
    } catch (e) {
      debugPrint('Error fetchDailyRevenue: $e');
      return 0;
    }
  }

  // 2. Ambil 3 Riwayat Pesanan Terakhir (Preview)
  Future<List<Map<String, dynamic>>> fetchRecentOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false)
          .limit(3); // Hanya ambil 3 untuk preview
      return response;
    } catch (e) {
      debugPrint('Error fetchRecentOrders: $e');
      return [];
    }
  }

  // 3. Fungsi Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
