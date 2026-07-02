import 'array_fifo_queue.dart';

class FifoQueueService {
  // Instansiasi Array Queue dengan kapasitas 20
  final ArrayFifoQueue<Map<String, dynamic>> orderQueue = ArrayFifoQueue<Map<String, dynamic>>(20);

  // Memasukkan data awal (dari database) ke dalam antrean
  void loadInitialQueue(List<Map<String, dynamic>> rawOrders) {
    
    while (!orderQueue.isEmpty()) {
      orderQueue.dequeue();
    }

    // Memasukkan data ke dalam Array Queue menggunakan ENQUEUE
    for (var order in rawOrders) {
      orderQueue.enqueue(order);
    }
  }

  // Menambahkan 1 pesanan baru ke posisi paling belakang
  bool enqueueNewOrder(Map<String, dynamic> newOrder) {
    return orderQueue.enqueue(newOrder);
  }

  // Melihat pesanan paling depan (tanpa menghapusnya)
  Map<String, dynamic>? peekFrontOrder() {
    return orderQueue.peek();
  }

  // Mengeluarkan pesanan paling depan (Selesai dimasak)
  Map<String, dynamic>? dequeueFrontOrder() {
    return orderQueue.dequeue();
  }

  // Mendapatkan data untuk di-map ke UI
  List<Map<String, dynamic>> getCurrentQueue() {
    return orderQueue.toList();
  }
}