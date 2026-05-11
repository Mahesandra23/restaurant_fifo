import 'package:flutter/material.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/menu_view.dart';
import 'package:restaurant_fifo/pages/kitchen/ingredients/ingredients_view.dart';

class KitchenCatalogView extends StatelessWidget {
  const KitchenCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 Tab
      child: Scaffold(
        backgroundColor: AppRestaurantColors.background,
        appBar: AppBar(
          title: const Text('Catalog & Recipes', style: TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.accent)),
          backgroundColor: AppRestaurantColors.primary,
          centerTitle: true,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: AppRestaurantColors.accent,
            indicatorWeight: 3,
            labelColor: AppRestaurantColors.accent,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Menu List'),
              Tab(icon: Icon(Icons.kitchen), text: 'Ingredient Master'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MenuView(),        // Memanggil halaman Menu
            IngredientsView(), // Memanggil halaman Bahan Baku
          ],
        ),
      ),
    );
  }
}