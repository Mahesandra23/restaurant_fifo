import 'dart:async';
import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_all/repository/menu_all_repository.dart';


class CustomerMenuModel {
  final String id;
  final String name;
  final int price;
  final String imageUrl;

  CustomerMenuModel({required this.id, required this.name, required this.price, required this.imageUrl});
  String get formattedPrice => 'Rp $price'; // Anda bisa gunakan NumberFormat di sini nanti
}

class MenuAllViewModel extends BaseViewModel {
  final MenuAllRepository _repo;
  final String categoryName;

  MenuAllViewModel(this._repo, this.categoryName);

  bool isLoading = false;
  List<CustomerMenuModel> menus = [];
  
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void init() {
    super.init();
    fetchMenus();
  }

  // Dipanggil setiap kali teks di SearchBar berubah
  void onSearchChanged(String query) {
    _searchQuery = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Tunggu 500ms setelah user berhenti mengetik sebelum memanggil database
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchMenus();
    });
  }

  Future<void> fetchMenus() async {
    isLoading = true;
    notifyListeners();

    try {
      final rawData = await _repo.fetchMenusByCategory(categoryName, _searchQuery);
      menus = rawData.map((row) {
        return CustomerMenuModel(
          id: row['id'].toString(),
          name: row['name'].toString(),
          price: int.tryParse(row['price'].toString()) ?? 0,
          imageUrl: row['image_path']?.toString() ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetch all menus: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}