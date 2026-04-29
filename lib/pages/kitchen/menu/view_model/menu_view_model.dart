import 'package:restaurant_fifo/mvvm/base_view_model.dart';

// --- MODEL DATA ---
class MasterIngredient {
  final String id;
  final String name;
  MasterIngredient({required this.id, required this.name});
}

class MenuData {
  final String id;
  String name;
  String description;
  String category;
  String imageUrl; // URL gambar atau asset
  List<MasterIngredient> ingredients; // Relasi ke bahan baku

  MenuData({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imageUrl = '',
    required this.ingredients,
  });
}

// --- VIEW MODEL ---
class MenuViewModel extends BaseViewModel {
  bool isLoading = false;

  // Daftar Menu yang ada di restoran
  List<MenuData> menus = [];

  // Daftar Master Bahan Baku (Diambil dari database/halaman Ingredients)
  List<MasterIngredient> availableIngredients = [];

  // Kategori Menu
  final List<String> menuCategories = [
    'Appetizer',
    'Main Course',
    'Dessert',
    'Drink'
  ];

  @override
  void init() {
    super.init();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // 1. Ambil Master Data Bahan (Simulasi)
    availableIngredients = [
      MasterIngredient(id: 'ING-01', name: 'Daging Ayam Paha'),
      MasterIngredient(id: 'ING-04', name: 'Bawang Bombay'),
      MasterIngredient(id: 'ING-06', name: 'Selada Air'),
      MasterIngredient(id: 'ING-07', name: 'Garam Halus'),
      MasterIngredient(id: 'ING-09', name: 'Kaldu Jamur'),
      MasterIngredient(id: 'ING-10', name: 'Minyak Goreng Sawit'),
    ];

    // 2. Ambil Data Menu (Simulasi)
    menus = [
      MenuData(
        id: 'MNU-001',
        name: 'Ayam Goreng Crispy',
        description: 'Ayam goreng renyah dengan bumbu rahasia.',
        category: 'Main Course',
        ingredients: [
          availableIngredients[0], // Daging Ayam Paha
          availableIngredients[3], // Garam
          availableIngredients[5], // Minyak Goreng
        ],
      ),
    ];

    isLoading = false;
    notifyListeners();
  }

  // --- FUNGSI CRUD ---

  // CREATE
  void addMenu(String name, String desc, String category, List<MasterIngredient> selectedIng) {
    final newMenu = MenuData(
      id: 'MNU-00${menus.length + 2}',
      name: name,
      description: desc,
      category: category,
      ingredients: List.from(selectedIng),
    );
    menus.add(newMenu);
    notifyListeners();
  }

  // UPDATE
  void updateMenu(String id, String newName, String newDesc, String newCategory, List<MasterIngredient> newIng) {
    final index = menus.indexWhere((m) => m.id == id);
    if (index != -1) {
      menus[index].name = newName;
      menus[index].description = newDesc;
      menus[index].category = newCategory;
      menus[index].ingredients = List.from(newIng);
      notifyListeners();
    }
  }

  // DELETE
  void deleteMenu(String id) {
    menus.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}