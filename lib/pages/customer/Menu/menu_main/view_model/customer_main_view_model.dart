import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_main/repository/customer_main_repository.dart';


// Model MenuItem diperbarui untuk menampung ID (penting untuk masuk keranjang nanti)
class MenuItem {
  final String id;
  final String name;
  final int price; // Diubah ke int sesuai database
  final String imageUrl;
  final String description;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl = '',
    this.description = '',
  });

  // Helper untuk format harga
  String get formattedPrice => 'Rp $price';
}

class CustomerMainViewModel extends BaseViewModel {
  // Injeksi Repository
  final MenuRepository _repository;
  CustomerMainViewModel(this._repository);

  bool isLoading = false;

  // Kumpulan data yang dikelompokkan otomatis berdasarkan kategori
  // Contoh isi: {'Drink': [Item1, Item2], 'Dessert': [Item3]}
  Map<String, List<MenuItem>> groupedMenus = {};
  
  // Daftar nama kategori untuk filter bottom sheet
  List<String> filterCategories = [];

  @override
  void init() {
    super.init();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    try {
      // 1. Tarik data dari Supabase via Repository
      final rawMenus = await _repository.fetchMenus();
      final rawCategories = await _repository.fetchCategories();

      // 2. Olah data kategori untuk Filter
      filterCategories = rawCategories.map((c) => c['name'] as String).toList();

      // 3. Olah dan kelompokkan Menu berdasarkan Kategori
      Map<String, List<MenuItem>> tempGrouped = {};

      for (var row in rawMenus) {
        // Karena ada relasi, bentuk datanya bertingkat. Kita ekstrak nama kategorinya.
        final categoryMap = row['menu_categories'] as Map<String, dynamic>?;
        final categoryName = categoryMap?['name'] ?? 'Uncategorized';

        final item = MenuItem(
          id: row['id'].toString(),
          name: row['name'].toString(),
          price: row['price'] as int,
          imageUrl: row['image_path']?.toString() ?? '',
          description: row['description']?.toString() ?? '',
        );

        // Jika kategori belum ada di Map, buat list baru
        if (!tempGrouped.containsKey(categoryName)) {
          tempGrouped[categoryName] = [];
        }
        
        // Masukkan item ke dalam kelompok kategorinya
        tempGrouped[categoryName]!.add(item);
      }

      groupedMenus = tempGrouped;
    } catch (e) {
      debugPrint("Error fetching menus: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}