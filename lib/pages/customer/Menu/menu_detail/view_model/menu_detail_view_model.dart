import 'package:restaurant_fifo/core/providers/cart_provider.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart'; // Import model menu Anda

class MenuDetailViewModel extends BaseViewModel {
  final MenuModel menu; // Menerima data menu dari halaman sebelumnya

  int quantity = 1;
  String notes = '';

  MenuDetailViewModel(this.menu);

  void increment() {
    quantity++;
    notifyListeners();
  }

  void decrement() {
    if (quantity > 1) {
      quantity--;
      notifyListeners();
    }
  }

  void updateNotes(String val) {
    notes = val;
  }

  // Fungsi total harga sementara (Harga x Jumlah)
  int get totalPrice => menu.price * quantity;

  // Fungsi untuk memasukkan ke keranjang
  // Fungsi untuk memasukkan ke keranjang global (Provider)
  void addToCart(CartProvider cartProvider) {
    cartProvider.addItem(menu, quantity, notes);
    
    // Print ini akan muncul di terminal untuk memastikan berhasil
    print('Berhasil masuk Tas Belanja: ${menu.name}, Qty: $quantity, Notes: $notes');
  }
}