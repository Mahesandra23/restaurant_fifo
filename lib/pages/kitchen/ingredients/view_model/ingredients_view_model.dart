import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/ingredients/repository/ingredients_repository.dart';

class IngredientItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double currentStock;
  final double reorderPoint;
  final String abcClass;
  final String hmlClass;
  final String sdeClass;
  final String fsnClass;

  IngredientItem({
    required this.id,
    required this.name,
    required this.category,
    this.unit = 'pcs',
    this.currentStock = 0,
    this.reorderPoint = 0,
    this.abcClass = 'C',
    this.hmlClass = 'L',
    this.sdeClass = 'E',
    this.fsnClass = 'N',
  });
}

class IngredientsViewModel extends BaseViewModel {
  final IngredientsRepository _repo;

  IngredientsViewModel(this._repo);

  bool isLoading = false;
  List<IngredientItem> rawIngredients = [];
  Map<String, List<IngredientItem>> groupedIngredients = {};

  final List<String> categories = [
    'Main Ingredients',
    'Vegetables & Fruits',
    'Supporting Ingredients',
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
        double totalStock = 0;
        String unitName = row['unit']?.toString() ?? 'pcs';

        if (row['stocks'] != null) {
          final List<dynamic> stockBatches = row['stocks'];
          for (var batch in stockBatches) {
            totalStock += (batch['current_quantity'] as num?)?.toDouble() ?? 0;
          }
        }

        return IngredientItem(
          id: row['id'].toString(),
          name: row['name'].toString(),
          category: row['category'].toString(),
          unit: unitName,
          currentStock: totalStock,
          reorderPoint: (row['reorder_point'] as num?)?.toDouble() ?? 0,
          abcClass: row['abc_class']?.toString() ?? 'C',
          hmlClass: row['hml_class']?.toString() ?? 'L',
          sdeClass: row['sde_class']?.toString() ?? 'E',
          fsnClass: row['fsn_class']?.toString() ?? 'N',
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

  // FUNGSI UPDATE BARU
  Future<void> updateIngredient({
    required String id,
    required String name,
    required String category,
    required String unit,
    required double reorderPoint,
    required double currentStock,
    required String abc,
    required String hml,
    required String sde,
    required String fsn,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repo.updateIngredient(
        id: id,
        name: name,
        category: category,
        unit: unit,
        reorderPoint: reorderPoint,
        currentStock: currentStock,
        abc: abc,
        hml: hml,
        sde: sde,
        fsn: fsn,
      );
      await fetchIngredients();
    } catch (e) {
      debugPrint("Error update ingredient: $e");
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