import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_all/menu_all_view.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/repository/menu_repository.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/view_model/menu_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/widget/show_menu_form.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/custom_empty_state.dart';
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

        return FocusDetector(
          onFocusGained: () {
            vm.fetchInitialData();
          },
          child: Scaffold(
            backgroundColor: AppRestaurantColors.background,

            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'addMenuBtn',
                  backgroundColor: AppRestaurantColors.primary,
                  onPressed: () {
                    if (vm.categories.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please create a category first!'),
                        ),
                      );
                      return;
                    }

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppRestaurantColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (context) {
                        return MenuFormBottomSheet(vm: vm);
                      },
                    );
                  },
                  child: const Icon(
                    Icons.add,
                    color: AppRestaurantColors.accent,
                  ),
                ),
              ],
            ),

            body: SafeArea(
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppRestaurantColors.primary,
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(height: 16),
                        // Menghubungkan Search Bar ke ViewModel
                        _buildSearchBar(vm),
                        SizedBox(height: 16),
                        Expanded(
                          child: vm.groupedMenus.isEmpty
                              ? CustomEmptyState(
                                  // Icon berubah dinamis jika query search tidak menemukan hasil
                                  icon: vm.searchQuery.isEmpty
                                      ? Icons.restaurant_menu
                                      : Icons.search_off,
                                  message: vm.searchQuery.isEmpty
                                      ? 'There are no menus available yet.'
                                      : 'No menus found for "${vm.searchQuery}".',
                                  iconColor: AppRestaurantColors.secondary,
                                )
                              : SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: 100,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: vm.groupedMenus.entries.map((
                                      entry,
                                    ) {
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
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET PENCARIAN (SEARCH BAR) ---
  Widget _buildSearchBar(MenuViewModel vm) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 45,
        child: TextField(
          onChanged: (value) => vm.searchMenu(value), // Terhubung ke ViewModel
          decoration: InputDecoration(
            hintText: 'Search menus to edit...',
            prefixIcon: const Icon(
              Icons.search,
              color: AppRestaurantColors.secondary,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppRestaurantColors.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppRestaurantColors.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppRestaurantColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  // --- STYLE ADMIN KITCHEN (HORIZONTAL SCROLL) ---
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
              style: TextStyle(
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
                'See all ➔',
                style: TextStyle(color: AppRestaurantColors.secondary),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 130,
                margin: EdgeInsets.only(right: 16, bottom: 8),
                decoration: BoxDecoration(
                  color: AppRestaurantColors.background,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: MenuCardWidget(
                  name: item.name,
                  formattedPrice: vm.formatRupiah(item.price), // Format harga
                  imageUrl: item.imageUrl,
                  onTap: () {
                    if (vm.categories.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please create a category first!'),
                        ),
                      );
                      return;
                    }

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppRestaurantColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (context) {
                        return MenuFormBottomSheet(vm: vm, existingMenu: item);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  // --- BOTTOM SHEET KELOLA KATEGORI ---
// --- BOTTOM SHEET KELOLA KATEGORI ---
  void _showCategoryManager(BuildContext context, MenuViewModel vm) {
    String newCategoryName = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.primary,
                ),
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'New Category Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                        ),
                        onChanged: (val) => newCategoryName = val,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    height: 35,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppRestaurantColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () {
                        if (newCategoryName.trim().isNotEmpty) {
                          vm.addCategory(newCategoryName.trim());
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text(
                        'Add Category',
                        style: TextStyle(
                          color: AppRestaurantColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 32),
              const Text(
                'Manage Categories (Hold & Drag to Reorder):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.secondary,
                ),
              ),
              SizedBox(height: 8),
              
              // MENGGUNAKAN REORDERABLE LIST VIEW
              SizedBox(
                height: 250, // Ditinggikan sedikit agar lebih leluasa saat menggeser
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  itemCount: vm.categories.length,
                  onReorder: (oldIndex, newIndex) {
                    vm.reorderCategories(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final cat = vm.categories[index];
                    return ListTile(
                      // KEY WAJIB ADA UNTUK REORDERABLE LIST
                      key: ValueKey(cat.id), 
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.drag_handle, color: Colors.grey),
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
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
