import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/queue/repository/queue_repository.dart';
import 'package:restaurant_fifo/core/services/fifo_queue_service.dart';

class OrderItem {
  final String name;
  final int quantity;
  final String notes;

  OrderItem({required this.name, required this.quantity, this.notes = ''});
}

class OrderQueue {
  final String id;
  final String rawId;
  final String customerName;
  final String orderTime;
  final List<OrderItem> items;
  final String tableNumber;
  final String status;

  OrderQueue({
    required this.id,
    required this.rawId,
    required this.customerName,
    required this.orderTime,
    required this.items,
    required this.tableNumber,
    required this.status,
  });
}

class QueueViewModel extends BaseViewModel {
  bool isLoading = false;
  final QueueRepository _repo = QueueRepository();
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

    final rawOrders = await _repo.fetchActiveOrders();
    _queueService.loadInitialQueue(rawOrders);
    _mapQueueToUI();

    isLoading = false;
    notifyListeners();
  }

  // Fungsi Mengubah status menjadi Cooking & Mengurangi Stok Bahan Baku
  Future<bool> acceptToCook(String orderId) async {
    isLoading = true;
    notifyListeners();

    final success = await _repo.startCookingOrder(orderId);
    if (success) {
      await fetchData();
    }

    isLoading = false;
    notifyListeners();
    return success;
  }

  // Fungsi: Menyelesaikan pesanan yang sedang dimasak
  Future<bool> completeOrder(String orderId) async {
    isLoading = true;
    notifyListeners();

    final success = await _repo.updateOrderStatusToCompleted(orderId);
    if (success) {
      _queueService.dequeueFrontOrder();

      _mapQueueToUI();

    }

    isLoading = false;
    notifyListeners();
    return success;
  }

  void _mapQueueToUI() {
    final rawQueue = _queueService.getCurrentQueue();

    activeOrders = rawQueue.map((orderMap) {
      final rawItems = orderMap['order_items'] as List<dynamic>? ?? [];
      final parsedItems = rawItems.map((item) {
        return OrderItem(
          name: item['menus']['name'] ?? 'Unknown Menu',
          quantity: item['quantity'] ?? 1,
          notes: item['notes'] ?? '',
        );
      }).toList();

      final createdAt = orderMap['created_at'];
      String timeString = '';
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt).toLocal();
        timeString =
            '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
      }

      final String rawId = orderMap['id'].toString();
      final String shortId = rawId.length > 6
          ? rawId.substring(0, 6).toUpperCase()
          : rawId;

      String customerName = 'Guest';
      if (orderMap['profiles'] != null &&
          orderMap['profiles']['display_name'] != null) {
        customerName = orderMap['profiles']['display_name'];
      }

      return OrderQueue(
        id: 'ORD-$shortId',
        rawId: rawId, // Kita simpan UUID aslinya di sini
        customerName: customerName,
        orderTime: timeString,
        items: parsedItems,
        tableNumber: orderMap['table_number'] ?? 'Takeaway',
        status:
            orderMap['status']?.toString() ?? 'pending', // Ambil status dari DB
      );
    }).toList();
  }
}
