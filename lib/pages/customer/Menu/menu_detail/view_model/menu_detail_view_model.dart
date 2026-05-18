import 'package:restaurant_fifo/core/providers/cart_provider.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_detail/repository/menu_detail_repository.dart';

class MenuDetailViewModel extends BaseViewModel {
  final MenuDetailRepository _repo = MenuDetailRepository();
  
  MenuModel menu; 
  int quantity = 1;
  String notes = '';
  bool isLoading = false;

  MenuDetailViewModel(this.menu);

  @override
  void init() {
    super.init();
    getLatestMenuDetails();
  }

  Future<void> getLatestMenuDetails() async {
    isLoading = true;
    notifyListeners();

    final rawMenu = await _repo.fetchMenuDetail(menu.id);
    if (rawMenu != null) {
      menu = MenuModel(
        id: rawMenu['id'].toString(),
        name: rawMenu['name'].toString(),
        description: rawMenu['description']?.toString() ?? '',
        price: rawMenu['price'] as int? ?? 0,
        imageUrl: rawMenu['image_path']?.toString() ?? '',
        categoryId: menu.categoryId,
        categoryName: menu.categoryName,
        ingredients: menu.ingredients,
      );
    }

    isLoading = false;
    notifyListeners();
  }

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

  int get totalPrice => menu.price * quantity;

  void addToCart(CartProvider cartProvider) {
    cartProvider.addItem(menu, quantity, notes);
    print('Berhasil masuk Tas Belanja: ${menu.name}, Qty: $quantity, Notes: $notes');
  }
}