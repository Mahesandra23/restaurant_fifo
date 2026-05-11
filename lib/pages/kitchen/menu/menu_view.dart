import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_all/menu_all_view.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/repository/menu_repository.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/view_model/menu_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/widget/show_menu_form.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/menu_card_widget.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<MenuViewModel>(
      viewModel: MenuViewModel(MenuRepository()),
      initOnce: true,
      key: const Key('MenuView'),
      view: (context) {
        final vm = context.watch<MenuViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,

          // APPBAR DIHAPUS, DIGANTI 2 TOMBOL MELAYANG INI:
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Tombol Kelola Kategori (Kecil)
              FloatingActionButton(
                heroTag: 'manageCategoryBtn',
                backgroundColor: AppRestaurantColors.secondary,
                mini: true,
                onPressed: () => _showCategoryManager(context, vm),
                child: const Icon(
                  Icons.category,
                  color: AppRestaurantColors.accent,
                ),
              ),
              const SizedBox(height: 12),
              // Tombol Tambah Menu (Besar)
              FloatingActionButton(
                heroTag: 'addMenuBtn',
                backgroundColor: AppRestaurantColors.primary,
                onPressed: () {
                  // --- PEMANGGILAN BOTTOM SHEET WIDGET LANGSUNG DI SINI ---

                  // 1. Cek dulu apakah kategori sudah ada
                  if (vm.categories.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Buat Kategori terlebih dahulu!'),
                      ),
                    );
                    return; // Hentikan eksekusi jika kategori kosong
                  }

                  // 2. Tampilkan Bottom Sheet
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled:
                        true, // Penting agar bisa full screen dan tidak tertutup keyboard
                    backgroundColor: AppRestaurantColors.background,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      // 3. Panggil widget yang sudah kita pisahkan tadi
                      return MenuFormBottomSheet(
                        vm: vm,
                        // existingMenu TIDAK PERLU dikirim (atau kirim null),
                        // karena ini untuk membuat menu BARU, bukan mengedit.
                      );
                    },
                  );
                },
                child: const Icon(Icons.add, color: AppRestaurantColors.accent),
              ),
            ],
          ),

          body: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppRestaurantColors.primary,
                  ),
                )
              : Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(
                      child: vm.groupedMenus.isEmpty
                          ? const Center(
                              child: Text(
                                'Belum ada menu.',
                                style: TextStyle(
                                  color: AppRestaurantColors.secondary,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                top: 16.0,
                                bottom: 80.0,
                              ), // Padding bawah agar list tidak tertutup tombol
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: vm.groupedMenus.entries.map((entry) {
                                  return _buildMenuSection(
                                    context,
                                    vm,
                                    entry.key,
                                    entry.value,
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari menu untuk diubah...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppRestaurantColors.secondary,
          ),
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
    );
  }

  // --- STYLE CUSTOMER (HORIZONTAL SCROLL) ---
  Widget _buildMenuSection(
    BuildContext context,
    MenuViewModel vm,
    String title,
    List<MenuModel> items,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppRestaurantColors.primary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MenuAllView(
                      categoryName: title,
                      isKitchen: true,
                      kitchenVm: vm,
                    ),
                  ),
                );
              },
              child: const Text(
                'See all',
                style: TextStyle(color: AppRestaurantColors.secondary),
              ),
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
                child: MenuCardWidget(
                  name: item.name,
                  formattedPrice: 'Rp ${item.price}',
                  imageUrl: item.imageUrl,
                  onTap: () {
                    // --- PEMANGGILAN BOTTOM SHEET WIDGET LANGSUNG DI SINI ---

                    // 1. Cek dulu apakah kategori sudah ada
                    if (vm.categories.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Buat Kategori terlebih dahulu!'),
                        ),
                      );
                      return; // Hentikan eksekusi jika kategori kosong
                    }

                    // 2. Tampilkan Bottom Sheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled:
                          true, // Penting agar bisa full screen dan tidak tertutup keyboard
                      backgroundColor: AppRestaurantColors.background,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        // 3. Panggil widget yang sudah kita pisahkan tadi
                        return MenuFormBottomSheet(
                          vm: vm,
                          existingMenu:
                              item, // Lempar item yang diklik sebagai existingMenu (Mode Edit)
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ==========================================
  // BOTTOM SHEET KELOLA KATEGORI
  // ==========================================
  void _showCategoryManager(BuildContext context, MenuViewModel vm) {
    String newCategoryName = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kelola Kategori',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Form Tambah Kategori
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nama Kategori Baru',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (val) => newCategoryName = val,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppRestaurantColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (newCategoryName.trim().isNotEmpty) {
                        vm.addCategory(newCategoryName.trim());
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text(
                      'Tambah',
                      style: TextStyle(color: AppRestaurantColors.accent),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Daftar Kategori
              const Text(
                'Daftar Kategori Saat Ini:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.secondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: vm.categories.length,
                  itemBuilder: (context, index) {
                    final cat = vm.categories[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(cat.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          vm.deleteCategory(cat.id);
                          Navigator.pop(ctx);
                        },
                      ),
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
