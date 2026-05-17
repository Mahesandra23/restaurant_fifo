import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchHistory({required int year, int? month}) async {
    try {
      // Build start and end dates based on year and month
      DateTime startDate;
      DateTime endDate;

      if (month != null && month > 0) {
        startDate = DateTime(year, month, 1);
        // Get the last day of the month by going to day 0 of the next month
        endDate = DateTime(year, month + 1, 0, 23, 59, 59);
      } else {
        startDate = DateTime(year, 1, 1);
        endDate = DateTime(year, 12, 31, 23, 59, 59);
      }

      final response = await _supabase
          .from('orders')
          .select()
          .eq('status', 'completed')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      debugPrint('Error fetchHistory: $e');
      return [];
    }
  }
}