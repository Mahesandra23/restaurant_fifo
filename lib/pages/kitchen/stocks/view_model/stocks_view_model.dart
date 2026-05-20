import 'package:flutter/material.dart';
import 'package:restaurant_fifo/core/models/ingredients_model.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/core/services/saw_restock_service.dart';
import 'package:restaurant_fifo/pages/kitchen/stocks/repository/stocks_repository.dart';

class StockViewModel extends BaseViewModel {
  final StockRepository _repo;
  final SawRestockService _sawService = SawRestockService();

  List<IngredientModel> allIngredients = [];
  List<SawResult> sawRecommendations = [];
  bool isLoading = false;

  Map<String, double> weights = {
    'ABC': 0.40,
    'FSN': 0.30,
    'SDE': 0.20,
    'HML': 0.10,
  };

  StockViewModel(this._repo);

  @override
  void init() {
    super.init();
    fetchStockData();
  }

  void updateWeight(String criteria, double value) {
    weights[criteria] = value;
    notifyListeners();
  }

  Future<void> fetchStockData() async {
    isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _repo.fetchAllIngredients(),
      _repo.fetchSawWeights(),
    ]);

    allIngredients = results[0] as List<IngredientModel>;
    weights = results[1] as Map<String, double>;

    runSawSpk();

    isLoading = false;
    notifyListeners();
  }

  void runSawSpk() {
    sawRecommendations = _sawService.calculateRecommendations(
      allIngredients,
      weights,
    );
    notifyListeners();
  }

  Future<bool> saveCurrentWeightsToDb() async {
    double totalWeight = weights.values.fold(0, (sum, val) => sum + val);

    if ((totalWeight * 100).round() == 100) {
      return await _repo.saveSawWeights(weights);
    }

    return false;
  }

  // Di StockViewModel, update fungsi restockIngredient
  Future<bool> restockIngredient(
    IngredientModel ingredient,
    double addedQuantity,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      // Mengirim `ingredient.unit` ke repository
      final success = await _repo.addStockBatch(
        ingredient.id,
        addedQuantity,
        ingredient.unit, // <--- Mengirim unit dari model
      );

      if (success) {
        await fetchStockData();
      }
      return success;
    } catch (e) {
      debugPrint("Error restock ingredient: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
