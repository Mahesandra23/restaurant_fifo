import 'package:restaurant_fifo/core/models/ingredients_model.dart';

// Model untuk dilempar ke UI
class SawResult {
  final IngredientModel ingredient;
  final double score;
  final int rank;

  SawResult({required this.ingredient, required this.score, this.rank = 0});
}

class SawRestockService {
  // Fungsi konversi kriteria ke nilai (xij)
  int _getScore(String value, String type) {
    value = value.toUpperCase();
    if (type == 'ABC') return value == 'A' ? 3 : value == 'B' ? 2 : 1;
    if (type == 'HML') return value == 'H' ? 3 : value == 'M' ? 2 : 1;
    if (type == 'SDE') return value == 'S' ? 3 : value == 'D' ? 2 : 1;
    if (type == 'FSN') return value == 'F' ? 3 : value == 'S' ? 2 : 1;
    return 1; // Default fallback
  }

  /// Menjalankan algoritma SAW
  /// [ingredients] = daftar seluruh bahan baku dari database
  /// [weights] = bobot dari UI (harus berjumlah 1.0 atau 100%)
  List<SawResult> calculateRecommendations(
    List<IngredientModel> ingredients,
    Map<String, double> weights,
  ) {
    // 1. FILTERING: Hanya proses yang butuh restock (<= Reorder Point ATAU <= Safety Stock)
    final filteredIngredients = ingredients.where((item) {
      return item.currentStock <= item.reorderPoint;
    }).toList();

    if (filteredIngredients.isEmpty) return [];

    List<SawResult> results = [];

    // Catatan Akademis: Dalam SAW murni, matriks keputusan (X) harus di-Normalisasi (R).
    // Karena max nilai kita seragam yaitu 3, pembaginya adalah 3.
    //  Rij = Xij / Max(Xj)
    const double maxCriteriaValue = 3.0;

    // 2. PERHITUNGAN MATRIKS
    for (var item in filteredIngredients) {
      // Ambil nilai mentah Xij
      double xAbc = _getScore(item.abcClass, 'ABC').toDouble();
      double xHml = _getScore(item.hmlClass, 'HML').toDouble();
      double xSde = _getScore(item.sdeClass, 'SDE').toDouble();
      double xFsn = _getScore(item.fsnClass, 'FSN').toDouble();

      // Normalisasi (Rij)
      double rAbc = xAbc / maxCriteriaValue;
      double rHml = xHml / maxCriteriaValue;
      double rSde = xSde / maxCriteriaValue;
      double rFsn = xFsn / maxCriteriaValue;

      // Perkalian Bobot (Vi = Σ wj * Rij)
      double finalScore = (rAbc * (weights['ABC'] ?? 0)) +
                          (rHml * (weights['HML'] ?? 0)) +
                          (rSde * (weights['SDE'] ?? 0)) +
                          (rFsn * (weights['FSN'] ?? 0));

      results.add(SawResult(ingredient: item, score: finalScore));
    }

    // 3. SORTING RANKING (Dari nilai terbesar ke terkecil)
    results.sort((a, b) => b.score.compareTo(a.score));

    // 4. ASSIGN RANKING NUMBER
    return List.generate(
      results.length,
      (index) => SawResult(
        ingredient: results[index].ingredient,
        score: results[index].score,
        rank: index + 1,
      ),
    );
  }
}