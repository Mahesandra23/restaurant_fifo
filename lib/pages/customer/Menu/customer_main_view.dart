import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/customer/Menu/view_model/customer_main_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart'; 

class CustomerMainView extends StatelessWidget {
  const CustomerMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<CustomerMainViewModel>(
      viewModel: CustomerMainViewModel(),
      initOnce: true,
      key: const Key('CustomerMain'),
      view: (context) {
        final vm = context.watch<CustomerMainViewModel>();

        return Scaffold(
          // 1. Ubah background utama
          backgroundColor: AppRestaurantColors.background, 
          body: SafeArea(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppRestaurantColors.primary))
                : Column(
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPromoBanner(),
                              const SizedBox(height: 24),
                              _buildMenuSection(context, 'Favorite Menu', vm.favoriteMenus),
                              _buildMenuSection(context, 'Appetizers', vm.appetizers),
                              _buildMenuSection(context, 'Main Course - Chicken', vm.mainCourseChicken),
                              _buildMenuSection(context, 'Main Course - Meat', vm.mainCourseMeat),
                              _buildMenuSection(context, 'Main Course - Pasta', vm.mainCoursePasta),
                              _buildMenuSection(context, 'Main Course - Pizza', vm.mainCoursePizza),
                              _buildMenuSection(context, 'Dessert', vm.desserts),
                              _buildMenuSection(context, 'Drink', vm.drinks),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Nama Aplikasi menggunakan warna Primary
          const Text(
            'RestaurantApp',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppRestaurantColors.primary, 
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search menu...',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppRestaurantColors.secondary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: AppRestaurantColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppRestaurantColors.primary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Tombol Filter: Kotak gelap (Primary) dengan ikon terang (Accent)
          Container(
            decoration: BoxDecoration(
              color: AppRestaurantColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: AppRestaurantColors.accent),
              onPressed: () => _showFilterBottomSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: AppRestaurantColors.secondary, // Menggunakan warna gelap untuk banner
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Banner Info Diskon / Gambar Makanan\n(Ambil dari Auth Layout)',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppRestaurantColors.accent, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<MenuItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Menuju halaman See All: $title')),
                );
              },
              child: const Text('See all', style: TextStyle(color: AppRestaurantColors.secondary)),
            ),
          ],
        ),
        
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppRestaurantColors.background,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200, // Warna netral untuk placeholder gambar
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: const Center(child: Icon(Icons.fastfood, color: AppRestaurantColors.secondary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppRestaurantColors.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.price,
                            style: const TextStyle(color: AppRestaurantColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final List<String> filterOptions = [
      'Appetizers', 'Main Course - Chicken', 'Main Course - Meat', 
      'Main Course - Pasta', 'Main Course - Pizza', 'Dessert', 'Drink'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppRestaurantColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter by Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary),
                ),
                const Divider(),
                ...filterOptions.map((option) => ListTile(
                      title: Text(option, style: const TextStyle(color: AppRestaurantColors.primary)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppRestaurantColors.secondary),
                      onTap: () {
                        Navigator.pop(ctx);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}