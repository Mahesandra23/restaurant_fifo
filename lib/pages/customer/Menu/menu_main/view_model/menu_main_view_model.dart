import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_main/repository/menu_main_repository.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';

class MenuMainViewModel extends BaseViewModel {
  // Injeksi Repository
  final MenuMainRepository _repository;
  MenuMainViewModel(this._repository);

  bool isLoading = false;

  // Kumpulan data yang dikelompokkan otomatis berdasarkan kategori
  // Contoh isi: {'Drink': [Item1, Item2], 'Dessert': [Item3]}
  Map<String, List<MenuModel>> groupedMenus = {};

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
      Map<String, List<MenuModel>> tempGrouped = {};

      for (var row in rawMenus) {
        // Karena ada relasi, bentuk datanya bertingkat. Kita ekstrak nama kategorinya.
        final categoryMap = row['menu_categories'] as Map<String, dynamic>?;
        final categoryName = categoryMap?['name'] ?? 'Uncategorized';

        final item = MenuModel(
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
