import 'package:flutter/material.dart';

// 1. Model untuk Item di Keranjang
class CartItem {
  final String id;
  final String name;
  final int price; // Gunakan integer agar mudah dihitung
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}

// 2. ViewModel untuk Keranjang
// Menggunakan ChangeNotifier biasa agar bisa di-provide secara global
class CartViewModel extends ChangeNotifier {
  // Data dummy sementara agar bisa langsung dilihat hasilnya
  final List<CartItem> _items = [
    CartItem(id: '1', name: 'Main Course - Chicken', price: 25000, quantity: 2),
    CartItem(id: '2', name: 'Drink - Lemon Tea', price: 10000, quantity: 1),
  ];

  List<CartItem> get items => _items;

  // Menghitung total jumlah barang (Ini yang akan tampil di angka merah BottomNav)
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  // Menghitung total harga
  int get totalPrice => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  // Fungsi tambah jumlah
  void increaseQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Fungsi kurangi jumlah / hapus
  void decreaseQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index); // Hapus jika sisa 1 lalu dikurangi
      }
      notifyListeners();
    }
  }
}