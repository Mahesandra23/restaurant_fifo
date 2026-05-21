import 'dart:async';
import 'package:flutter/material.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_all/repository/menu_all_repository.dart';

class MenuAllViewModel extends BaseViewModel {
  final MenuAllRepository _repo;
  final String categoryName;

  MenuAllViewModel(this._repo, this.categoryName);

  bool isLoading = false;
  List<MenuModel> menus = [];

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

  Future<void> fetchMenus() async {
    isLoading = true;
    notifyListeners();

    try {
      final rawData = await _repo.fetchMenusByCategory(
        categoryName,
        _searchQuery,
      );
      menus = rawData.map((row) {
        // --- PROSES MENGEKSTRAK RESEP (Sama seperti di ViewModel Dapur) ---
        List<MenuIngredient> extractedIngredients = [];
        if (row['menu_ingredients'] != null) {
          final listRelasi = row['menu_ingredients'] as List<dynamic>;
          for (var rel in listRelasi) {
            final ingData = rel['ingredients'];
            if (ingData != null) {
              extractedIngredients.add(
                MenuIngredient(
                  id: ingData['id'].toString(),
                  name: ingData['name'].toString(),
                ),
              );
            }
          }
        }
        // ------------------------------------------------------------------

        return MenuModel(
          id: row['id'].toString(),
          name: row['name'].toString(),
          price: int.tryParse(row['price'].toString()) ?? 0,
          imageUrl: row['image_path']?.toString() ?? '',
          description: row['description']?.toString() ?? '',
          categoryId: row['category_id']?.toString() ?? '',

          // MASUKKAN VARIABEL RESEP YANG SUDAH DIEKSTRAK DI ATAS KE SINI:
          ingredients: extractedIngredients,
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
