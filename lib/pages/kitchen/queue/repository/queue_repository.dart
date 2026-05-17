import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class QueueRepository {
  final _supabase = Supabase.instance.client;

  // 1. Mengambil data pesanan (Status pending & cooking)
  Future<List<Map<String, dynamic>>> fetchActiveOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('id, customer_id, total_price, status, created_at, table_number, profiles(display_name), order_items(quantity, notes, menus(name))')
          .inFilter('status', ['pending', 'cooking']) // Tetap memantau kedua status ini
          .order('created_at', ascending: true); 

      return response;
    } catch (e) {
      debugPrint('Error fetchActiveOrders: $e');
      return []; 
    }
  }

  // 2. Memicu RPC Supabase untuk mulai memasak + potong stok FIFO
  Future<bool> startCookingOrder(String orderId) async {
    try {
      await _supabase.rpc('start_cooking_and_reduce_stock', params: {
        'p_order_id': orderId,
      });
      return true;
    } catch (e) {
      debugPrint('Error startCookingOrder: $e');
      return false;
    }
  }

  // 3. Mengubah status pesanan menjadi Selesai (Completed)
  Future<bool> updateOrderStatusToCompleted(String orderId) async {
    try {
      await _supabase.from('orders').update({'status': 'completed'}).eq('id', orderId);
      return true; 
    } catch (e) {
      debugPrint('Error updateOrderStatusToCompleted: $e');
      return false; 
    }
  }
}