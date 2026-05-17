import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentRepository {
  final _supabase = Supabase.instance.client;

  // 1. UBAH int customerid MENJADI String customerId
  Future<bool> createOrder(int totalAmount, String paymentMethod, List<dynamic> cartItems, String tableNumber, String customerId) async {
    try {
      final orderResponse = await _supabase.from('orders').insert({
        'total_price': totalAmount,
        'status': 'pending', 
        'table_number': tableNumber,
        'customer_id': customerId, // Sekarang aman karena String
      }).select('id').single(); 

      final newOrderId = orderResponse['id'];

      final List<Map<String, dynamic>> orderItemsData = cartItems.map((item) {
        return {
          'order_id': newOrderId,
          'menu_id': item.menu.id, 
          'quantity': item.quantity,
          'notes': item.notes,
          // 2. HAPUS BARIS 'table_number' DI SINI! (Sudah saya hapus di contoh ini)
        };
      }).toList();

      await _supabase.from('order_items').insert(orderItemsData);

      return true;
    } catch (e) {
      print('Error membuat order: $e');
      return false; 
    }
  }
}