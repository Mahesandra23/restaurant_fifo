import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/kitchen/ingredients/repository/ingredients_repository.dart';
import 'package:restaurant_fifo/pages/kitchen/ingredients/view_model/ingredients_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/custom_empty_state.dart';

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

        return FocusDetector(
          onFocusGained: () {
            vm.fetchIngredients();
          },
          child: Scaffold(
            backgroundColor: AppRestaurantColors.background,
            floatingActionButton: FloatingActionButton(
              heroTag: 'addIngredientBtn',
              backgroundColor: AppRestaurantColors.primary,
              // Panggil sheet tanpa data untuk ADD
              onPressed: () => _showIngredientSheet(context, vm),
              child: const Icon(Icons.add, color: AppRestaurantColors.accent),
            ),
            body: SafeArea(
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppRestaurantColors.primary))
                  : vm.groupedIngredients.isEmpty
                      ? const CustomEmptyState(
                          icon: Icons.inventory_2_outlined,
                          message:
                              'There are no ingredients to display. Add new ingredients to manage your kitchen inventory.',
                          iconColor: AppRestaurantColors.secondary,
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 16, bottom: 100),
                          itemCount: vm.groupedIngredients.keys.length,
                          itemBuilder: (context, index) {
                            String categoryName =
                                vm.groupedIngredients.keys.elementAt(index);
                            List<IngredientItem> items =
                                vm.groupedIngredients[categoryName]!;

                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: AppRestaurantColors.background,
                              elevation: 2,
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
                                leading: const Icon(Icons.folder_open,
                                    color: AppRestaurantColors.primary),
                                children: items.map((item) {
                                  return Column(
                                    key: ValueKey(item.id),
                                    children: [
                                      Divider(
                                          height: 1,
                                          indent: 16,
                                          endIndent: 16,
                                          color: AppRestaurantColors.secondary),
                                      ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        title: Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppRestaurantColors.primary,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Stok saat ini: ${item.currentStock} ${item.unit}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppRestaurantColors.secondary,
                                          ),
                                        ),
                                        // Ubah trailing menjadi Row untuk tombol Edit & Delete
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Colors.blueAccent,
                                              ),
                                              // Panggil sheet dan lempar data item untuk EDIT
                                              onPressed: () => _showIngredientSheet(
                                                  context, vm,
                                                  ingredient: item),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Colors.redAccent),
                                              onPressed: () =>
                                                  vm.removeIngredient(item.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
            ),
          ),
        );
      },
    );
  }

  // Fungsi Sheet diubah agar bisa menerima opsional parameter ingredient
  void _showIngredientSheet(BuildContext context, IngredientsViewModel vm,
      {IngredientItem? ingredient}) {
    // Cek apakah ini mode Edit
    bool isEdit = ingredient != null;

    // Isi state dengan data existing jika mode Edit
    String name = ingredient?.name ?? '';
    String selectedCategory = ingredient?.category ?? vm.categories.first;
    String unit = ingredient?.unit ?? 'kg';
    double currentStock = ingredient?.currentStock ?? 0;
    double reorderPoint = ingredient?.reorderPoint ?? 0;
    String abcClass = ingredient?.abcClass ?? 'C';
    String hmlClass = ingredient?.hmlClass ?? 'L';
    String sdeClass = ingredient?.sdeClass ?? 'E';
    String fsnClass = ingredient?.fsnClass ?? 'N';

    InputDecoration buildInputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppRestaurantColors.primary),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 0.85 * MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Ingredient' : 'Add Ingredient & Parameters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppRestaurantColors.primary,
                      ),
                    ),
                    SizedBox(height: 24),

                    // Pakai TextFormField + initialValue agar data terisi otomatis
                    TextFormField(
                      initialValue: name,
                      decoration: buildInputDecoration('Ingredient Name'),
                      onChanged: (val) => name = val,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true, // Fix Overflow
                            value: selectedCategory,
                            decoration: buildInputDecoration('Category'),
                            items: vm.categories
                                .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat,
                                        overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedCategory = val!),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: unit,
                            decoration: buildInputDecoration('Unit'),
                            items: ['kg', 'gram', 'liter', 'ml', 'pcs', 'ikat']
                                .map((u) => DropdownMenuItem(
                                    value: u, child: Text(u)))
                                .toList(),
                            onChanged: (val) => setState(() => unit = val!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    const Text('Stock Settings',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppRestaurantColors.primary)),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: currentStock.toString(),
                            keyboardType: TextInputType.number,
                            readOnly: isEdit, // Disable di mode Edit
                            decoration: buildInputDecoration('Current Stock').copyWith(
                              fillColor: isEdit ? Colors.grey.shade200 : null,
                              filled: isEdit,
                            ),
                            onChanged: (val) =>
                                currentStock = double.tryParse(val) ?? 0,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: reorderPoint.toString(),
                            keyboardType: TextInputType.number,
                            decoration: buildInputDecoration('Reorder Point'),
                            onChanged: (val) =>
                                reorderPoint = double.tryParse(val) ?? 0,
                          ),
                        ),
                      ],
                    ),
                    if (isEdit)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '*Stok FIFO hanya dapat diubah melalui menu transaksi/penyesuaian stok.',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    SizedBox(height: 24),

                    const Text('Priority Criteria (SAW Method)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppRestaurantColors.primary)),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true, // Fix Overflow
                            value: abcClass,
                            decoration: buildInputDecoration('ABC (Usage)'),
                            items: const [
                              DropdownMenuItem(value: 'A', child: Text('A (High)')),
                              DropdownMenuItem(value: 'B', child: Text('B (Med)')),
                              DropdownMenuItem(value: 'C', child: Text('C (Low)')),
                            ],
                            onChanged: (val) => setState(() => abcClass = val!),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true, // Fix Overflow
                            value: hmlClass,
                            decoration: buildInputDecoration('HML (Price)'),
                            items: const [
                              DropdownMenuItem(value: 'H', child: Text('H (High)')),
                              DropdownMenuItem(value: 'M', child: Text('M (Med)')),
                              DropdownMenuItem(value: 'L', child: Text('L (Low)')),
                            ],
                            onChanged: (val) => setState(() => hmlClass = val!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true, // Fix Overflow
                            value: sdeClass,
                            decoration: buildInputDecoration('SDE (Scarcity)'),
                            items: const [
                              DropdownMenuItem(value: 'S', child: Text('S (Scarce)')),
                              DropdownMenuItem(value: 'D', child: Text('D (Diff)')),
                              DropdownMenuItem(value: 'E', child: Text('E (Easy)')),
                            ],
                            onChanged: (val) => setState(() => sdeClass = val!),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true, // Fix Overflow (Utama)
                            value: fsnClass,
                            decoration: buildInputDecoration('FSN (Movement)'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'F',
                                  child: Text('F (Fast)',
                                      overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(
                                  value: 'S',
                                  child: Text('S (Slow)',
                                      overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(
                                  value: 'N',
                                  child: Text('N (Non-moving)',
                                      overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: (val) => setState(() => fsnClass = val!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppRestaurantColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (name.trim().isNotEmpty) {
                            if (isEdit) {
                              vm.updateIngredient(
                                id: ingredient.id,
                                name: name.trim(),
                                category: selectedCategory,
                                unit: unit,
                                reorderPoint: reorderPoint,
                                abc: abcClass,
                                hml: hmlClass,
                                sde: sdeClass,
                                fsn: fsnClass,
                              );
                            } else {
                              vm.addIngredient(
                                name: name.trim(),
                                category: selectedCategory,
                                unit: unit,
                                currentStock: currentStock,
                                reorderPoint: reorderPoint,
                                abc: abcClass,
                                hml: hmlClass,
                                sde: sdeClass,
                                fsn: fsnClass,
                              );
                            }
                            
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEdit
                                    ? 'Ingredient updated successfully!'
                                    : 'Ingredient added successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: Text(
                          isEdit ? 'Save Changes' : 'Add Ingredient',
                          style: TextStyle(
                            color: AppRestaurantColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}