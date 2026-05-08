import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/repository/menu_repository.dart';
  import 'dart:io';

class CategoryData {
  final String id;
  final String name;
  CategoryData({required this.id, required this.name});
}

class MasterIngredient {
  final String id;
  final String name;
  MasterIngredient({required this.id, required this.name});
}

class KitchenMenuData {
  final String id;
  final String name;
  final String description;
  final int price;
  final String categoryId;
  final String categoryName;
  final String imageUrl;
  final List<MasterIngredient> ingredients;

  KitchenMenuData({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
    required this.ingredients,
  });
}

class MenuViewModel extends BaseViewModel {
  final MenuRepository _repo;
  MenuViewModel(this._repo);

  bool isLoading = false;

  List<CategoryData> categories = [];
  List<MasterIngredient> availableIngredients = [];
  Map<String, List<KitchenMenuData>> groupedMenus = {};

  @override
  void init() {
    super.init();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch Paralel agar lebih cepat
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
            (i) => MasterIngredient(
              id: i['id'].toString(),
              name: i['name'].toString(),
            ),
          )
          .toList();

      // 3. Parse Menus & Grouping
      final rawMenus = results[2] as List;
      groupedMenus = {};

      for (var row in rawMenus) {
        final catMap = row['menu_categories'] as Map<String, dynamic>?;
        final catName = catMap?['name'] ?? 'Uncategorized';

        final List<dynamic> rawIng = row['menu_ingredients'] ?? [];
        final List<MasterIngredient> menuIngs = rawIng.map((item) {
          return MasterIngredient(
            id: item['ingredient_id'].toString(),
            name: item['ingredients']['name'].toString(),
          );
        }).toList();

        final menu = KitchenMenuData(
          id: row['id'].toString(),
          name: row['name'].toString(),
          description: row['description']?.toString() ?? '',
          price: row['price'] as int? ?? 0,
          categoryId: row['category_id']?.toString() ?? '',
          categoryName: catName,
          imageUrl: row['image_path']?.toString() ?? '',
          ingredients: menuIngs,
        );

        if (!groupedMenus.containsKey(catName)) {
          groupedMenus[catName] = [];
        }
        groupedMenus[catName]!.add(menu);
      }
    } catch (e) {
      debugPrint("Error fetching kitchen data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- FUNGSI KATEGORI ---
  Future<void> addCategory(String name) async {
    await _repo.addCategory(name);
    await fetchInitialData();
  }

  Future<void> deleteCategory(String id) async {
    await _repo.deleteCategory(id);
    await fetchInitialData();
  }

  // --- FUNGSI MENU ---
  // Update parameter saveMenu
  Future<void> saveMenu({
    String? id, required String name, required String desc, 
    required int price, required String categoryId, required List<String> ingredientIds,
    File? imageFile, // Parameter foto baru
    String? existingImageUrl, // URL foto lama (jika edit)
  }) async {
    isLoading = true;
    notifyListeners();
    
    String? finalImageUrl = existingImageUrl;

    try {
      // Jika Admin memilih foto baru dari galeri, Upload dulu!
      if (imageFile != null) {
        final uploadedUrl = await _repo.uploadMenuImage(imageFile);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        }
      }

      // Siapkan data untuk disimpan ke tabel menus
      final menuData = {
        'name': name, 
        'description': desc, 
        'price': price, 
        'category_id': categoryId,
        if (finalImageUrl != null && finalImageUrl.isNotEmpty) 'image_path': finalImageUrl,
      };
      
      if (id == null) {
        await _repo.addMenu(menuData, ingredientIds);
      } else {
        await _repo.updateMenu(id, menuData, ingredientIds);
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
