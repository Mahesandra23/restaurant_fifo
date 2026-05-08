import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/kitchen/ingredients/repository/ingredients_repository.dart';
import 'package:restaurant_fifo/pages/kitchen/ingredients/view_model/ingredients_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class IngredientsView extends StatelessWidget {
  const IngredientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<IngredientsViewModel>(
      viewModel: IngredientsViewModel(IngredientsRepository()),
      initOnce: true,
      key: const Key('IngredientsView'),
      view: (context) {
        final vm = context.watch<IngredientsViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,

          // APPBAR DIHAPUS, DIGANTI DENGAN TOMBOL MELAYANG INI:
          floatingActionButton: FloatingActionButton(
            heroTag:
                'addIngredientBtn', // heroTag penting agar tidak bentrok dengan halaman sebelah
            backgroundColor: AppRestaurantColors.primary,
            onPressed: () => _showAddIngredientSheet(context, vm),
            child: const Icon(Icons.add, color: AppRestaurantColors.accent),
          ),

          body: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppRestaurantColors.primary,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 80,
                  ), // Tambah bottom padding agar tidak tertutup tombol
                  itemCount: vm.groupedIngredients.keys.length,
                  itemBuilder: (context, index) {
                    String categoryName = vm.groupedIngredients.keys.elementAt(
                      index,
                    );
                    List<IngredientItem> items =
                        vm.groupedIngredients[categoryName]!;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: AppRestaurantColors.background,
                      elevation: 2,
                      shadowColor: AppRestaurantColors.primary.withOpacity(0.1),
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        key: ValueKey('$categoryName-${items.length}'),
                        backgroundColor: AppRestaurantColors.background,
                        collapsedBackgroundColor:
                            AppRestaurantColors.background,
                        iconColor: AppRestaurantColors.primary,
                        textColor: AppRestaurantColors.primary,
                        initiallyExpanded: true,
                        title: Text(
                          categoryName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppRestaurantColors.primary,
                          ),
                        ),
                        leading: const Icon(
                          Icons.folder_open,
                          color: AppRestaurantColors.primary,
                        ),
                        children: items.map((item) {
                          return Column(
                            key: ValueKey(item.id),
                            children: [
                              const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: AppRestaurantColors.secondary,
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 4,
                                ),
                                title: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppRestaurantColors.primary,
                                  ),
                                ),
                                subtitle: Text(
                                  item.id,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppRestaurantColors.secondary,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => vm.removeIngredient(item.id),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _showAddIngredientSheet(BuildContext context, IngredientsViewModel vm) {
    String name = '';
    String selectedCategory = vm.categories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah Bahan Baru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nama Bahan',
                      border: OutlineInputBorder(),
                      hintText: 'Contoh: Daging Sapi',
                    ),
                    onChanged: (val) => name = val,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: vm.categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCategory = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppRestaurantColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (name.trim().isNotEmpty) {
                          vm.addIngredient(name.trim(), selectedCategory);
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bahan berhasil ditambahkan!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'SIMPAN BAHAN',
                        style: TextStyle(
                          color: AppRestaurantColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
