import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_main/repository/menu_main_repository.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';

class MenuMainViewModel extends BaseViewModel {
  final MenuMainRepository _repository;
  MenuMainViewModel(this._repository);

  bool isLoading = false;

  Map<String, List<MenuModel>> groupedMenus = {};
  List<String> filterCategories = [];
  List<String> bannerUrls = [];

  // VARIABLE BARU: Untuk menyimpan kata kunci pencarian aktif agar bisa dibaca oleh UI
  String searchQuery = '';

  List<Map<String, dynamic>> _cachedRawMenus = [];

  @override
  void init() {
    super.init();
    fetchData();
  }

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

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    try {
      // 1. OPTIMASI: Menjalankan 3 fungsi API secara berbarengan (Lebih Cepat!)
      final results = await Future.wait([
        _repository.fetchMenus(),
        _repository.fetchCategories(),
        _repository.fetchActiveBanners(),
      ]);

      final rawMenus = results[0] as List<Map<String, dynamic>>;
      final rawCategories = results[1] as List<Map<String, dynamic>>;
      bannerUrls = results[2] as List<String>;

      _cachedRawMenus = rawMenus;

      // 2. Olah data kategori untuk Filter
      filterCategories = rawCategories.map((c) => c['name'] as String).toList();

      // 3. Reset pencarian awal
      searchQuery = '';
      _filterAndGroupMenus('');
      
    } catch (e) {
      debugPrint("Error fetching menus: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void searchMenu(String query) {
    searchQuery = query; // Simpan query terbaru
    _filterAndGroupMenus(query);
    notifyListeners();
  }

// --- LOGIKA GROUPING YANG DIUBAH AGAR MENGHARGAI URUTAN ---
  void _filterAndGroupMenus(String query) {
    Map<String, List<MenuModel>> tempGrouped = {};
    final lowerQuery = query.toLowerCase().trim();

    // 1. Inisialisasi urutan map menggunakan daftar kategori yang sudah berurutan dari database
    for (var catName in filterCategories) {
      tempGrouped[catName] = [];
    }
    // Tambahkan 'Uncategorized' di urutan paling bawah untuk berjaga-jaga
    tempGrouped['Uncategorized'] = [];

    // 2. Masukkan makanan ke kandang kategorinya masing-masing
    for (var row in _cachedRawMenus) {
      final menuName = row['name'].toString();

      if (lowerQuery.isNotEmpty && !menuName.toLowerCase().contains(lowerQuery)) {
        continue; 
      }

      final categoryMap = row['menu_categories'] as Map<String, dynamic>?;
      final categoryName = categoryMap?['name'] ?? 'Uncategorized';

      final item = MenuModel(
        id: row['id'].toString(),
        name: menuName,
        price: (row['price'] as num).toInt(), 
        imageUrl: row['image_path']?.toString() ?? '',
        description: row['description']?.toString() ?? '',
      );

      // Jika ada kategori usang, daftarkan
      if (!tempGrouped.containsKey(categoryName)) {
        tempGrouped[categoryName] = [];
      }

      tempGrouped[categoryName]!.add(item);
    }

    // 3. Bersihkan (hapus) kategori yang kosong, agar tidak muncul judul kategori tanpa makanan di layar Customer
    tempGrouped.removeWhere((key, value) => value.isEmpty);

    groupedMenus = tempGrouped;
  }
}