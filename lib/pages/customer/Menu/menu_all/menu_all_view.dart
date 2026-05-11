import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_all/repository/menu_all_repository.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_all/view_model/menu_all_view_model.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_detail/menu_detail_view.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/widget/show_menu_form.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/menu_card_widget.dart';

// PASTIKAN ANDA MENG-IMPORT FILE BOTTOM SHEET KITCHEN DI SINI:
// import 'package:restaurant_fifo/pages/kitchen/menu/widgets/menu_form_bottom_sheet.dart'; 

class MenuAllView extends StatelessWidget {
  final String categoryName; 
  
  // --- PARAMETER BARU UNTUK MEMBEDAKAN ROLE ---
  final bool isKitchen; 
  final dynamic kitchenVm;

  const MenuAllView({
    super.key, 
    required this.categoryName,
    this.isKitchen = false, // Nilai bawaannya false (Sebagai Customer)
    this.kitchenVm,
  });

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<MenuAllViewModel>(
      viewModel: MenuAllViewModel(MenuAllRepository(), categoryName),
      initOnce: true,
      key: const Key('MenuAllView'),
      view: (context) {
        final vm = context.watch<MenuAllViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,
          appBar: AppBar(
            backgroundColor: AppRestaurantColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppRestaurantColors.primary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              categoryName,
              style: const TextStyle(color: AppRestaurantColors.primary, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  onChanged: vm.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari menu $categoryName...',
                    prefixIcon: const Icon(Icons.search, color: AppRestaurantColors.secondary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
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

              // Grid Daftar Makanan
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppRestaurantColors.primary))
                    : vm.menus.isEmpty
                    ? const Center(
                        child: Text('Menu tidak ditemukan.', style: TextStyle(color: AppRestaurantColors.secondary)),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          childAspectRatio: 0.8, 
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: vm.menus.length,
                        itemBuilder: (context, index) {
                          final item = vm.menus[index];
                          return MenuCardWidget(
                            name: item.name,
                            formattedPrice: item.formattedPrice, // Jika model Anda masih berbentuk string, ganti 'Rp ${item.price}'
                            imageUrl: item.imageUrl,
                            
                            // --- LOGIKA PERCABANGAN ROLE (KITCHEN VS CUSTOMER) ---
                            onTap: () {
                              if (isKitchen && kitchenVm != null) {
                                // 1. AKSI JIKA YANG MENGKLIK ADALAH KOKI / ADMIN DAPUR
                                if (kitchenVm.categories.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Buat Kategori terlebih dahulu!')),
                                  );
                                  return;
                                }

                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: AppRestaurantColors.background,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (context) {
                                    return MenuFormBottomSheet(
                                      vm: kitchenVm,
                                      existingMenu: item,
                                    );
                                  },
                                ).then((_) {
                                  vm.fetchMenus(); 
                                });
                              } else {
                                // 2. AKSI JIKA YANG MENGKLIK ADALAH PELANGGAN (DEFAULT)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MenuDetailView(
                                      menu: item,
                                    ), 
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}