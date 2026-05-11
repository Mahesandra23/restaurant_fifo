import 'package:flutter/material.dart';
import 'package:restaurant_fifo/core/services/fifo_queue_service.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';

// --- MODEL DATA (Tetap Sama) ---
class OrderItem {
  final String name;
  final int quantity;
  final String notes;

  OrderItem({required this.name, required this.quantity, this.notes = ''});
}

class OrderQueue {
  final String id;
  final String customerName;
  final String orderTime;
  final List<OrderItem> items;

  OrderQueue({
    required this.id,
    required this.customerName,
    required this.orderTime,
    required this.items,
  });
}

// --- VIEW MODEL ---
class QueueViewModel extends BaseViewModel {
  bool isLoading = false;
  
  // Panggil Service Database + Algoritma Anda
  final FifoQueueService _queueService = FifoQueueService();
  
  List<OrderQueue> activeOrders = [];

  @override
  void init() {
    super.init();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    // 1. Ambil data dari Supabase dan masukkan ke dalam Array FIFO
    await _queueService.loadInitialQueue();
    
    // 2. Terjemahkan Array FIFO menjadi List untuk UI
    _mapQueueToUI();

    isLoading = false;
    notifyListeners(); 
  }

  // Fungsi Penerjemah (Data Supabase -> Data UI)
  void _mapQueueToUI() {
    final rawQueue = _queueService.getCurrentQueue();

    activeOrders = rawQueue.map((orderMap) {
      // Ambil daftar item makanan
      final rawItems = orderMap['order_items'] as List<dynamic>? ?? [];
      final parsedItems = rawItems.map((item) {
        return OrderItem(
          name: item['menus']['name'] ?? 'Unknown Menu',
          quantity: item['quantity'] ?? 1,
          notes: item['notes'] ?? '',
        );
      }).toList();

      // Format Jam (Contoh: 14:30)
      final createdAt = orderMap['created_at'];
      String timeString = '';
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt).toLocal();
        timeString = '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
      }

      // Potong ID agar rapi (Ambil 6 karakter pertama UUID)
      final String rawId = orderMap['id'].toString();
      final String shortId = rawId.length > 6 ? rawId.substring(0, 6).toUpperCase() : rawId;

      return OrderQueue(
        id: 'ORD-$shortId',
        customerName: 'Pelanggan', // Jika Anda punya kolom nama, bisa dipanggil di sini
        orderTime: timeString,
        items: parsedItems,
      );
    }).toList();
  }

  // Fungsi untuk menyelesaikan pesanan FIFO (DEQUEUE)
  Future<bool> completeFrontOrder() async {
    isLoading = true;
    notifyListeners();

    // Jalankan Dequeue dari array dan update ke database
    final finishedOrder = await _queueService.finishFrontOrder();

    if (finishedOrder != null) {
      // Refresh UI dengan array terbaru yang antreannya sudah maju
      _mapQueueToUI();
      isLoading = false;
      notifyListeners();
      return true; // Sukses
    } else {
      isLoading = false;
      notifyListeners();
      return false; // Gagal / Kosong
    }
  }
}