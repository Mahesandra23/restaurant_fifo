import 'package:supabase_flutter/supabase_flutter.dart';

class IngredientsRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchIngredients() async {
    final response = await _supabase
        .from('ingredients')
        .select('*, stocks(current_quantity, unit)') 
        .order('category', ascending: true) 
        .order('name', ascending: true);    
    return response;
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
    final ingredientResponse = await _supabase.from('ingredients').insert({
      'name': name,
      'category': category,
      'unit': unit,
      'reorder_point': reorderPoint,
      'abc_class': abc,
      'hml_class': hml,
      'sde_class': sde,
      'fsn_class': fsn,
    }).select('id').single();

    final String newIngredientId = ingredientResponse['id'];

    if (currentStock > 0) {
      await _supabase.from('stocks').insert({
        'ingredient_id': newIngredientId,
        'current_quantity': currentStock,
        'unit': unit,
        'entry_date': DateTime.now().toIso8601String(), 
      });
    }
  }

  // FUNGSI UPDATE BARU
  Future<void> updateIngredient({
    required String id,
    required String name,
    required String category,
    required String unit,
    required double reorderPoint,
    required String abc,
    required String hml,
    required String sde,
    required String fsn,
  }) async {
    await _supabase.from('ingredients').update({
      'name': name,
      'category': category,
      'unit': unit,
      'reorder_point': reorderPoint,
      'abc_class': abc,
      'hml_class': hml,
      'sde_class': sde,
      'fsn_class': fsn,
    }).eq('id', id);
  }

  Future<void> deleteIngredient(String id) async {
    await _supabase.from('ingredients').delete().eq('id', id);
  }
}