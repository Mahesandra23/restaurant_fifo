class IngredientModel {
  final String id;
  final String name;
  final String unit;
  final double currentStock;
  final double reorderPoint;
  final String abcClass;
  final String hmlClass;
  final String sdeClass;
  final String fsnClass;

  IngredientModel({
    required this.id, required this.name, required this.unit,
    required this.currentStock, required this.reorderPoint,
    required this.abcClass, required this.hmlClass, required this.sdeClass, required this.fsnClass,
  });
}