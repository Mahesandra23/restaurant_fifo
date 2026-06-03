import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class HistoryRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchFullOrderHistory(String customerId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            id, 
            total_price, 
            status, 
            created_at, 
            order_items(quantity, menus(name))
          ''')
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
          
      return response;
    } catch (e) {
      debugPrint('Error fetchFullOrderHistory: $e');
      return [];
    }
  }
}