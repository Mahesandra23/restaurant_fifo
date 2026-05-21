import 'package:flutter/material.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/repository/menu_repository.dart';
import 'dart:io';

class CategoryData {
  final String id;
  final String name;
  CategoryData({required this.id, required this.name});
}

class MenuViewModel extends BaseViewModel {
  final MenuRepository _repo;
  MenuViewModel(this._repo);

  bool isLoading = false;

  List<CategoryData> categories = [];
  List<MenuIngredient> availableIngredients = [];
  Map<String, List<MenuModel>> groupedMenus = {};

  // --- VARIABEL UNTUK PENCARIAN ---
  String searchQuery = '';
  List<Map<String, dynamic>> _cachedRawMenus = [];

  @override
  void init() {
    super.init();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.fetchCategories(),
        _repo.fetchIngredients(),
        _repo.fetchMenus(),
      ]);

      // 1. Parse Categories
      categories = (results[0] as List)
          .map(
            (c) => CategoryData(
              id: c['id'].toString(),
              name: c['name'].toString(),
            ),
          )
          .toList();

      // 2. Parse Ingredients
      availableIngredients = (results[1] as List)
          .map(
            (i) => MenuIngredient(
              id: i['id'].toString(),
              name: i['name'].toString(),
              unit: i['unit']?.toString() ?? '',
            ),
          )
          .toList();

      // 3. Simpan data mentah ke Cache & Reset filter pencarian
      _cachedRawMenus = results[2] as List<Map<String, dynamic>>;
      searchQuery = '';
      _filterAndGroupMenus('');
    } catch (e) {
      debugPrint("Error fetching kitchen data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- FUNGSI PENCARIAN ---
  void searchMenu(String query) {
    searchQuery = query;
    _filterAndGroupMenus(query);
    notifyListeners();
  }

  // UBAH JADI PUBLIK AGAR BISA DIPANGGIL DARI VIEW
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

  // --- FUNGSI FILTER & GROUPING LOKAL ---
  void _filterAndGroupMenus(String query) {
    Map<String, List<MenuModel>> tempGrouped = {};
    final lowerQuery = query.toLowerCase().trim();

    for (var row in _cachedRawMenus) {
      final menuName = row['name'].toString();

      // Lewati (filter out) menu yang namanya tidak mengandung kata kunci pencarian
      if (lowerQuery.isNotEmpty &&
          !menuName.toLowerCase().contains(lowerQuery)) {
        continue;
      }

      final catMap = row['menu_categories'] as Map<String, dynamic>?;
      final catName = catMap?['name'] ?? 'Uncategorized';

      final List<dynamic> rawIng = row['menu_ingredients'] ?? [];
      final List<MenuIngredient> menuIngs = rawIng.map((item) {
        final ingMap = item['ingredients'] as Map<String, dynamic>?;
        return MenuIngredient(
          id: item['ingredient_id'].toString(),
          name: ingMap?['name'].toString() ?? '',
          unit: ingMap?['unit']?.toString() ?? '',
          quantityNeeded: (item['quantity_needed'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      final menu = MenuModel(
        id: row['id'].toString(),
        name: menuName,
        description: row['description']?.toString() ?? '',
        // KEMBALIKAN KE BENTUK ANGKA AGAR TIDAK ERROR
        price: (row['price'] as num?)?.toInt() ?? 0,
        categoryId: row['category_id']?.toString() ?? '',
        categoryName: catName,
        imageUrl: row['image_path']?.toString() ?? '',
        ingredients: menuIngs,
      );

      if (!tempGrouped.containsKey(catName)) {
        tempGrouped[catName] = [];
      }
      tempGrouped[catName]!.add(menu);
    }

    groupedMenus = tempGrouped;
  }

  Future<void> addCategory(String name) async {
    await _repo.addCategory(name);
    await fetchInitialData();
  }

  Future<void> deleteCategory(String id) async {
    await _repo.deleteCategory(id);
    await fetchInitialData();
  }

  Future<void> saveMenu({
    String? id,
    required String name,
    required String desc,
    required String price,
    required String categoryId,
    required Map<String, double> ingredientQuantities,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    isLoading = true;
    notifyListeners();

    String? finalImageUrl = existingImageUrl;

    try {
      if (imageFile != null) {
        final uploadedUrl = await _repo.uploadMenuImage(imageFile);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        }
      }

      final menuData = {
        'name': name,
        'description': desc,
        // UBAH STRING INPUT MENJADI ANGKA SEBELUM DISIMPAN KE DATABASE
        'price': int.tryParse(price) ?? 0,
        'category_id': categoryId,
        if (finalImageUrl != null && finalImageUrl.isNotEmpty)
          'image_path': finalImageUrl,
      };

      if (id == null) {
        await _repo.addMenu(menuData, ingredientQuantities);
      } else {
        await _repo.updateMenu(id, menuData, ingredientQuantities);
      }
      await fetchInitialData();
    } catch (e) {
      debugPrint("Error save menu: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMenu(String id) async {
    isLoading = true;
    notifyListeners();
    await _repo.deleteMenu(id);
    await fetchInitialData();
  }
}
