import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/ingredients/repository/ingredients_repository.dart';


class IngredientItem {
  final String id; // Sekarang menggunakan UUID dari Supabase
  final String name;
  final String category;

  IngredientItem({required this.id, required this.name, required this.category});
}

class IngredientsViewModel extends BaseViewModel {
  final IngredientsRepository _repo;

  // Masukkan repository ke dalam constructor
  IngredientsViewModel(this._repo);

  bool isLoading = false;
  List<IngredientItem> rawIngredients = [];
  Map<String, List<IngredientItem>> groupedIngredients = {};

  // Daftar kategori tetap untuk pilihan di Dropdown Tambah
  final List<String> categories = [
    'Bahan Baku Utama',
    'Sayur & Buah',
    'Bumbu & Rempah',
    'Cairan & Minyak',
    'Bahan Kering'
  ];

  @override
  void init() {
    super.init();
    fetchIngredients();
  }

  // Menarik data dari Supabase
  Future<void> fetchIngredients() async {
    isLoading = true;
    notifyListeners();

    try {
      final rawData = await _repo.fetchIngredients();
      
      // Mapping dari Supabase ke Model UI
      rawIngredients = rawData.map((row) {
        return IngredientItem(
          id: row['id'].toString(),
          name: row['name'].toString(),
          category: row['category'].toString(),
        );
      }).toList();

      _groupData();
    } catch (e) {
      debugPrint("Error fetch ingredients: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi untuk mengelompokkan data
  void _groupData() {
    groupedIngredients = {};
    for (var item in rawIngredients) {
      if (!groupedIngredients.containsKey(item.category)) {
        groupedIngredients[item.category] = [];
      }
      groupedIngredients[item.category]!.add(item);
    }
  }

  // Fungsi Tambah Bahan ke Supabase
  Future<void> addIngredient(String name, String category) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repo.addIngredient(name, category);
      debugPrint("Ingredient added successfully: $name in category $category");
      await fetchIngredients(); // Tarik ulang data agar list ter-update
    } catch (e) {
      debugPrint("Error add ingredient: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi Hapus Bahan dari Supabase
  Future<void> removeIngredient(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repo.deleteIngredient(id);
      await fetchIngredients(); // Tarik ulang data setelah sukses dihapus
    } catch (e) {
      debugPrint("Error delete ingredient: $e");
      isLoading = false;
      notifyListeners();
    }
  }
}