import 'package:restaurant_fifo/mvvm/base_view_model.dart';

// --- MODEL DATA ---
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
  
  // List untuk menyimpan antrean pesanan
  List<OrderQueue> activeOrders = [];

  @override
  void init() {
    super.init();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    // Simulasi ambil data dari API / Supabase
    await Future.delayed(const Duration(seconds: 1));
    
    // Dummy Data Pesanan Masuk
    activeOrders = [
      OrderQueue(
        id: 'ORD-001',
        customerName: 'Meja 4 - Ravindra',
        orderTime: '14:30',
        items: [
          OrderItem(name: 'Main Course - Chicken', quantity: 2, notes: 'Pedas sedang'),
          OrderItem(name: 'Drink - Lemon Tea', quantity: 2, notes: 'Es dipisah'),
        ],
      ),
      OrderQueue(
        id: 'ORD-002',
        customerName: 'Meja 2 - Budi',
        orderTime: '14:35',
        items: [
          OrderItem(name: 'Appetizer - French Fries', quantity: 1),
          OrderItem(name: 'Main Course - Pizza', quantity: 1, notes: 'Extra Cheese'),
        ],
      ),
      OrderQueue(
        id: 'ORD-003',
        customerName: 'Takeaway - Sarah',
        orderTime: '14:40',
        items: [
          OrderItem(name: 'Dessert - Brownie', quantity: 3),
        ],
      ),
    ];

    isLoading = false;
    notifyListeners(); 
  }

  // Fungsi untuk menyelesaikan pesanan (menghapus dari antrean)
  void completeOrder(String orderId) {
    activeOrders.removeWhere((order) => order.id == orderId);
    notifyListeners(); // Update UI agar list berkurang
  }
}