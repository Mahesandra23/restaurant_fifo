import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/view_model/menu_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<MenuViewModel>(
      viewModel: MenuViewModel(),
      initOnce: true,
      key: const Key('MenuView'),
      view: (context) {
        final vm = context.watch<MenuViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,
          appBar: AppBar(
            title: const Text('Manajemen Menu', style: TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.accent)),
            backgroundColor: AppRestaurantColors.primary,
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppRestaurantColors.accent, size: 28),
                onPressed: () => _showMenuForm(context, vm, null), 
              )
            ],
          ),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppRestaurantColors.primary))
              : vm.menus.isEmpty
                  ? const Center(child: Text('Belum ada menu. Silakan tambah baru.', style: TextStyle(color: AppRestaurantColors.secondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.menus.length,
                      itemBuilder: (context, index) {
                        final menu = vm.menus[index];
                        return _buildMenuCard(context, vm, menu);
                      },
                    ),
        );
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, MenuViewModel vm, MenuData menu) {
    return Card(
      key: ValueKey(menu.id),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppRestaurantColors.background,
      elevation: 3,
      shadowColor: AppRestaurantColors.primary.withOpacity(0.2),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            color: AppRestaurantColors.secondary.withOpacity(0.1),
            child: const Icon(Icons.fastfood, size: 50, color: AppRestaurantColors.secondary),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppRestaurantColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(menu.category, style: const TextStyle(fontSize: 12, color: AppRestaurantColors.secondary, fontWeight: FontWeight.bold)),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppRestaurantColors.secondary),
                          onPressed: () => _showMenuForm(context, vm, menu), 
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent), // Semantik bahaya
                          onPressed: () => _showDeleteDialog(context, vm, menu),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(menu.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
                const SizedBox(height: 4),
                Text(menu.description, style: const TextStyle(color: AppRestaurantColors.secondary, fontSize: 14)),
                const SizedBox(height: 16),
                
                const Text('Bahan yang digunakan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: menu.ingredients.map((ing) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppRestaurantColors.secondary.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(20),
                        color: AppRestaurantColors.accent2.withOpacity(0.3), // Akses 2 yang lebih lembut
                      ),
                      child: Text(ing.name, style: const TextStyle(fontSize: 11, color: AppRestaurantColors.primary, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, MenuViewModel vm, MenuData menu) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppRestaurantColors.background,
        title: const Text('Hapus Menu?', style: TextStyle(color: AppRestaurantColors.primary)),
        content: Text('Yakin ingin menghapus ${menu.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: AppRestaurantColors.secondary))),
          TextButton(
            onPressed: () {
              vm.deleteMenu(menu.id);
              Navigator.pop(ctx);
            }, 
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMenuForm(BuildContext context, MenuViewModel vm, MenuData? existingMenu) {
    final bool isEdit = existingMenu != null;
    String formName = isEdit ? existingMenu.name : '';
    String formDesc = isEdit ? existingMenu.description : '';
    String formCat = isEdit ? existingMenu.category : vm.menuCategories.first;
    
    List<String> selectedIngredientIds = isEdit 
        ? existingMenu.ingredients.map((e) => e.id).toList() 
        : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEdit ? 'Edit Menu' : 'Tambah Menu Baru', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: formName,
                          decoration: const InputDecoration(labelText: 'Nama Makanan', border: OutlineInputBorder()),
                          onChanged: (val) => formName = val,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: formCat,
                          decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                          items: vm.menuCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) => setState(() => formCat = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: formDesc,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Deskripsi Singkat', border: OutlineInputBorder()),
                    onChanged: (val) => formDesc = val,
                  ),
                  const SizedBox(height: 16),

                  const Text('Pilih Bahan Baku (Ingredients):', style: TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
                  const SizedBox(height: 8),
                  Container(
                    height: 150, 
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: vm.availableIngredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = vm.availableIngredients[index];
                          final isSelected = selectedIngredientIds.contains(ingredient.id);
                          
                          return CheckboxListTile(
                            title: Text(ingredient.name, style: const TextStyle(fontSize: 14)),
                            value: isSelected,
                            dense: true,
                            activeColor: AppRestaurantColors.primary, // Warna checkbox aktif
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedIngredientIds.add(ingredient.id);
                                } else {
                                  selectedIngredientIds.remove(ingredient.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppRestaurantColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        if (formName.trim().isEmpty) return;

                        final finalIngredients = vm.availableIngredients
                            .where((ing) => selectedIngredientIds.contains(ing.id))
                            .toList();

                        if (isEdit) {
                          vm.updateMenu(existingMenu.id, formName, formDesc, formCat, finalIngredients);
                        } else {
                          vm.addMenu(formName, formDesc, formCat, finalIngredients);
                        }
                        
                        Navigator.pop(context);
                      },
                      child: const Text('SIMPAN MENU', style: TextStyle(color: AppRestaurantColors.accent, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }
}