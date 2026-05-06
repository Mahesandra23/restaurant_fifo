import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/customer/Menu/repository/customer_main_repository.dart';
import 'package:restaurant_fifo/pages/customer/Menu/view_model/customer_main_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class CustomerMainView extends StatelessWidget {
  const CustomerMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<CustomerMainViewModel>(
      // Masukkan MenuRepository saat inisialisasi ViewModel
      viewModel: CustomerMainViewModel(MenuRepository()),
      initOnce: true,
      key: const Key('CustomerMain'),
      view: (context) {
        final vm = context.watch<CustomerMainViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background, 
          body: SafeArea(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppRestaurantColors.primary))
                : Column(
                    children: [
                      _buildHeader(context, vm), // Tambahkan parameter vm ke header
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPromoBanner(),
                              const SizedBox(height: 24),
                              
                              // MENAMPILKAN KATEGORI SECARA DINAMIS
                              // Sistem akan meloop semua kategori yang ada di Database
                              if (vm.groupedMenus.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Text("Belum ada menu yang tersedia.", style: TextStyle(color: AppRestaurantColors.secondary)),
                                  ),
                                ),
                              ...vm.groupedMenus.entries.map((entry) {
                                String categoryName = entry.key;
                                List<MenuItem> menuItems = entry.value;
                                return _buildMenuSection(context, categoryName, menuItems);
                              }),

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

  // --- WIDGET BUILDERS (Hanya bagian yang berubah) ---

  Widget _buildHeader(BuildContext context, CustomerMainViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'RestaurantApp',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppRestaurantColors.primary)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: AppRestaurantColors.primary, borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: AppRestaurantColors.accent),
              onPressed: () => _showFilterBottomSheet(context, vm), // Passing VM ke BottomSheet
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
      decoration: BoxDecoration(color: AppRestaurantColors.secondary, borderRadius: BorderRadius.circular(16)),
      child: const Center(
        child: Text(
          'Banner Info Diskon\n(Ambil dari Storage/Remote Config nanti)',
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
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Menuju halaman See All: $title')));
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      // Jika nanti image_path terisi link Supabase Storage, ganti Icon ini dengan:
                      // child: Image.network(item.imageUrl, fit: BoxFit.cover),
                      child: const Center(child: Icon(Icons.fastfood, color: AppRestaurantColors.secondary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppRestaurantColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          // Gunakan getter formattedPrice
                          Text(item.formattedPrice, style: const TextStyle(color: AppRestaurantColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
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

  // MENAMPILKAN KATEGORI DINAMIS DI BOTTOM SHEET
  void _showFilterBottomSheet(BuildContext context, CustomerMainViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppRestaurantColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Filter by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
                const Divider(),
                // Loop dari data Kategori di database
                if (vm.filterCategories.isEmpty)
                   const Padding(padding: EdgeInsets.all(16), child: Text("Tidak ada kategori.")),
                ...vm.filterCategories.map((option) => ListTile(
                      title: Text(option, style: const TextStyle(color: AppRestaurantColors.primary)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppRestaurantColors.secondary),
                      onTap: () => Navigator.pop(ctx),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}