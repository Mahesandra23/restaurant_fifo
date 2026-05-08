import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_all/view_model/menu_all_view_model.dart'; // Import model menu Anda

class MenuDetailViewModel extends BaseViewModel {
  final CustomerMenuModel menu; // Menerima data menu dari halaman sebelumnya

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
  void addToCart() {
    // TODO: Nanti disambungkan ke CartProvider atau SessionProvider
    // Contoh bentuk data yang akan dilempar ke keranjang:
    // {
    //   'menu_id': menu.id,
    //   'name': menu.name,
    //   'price': menu.price,
    //   'quantity': quantity,
    //   'notes': notes,
    // }
    
    print('Berhasil ditambahkan: ${menu.name}, Qty: $quantity, Notes: $notes');
  }
}