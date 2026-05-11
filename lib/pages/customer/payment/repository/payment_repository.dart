import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentRepository {
  final _supabase = Supabase.instance.client;

  Future<bool> createOrder(int totalAmount, String paymentMethod, List<dynamic> cartItems) async {
    try {
      // 1. Masukkan data ke tabel 'orders'
      final orderResponse = await _supabase.from('orders').insert({
        'total_price': totalAmount,
        
        // PENTING: Pastikan tulisan 'pending' ini SAMA PERSIS huruf besar/kecilnya
        // dengan enum 'order_status' yang Anda buat di Supabase. 
        // Kalau di DB huruf kecil, ganti jadi 'pending'.
        'status': 'pending', 
        
        // customer_id wajib diisi kalau di DB Anda tidak boleh kosong (Not Null).
        // Kalau Anda sudah punya SessionProvider, bisa dikirim ke sini nanti.
        // Untuk sekarang kita biarkan Supabase yang mengurus id dan created_at.
      }).select('id').single(); 

      final newOrderId = orderResponse['id'];

      // 2. Siapkan data untuk dimasukkan ke tabel 'order_items'
      final List<Map<String, dynamic>> orderItemsData = cartItems.map((item) {
        return {
          'order_id': newOrderId,
          'menu_id': item.menu.id, 
          'quantity': item.quantity,
          'notes': item.notes,
          // Kolom 'subtotal' dihapus karena memang tidak ada di tabel order_items Anda
        };
      }).toList();

      // 3. Masukkan semua barang ke 'order_items' sekaligus
      await _supabase.from('order_items').insert(orderItemsData);

      return true; // Sukses!
    } catch (e) {
      print('Error membuat order: $e');
      return false; // Gagal
    }
  }
}