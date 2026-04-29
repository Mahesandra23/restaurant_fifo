import 'package:restaurant_fifo/mvvm/base_view_model.dart';

class IngredientItem {
  final String id;
  final String name;
  final String category;

  IngredientItem({required this.id, required this.name, required this.category});
}

class IngredientsViewModel extends BaseViewModel {
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

  Future<void> fetchIngredients() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    rawIngredients = [
      IngredientItem(id: 'ING-01', name: 'Daging Ayam Paha', category: 'Bahan Baku Utama'),
      IngredientItem(id: 'ING-04', name: 'Bawang Bombay', category: 'Sayur & Buah'),
      IngredientItem(id: 'ING-07', name: 'Garam Halus', category: 'Bumbu & Rempah'),
    ];

    _groupData();
    isLoading = false;
    notifyListeners();
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

  // Fungsi Tambah Bahan (Tanpa pindah halaman)
  void addIngredient(String name, String category) {
    final newId = 'ING-${rawIngredients.length + 10}';
    final newItem = IngredientItem(id: newId, name: name, category: category);
    
    rawIngredients.add(newItem);
    _groupData();
    notifyListeners();
  }

  // Fungsi Hapus Bahan (Tombol minus)
  void removeIngredient(String id) {
    rawIngredients.removeWhere((item) => item.id == id);
    _groupData();
    notifyListeners();
  }
}