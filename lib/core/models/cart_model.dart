import 'package:restaurant_fifo/core/models/menu_model.dart';

class CartItem {
  final String id; // ID unik keranjang (Gabungan Menu ID + Notes)
  final MenuModel menu;
  int quantity;
  String notes;

  CartItem({
    required this.id,
    required this.menu,
    this.quantity = 1,
    this.notes = '',
  });

  // Otomatis menghitung subtotal per barang (Harga x Jumlah)
  int get subtotal => menu.price * quantity;
}