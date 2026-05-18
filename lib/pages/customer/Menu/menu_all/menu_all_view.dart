import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_all/repository/menu_all_repository.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_all/view_model/menu_all_view_model.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_detail/menu_detail_view.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/widget/show_menu_form.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/menu_card_widget.dart';

class MenuAllView extends StatelessWidget {
  final String categoryName;

  final bool isKitchen;
  final dynamic kitchenVm;

  const MenuAllView({
    super.key,
    required this.categoryName,
    this.isKitchen = false, 
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
            backgroundColor: AppRestaurantColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppRestaurantColors.background, // Warna accent agar seragam
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              categoryName,
              style: const TextStyle(
                color: AppRestaurantColors.background,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Gap standar dari AppBar ke konten pertama (Search Bar): 16.0
              SizedBox(height: 16.h),

              // Search Bar
              Padding(
                // Standarisasi padding horizontal layar: 16.0
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  onChanged: vm.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari menu $categoryName...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppRestaurantColors.secondary,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 0.h),
                    border: OutlineInputBorder(
                      // Radius Medium standar: 12.0
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: AppRestaurantColors.primary,
                      ),
                    ),
                  ),
                ),
              ),

              // Gap standar antar section (Search Bar ke Grid Menu): 24.0
              SizedBox(height: 24.h),

              // Grid Daftar Makanan
              Expanded(
                child: vm.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppRestaurantColors.primary,
                        ),
                      )
                    : vm.menus.isEmpty
                        ? const Center(
                            child: Text(
                              'Menu tidak ditemukan.',
                              style: TextStyle(
                                color: AppRestaurantColors.secondary,
                              ),
                            ),
                          )
                        : GridView.builder(
                            // Padding kiri-kanan 16.0, ditambah padding bawah ekstra 40.0
                            padding: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              bottom: 40.h,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              // Gap antar elemen standar: 16.0
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
                            ),
                            itemCount: vm.menus.length,
                            itemBuilder: (context, index) {
                              final item = vm.menus[index];
                              return MenuCardWidget(
                                name: item.name,
                                formattedPrice: item.formattedPrice, 
                                imageUrl: item.imageUrl,
                                onTap: () {
                                  if (isKitchen && kitchenVm != null) {
                                    // 1. AKSI JIKA YANG MENGKLIK ADALAH KOKI / ADMIN DAPUR
                                    if (kitchenVm.categories.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Buat Kategori terlebih dahulu!',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor:
                                          AppRestaurantColors.background,
                                      shape: RoundedRectangleBorder(
                                        // Radius Besar standar untuk BottomSheet: 16.0
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16.r),
                                        ),
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
                                        builder: (context) =>
                                            MenuDetailView(menu: item),
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