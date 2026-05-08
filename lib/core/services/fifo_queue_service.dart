import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'array_fifo_queue.dart';

class FifoQueueService {
  final _supabase = Supabase.instance.client;
  
  // Instansiasi Array Queue dengan kapasitas 20
  final ArrayFifoQueue<Map<String, dynamic>> orderQueue = ArrayFifoQueue<Map<String, dynamic>>(20);

  // 1. Inisialisasi awal saat halaman dibuka
  Future<void> loadInitialQueue() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('id, customer_id, total_price, status, created_at, order_items(quantity, notes, menus(name))')
          .inFilter('status', ['pending', 'cooking'])
          .order('created_at', ascending: true); // Tetap di-sort dari DB agar urutan waktu valid
          
      // Kosongkan queue jika ada sisa (reset)
      while (!orderQueue.isEmpty()) {
        orderQueue.dequeue();
      }

      // Memasukkan data ke dalam Array Queue menggunakan ENQUEUE
      for (var order in response) {
        orderQueue.enqueue(order);
      }
      
    } catch (e) {
      debugPrint('Error load queue: $e');
    }
  }

  // 2. Saat ada pesanan baru masuk (dari kasir/customer)
  // Anda panggil ini untuk memasukkan data ke State memori tanpa harus refresh API
  void addNewOrderToQueue(Map<String, dynamic> newOrder) {
    bool success = orderQueue.enqueue(newOrder);
    if (!success) {
      // Handle jika array ukuran 20 sudah penuh
      debugPrint("Kapasitas dapur penuh!");
    }
  }

  // 3. Saat Koki menyelesaikan pesanan paling depan
  Future<Map<String, dynamic>?> finishFrontOrder() async {
    if (orderQueue.isEmpty()) return null;

    // Ambil order paling depan
    final frontOrder = orderQueue.peek();
    final orderId = frontOrder!['id'];

    try {
      // A. Update status di Supabase menjadi completed
      await _supabase.from('orders').update({'status': 'completed'}).eq('id', orderId);

      // B. DEQUEUE dari Array (Hapus dari posisi Front, pointer bergeser)
      final finishedOrder = orderQueue.dequeue();
      
      // TODO: Panggil pengurang stok (InventoryService) di sini
      
      return finishedOrder;
    } catch (e) {
      debugPrint('Error finishFrontOrder: $e');
      return null;
    }
  }

  // Mendapatkan data untuk ditampilkan di ListView
  List<Map<String, dynamic>> getCurrentQueue() {
    return orderQueue.toList();
  }
}