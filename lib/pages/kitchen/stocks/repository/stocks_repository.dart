import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restaurant_fifo/core/models/ingredients_model.dart';

class StockRepository {
  final _supabase = Supabase.instance.client;

  Future<List<IngredientModel>> fetchAllIngredients() async {
    try {
      final response = await _supabase
          .from('ingredients')
          .select('*, stocks(current_quantity)')
          .order('name', ascending: true);

      List<IngredientModel> ingredientsList = [];

      for (var row in response) {
        double totalStock = 0;
        if (row['stocks'] != null) {
          final List<dynamic> stockBatches = row['stocks'];
          for (var batch in stockBatches) {
            totalStock += (batch['current_quantity'] as num?)?.toDouble() ?? 0;
          }
        }

        String abc = row['abc_class']?.toString().trim() ?? 'C';
        String hml = row['hml_class']?.toString().trim() ?? 'L';
        String sde = row['sde_class']?.toString().trim() ?? 'E';
        String fsn = row['fsn_class']?.toString().trim() ?? 'N';

        ingredientsList.add(
          IngredientModel(
            id: row['id'].toString(),
            name: row['name'].toString(),
            unit: row['unit']?.toString() ?? 'pcs',
            currentStock: totalStock,
            reorderPoint: (row['reorder_point'] as num?)?.toDouble() ?? 0,
            abcClass: abc,
            hmlClass: hml,
            sdeClass: sde,
            fsnClass: fsn,
          ),
        );
      }
      return ingredientsList;
    } catch (e) {
      debugPrint('Error fetchAllIngredients (SAW): $e');
      return [];
    }
  }

  Future<Map<String, double>> fetchSawWeights() async {
    try {
      final response = await _supabase
          .from('saw_weights')
          .select()
          .eq('id', 'default')
          .single();

      return {
        'ABC': (response['abc_weight'] as num).toDouble(),
        'FSN': (response['fsn_weight'] as num).toDouble(),
        'SDE': (response['sde_weight'] as num).toDouble(),
        'HML': (response['hml_weight'] as num).toDouble(),
      };
    } catch (e) {
      debugPrint(
        'Error fetchSawWeights: $e. Menggunakan fallback nilai default.',
      );
      return {'ABC': 0.40, 'FSN': 0.30, 'SDE': 0.20, 'HML': 0.10};
    }
  }

  // --- PERBAIKAN: TAMBAH KOLOM updated_by ---
  Future<bool> saveSawWeights(Map<String, double> weights) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      // Siapkan payload data berdasarkan skema yang difoto
      final payload = {
        'id': 'default',
        'abc_weight': weights['ABC'],
        'fsn_weight': weights['FSN'],
        'sde_weight': weights['SDE'],
        'hml_weight': weights['HML'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Tambahkan updated_by ke object payload (bila user sudah login)
      if (userId != null) {
        payload['updated_by'] = userId;
      }

      await _supabase.from('saw_weights').upsert(payload);
      return true; // Berhasil menyimpan
    } catch (e) {
      debugPrint('Error ketika menyimpan bobot ke database: $e');
      return false; // Gagal menyimpan
    }
  }

  // Update fungsi addStockBatch agar menerima unit
  Future<bool> addStockBatch(
    String ingredientId,
    double quantity,
    String unit,
  ) async {
    try {
      await _supabase.from('stocks').insert({
        'ingredient_id': ingredientId,
        'current_quantity': quantity,
        'unit': unit, // <--- MENAMBAHKAN KOLOM INI
        'entry_date': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint("Error insert stock batch: $e");
      return false;
    }
  }
}
