import 'package:restaurant_fifo/mvvm/base_view_model.dart';

// Model sederhana untuk merepresentasikan item menu
class MenuItem {
  final String name;
  final String price;
  final String imageUrl;

  MenuItem({required this.name, required this.price, this.imageUrl = ''});
}

class CustomerMainViewModel extends BaseViewModel {
  bool isLoading = false;

  // Daftar list untuk masing-masing kategori
  List<MenuItem> favoriteMenus = [];
  List<MenuItem> appetizers = [];
  List<MenuItem> mainCourseChicken = [];
  List<MenuItem> mainCourseMeat = [];
  List<MenuItem> mainCoursePasta = [];
  List<MenuItem> mainCoursePizza = [];
  List<MenuItem> desserts = [];
  List<MenuItem> drinks = [];

  @override
  void init() {
    super.init();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    // Simulasi memuat data dari database/API (Nantinya diganti dengan query Supabase)
    await Future.delayed(const Duration(seconds: 1));

    // Fungsi pembantu untuk membuat 5 dummy data per kategori
    List<MenuItem> generateDummyData(String category) {
      return List.generate(
        5, 
        (index) => MenuItem(
          name: '$category ${index + 1}', 
          price: 'Rp ${(index + 1) * 15}.000',
        ),
      );
    }

    favoriteMenus = generateDummyData('Favorite');
    appetizers = generateDummyData('Appetizer');
    mainCourseChicken = generateDummyData('Chicken');
    mainCourseMeat = generateDummyData('Meat');
    mainCoursePasta = generateDummyData('Pasta');
    mainCoursePizza = generateDummyData('Pizza');
    desserts = generateDummyData('Dessert');
    drinks = generateDummyData('Drink');

    isLoading = false;
    notifyListeners();
  }
}