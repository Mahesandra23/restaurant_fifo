import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/ingredients/repository/ingredients_repository.dart';

// UPDATE MODEL: Tambahkan parameter stok dan kriteria
class IngredientItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double currentStock;

  IngredientItem({
    required this.id,
    required this.name,
    required this.category,
    this.unit = 'pcs',
    this.currentStock = 0,
  });
}

class IngredientsViewModel extends BaseViewModel {
  final IngredientsRepository _repo;

  IngredientsViewModel(this._repo);

  bool isLoading = false;
  List<IngredientItem> rawIngredients = [];
  Map<String, List<IngredientItem>> groupedIngredients = {};

  final List<String> categories = [
    'Bahan Baku Utama',
    'Sayur & Buah',
    'Bumbu & Rempah',
    'Cairan & Minyak',
    'Bahan Kering',
  ];

  @override
  void init() {
    super.init();
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    isLoading = true;
    notifyListeners();

    try {
      final rawData = await _repo.fetchIngredients();

      rawIngredients = rawData.map((row) {
        // --- LOGIKA HITUNG TOTAL STOK FIFO ---
        double totalStock = 0;
        String unitName = row['unit']?.toString() ?? 'pcs';

        // Cek apakah ada data di tabel relasi 'stocks'
        if (row['stocks'] != null) {
          final List<dynamic> stockBatches = row['stocks'];
          for (var batch in stockBatches) {
            totalStock += (batch['current_quantity'] as num?)?.toDouble() ?? 0;
          }
        }
        // -------------------------------------

        return IngredientItem(
          id: row['id'].toString(),
          name: row['name'].toString(),
          category: row['category'].toString(),
          unit: unitName,
          currentStock: totalStock, // Masukkan total hasil hitungan relasi
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

  void _groupData() {
    groupedIngredients = {};
    for (var item in rawIngredients) {
      if (!groupedIngredients.containsKey(item.category)) {
        groupedIngredients[item.category] = [];
      }
      groupedIngredients[item.category]!.add(item);
    }
  }

  // UPDATE FUNGSI TAMBAH: Menerima banyak parameter
  Future<void> addIngredient({
    required String name,
    required String category,
    required String unit,
    required double currentStock,
    required double reorderPoint,
    required String abc,
    required String hml,
    required String sde,
    required String fsn,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repo.addIngredient(
        name: name,
        category: category,
        unit: unit,
        currentStock: currentStock,
        reorderPoint: reorderPoint,
        abc: abc,
        hml: hml,
        sde: sde,
        fsn: fsn,
      );
      await fetchIngredients();
    } catch (e) {
      debugPrint("Error add ingredient: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeIngredient(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repo.deleteIngredient(id);
      await fetchIngredients();
    } catch (e) {
      debugPrint("Error delete ingredient: $e");
      isLoading = false;
      notifyListeners();
    }
  }
}
