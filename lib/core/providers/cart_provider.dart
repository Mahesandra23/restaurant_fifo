import 'package:flutter/material.dart';
import 'package:restaurant_fifo/core/models/cart_model.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice =>
      _items.values.fold(0, (sum, item) => sum + item.subtotal);

  // --- TAMBAHKAN GETTER UNTUK TOTAL PRICE YANG SUDAH DIFORMAT ---
  String get formattedTotalPrice => formatRupiah(totalPrice);

  // --- FUNGSI FORMAT RUPIAH ---
  String formatRupiah(num amount) {
    String numStr = amount.toInt().toString();
    String result = '';
    int count = 0;

    for (int i = numStr.length - 1; i >= 0; i--) {
      result = numStr[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  void addItem(MenuModel menu, int quantity, String notes) {
    final String cartKey = '${menu.id}_$notes';

    if (_items.containsKey(cartKey)) {
      _items[cartKey]!.quantity += quantity;
    } else {
      _items[cartKey] = CartItem(
        id: cartKey,
        menu: menu,
        quantity: quantity,
        notes: notes,
      );
    }
    notifyListeners();
  }

  void increaseQuantity(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String id) {
    if (_items.containsKey(id)) {
      if (_items[id]!.quantity > 1) {
        _items[id]!.quantity--;
      } else {
        _items.remove(id);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
