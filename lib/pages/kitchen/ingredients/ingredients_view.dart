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
            // 3. PANGGIL FUNGSI FETCH SAAT HALAMAN KEMBALI MUNCUL
            vm.fetchIngredients();
          },
          child:Scaffold(
          backgroundColor: AppRestaurantColors.background,
          floatingActionButton: FloatingActionButton(
            heroTag: 'addIngredientBtn', 
            backgroundColor: AppRestaurantColors.primary,
            onPressed: () => _showAddIngredientSheet(context, vm),
            child: const Icon(Icons.add, color: AppRestaurantColors.accent),
          ),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppRestaurantColors.primary))
              // --- TAMBAHKAN PENGECEKAN EMPTY STATE DI SINI ---
              : vm.groupedIngredients.isEmpty
                  ? const CustomEmptyState(
                      icon: Icons.inventory_2_outlined,
                      message: 'There are no ingredients to display. Add new ingredients to manage your kitchen inventory.',
                      iconColor: AppRestaurantColors.secondary,
                    )
                  // Jika ada data, tampilkan ListView
                  : ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80), 
                  itemCount: vm.groupedIngredients.keys.length,
                  itemBuilder: (context, index) {
                    String categoryName = vm.groupedIngredients.keys.elementAt(index);
                    List<IngredientItem> items = vm.groupedIngredients[categoryName]!;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: AppRestaurantColors.background,
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        key: ValueKey('$categoryName-${items.length}'),
                        backgroundColor: AppRestaurantColors.background,
                        collapsedBackgroundColor: AppRestaurantColors.background,
                        iconColor: AppRestaurantColors.primary,
                        textColor: AppRestaurantColors.primary,
                        initiallyExpanded: true,
                        title: Text(categoryName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
                        leading: const Icon(Icons.folder_open, color: AppRestaurantColors.primary),
                        children: items.map((item) {
                          return Column(
                            key: ValueKey(item.id),
                            children: [
                              const Divider(height: 1, indent: 16, endIndent: 16, color: AppRestaurantColors.secondary),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
                                // Tampilkan sisa stok di layar ini agar informatif
                                subtitle: Text('Stok saat ini: ${item.currentStock} ${item.unit}', style: const TextStyle(fontSize: 12, color: AppRestaurantColors.secondary)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
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
          ),
        );
      },
    );
  }

  void _showAddIngredientSheet(BuildContext context, IngredientsViewModel vm) {
    String name = '';
    String selectedCategory = vm.categories.first;
    String unit = 'kg'; // Default
    
    // Variabel Input Stok
    double currentStock = 0;
    double reorderPoint = 0;

    // Variabel SAW MCDM
    String abcClass = 'C';
    String hmlClass = 'L';
    String sdeClass = 'E';
    String fsnClass = 'N';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Bolehkan bottom sheet penuh
      backgroundColor: AppRestaurantColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            
            // Helper widget untuk merapikan teks list di dalam dropdown info
            Widget buildBulletInfo(String title, String desc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    children: [
                      TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: desc),
                    ],
                  ),
                ),
              );
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85, // 85% dari layar
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Hindari keyboard
                left: 20, right: 20, top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Ingredient & Parameters for Restock', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)
                    ),
                    const SizedBox(height: 20),

                    // ==========================================
                    // --- 1. BASIC INFO ---
                    // ==========================================
                    TextField(
                      decoration: const InputDecoration(labelText: 'Ingredient Name', border: OutlineInputBorder()),
                      onChanged: (val) => name = val,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                            items: vm.categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (val) => setState(() => selectedCategory = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: unit,
                            decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                            items: ['kg', 'gram', 'liter', 'ml', 'pcs', 'ikat'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (val) => setState(() => unit = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ==========================================
                    // --- 2. STOCK INFO & INPUT ---
                    // ==========================================
                    const Text('Stock Settings', style: TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
                    const SizedBox(height: 8),
                    
                    // --- DROPDOWN INFO: REORDER POINT ---
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        backgroundColor: AppRestaurantColors.primary.withOpacity(0.05),
                        collapsedBackgroundColor: AppRestaurantColors.primary.withOpacity(0.05),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        leading: const Icon(Icons.lightbulb_outline, color: AppRestaurantColors.primary, size: 20),
                        title: const Text(
                          'What is the Reorder Point (ROP)?',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.primary, fontSize: 13),
                        ),
                        children: const [
                          Text(
                            'The Reorder Point is the minimum safety stock level. When current stock drops below this number, the system will automatically alert you to restock the ingredient before it runs out completely.',
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Current Stock', border: OutlineInputBorder()),
                            onChanged: (val) => currentStock = double.tryParse(val) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Reorder Point', border: OutlineInputBorder()),
                            onChanged: (val) => reorderPoint = double.tryParse(val) ?? 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ==========================================
                    // --- 3. SAW CRITERIA INFO & INPUT ---
                    // ==========================================
                    const Text('Priority Criteria (SAW Method)', style: TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
                    const SizedBox(height: 8),

                    // --- DROPDOWN INFO: SAW CRITERIA ---
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        backgroundColor: AppRestaurantColors.primary.withOpacity(0.05),
                        collapsedBackgroundColor: AppRestaurantColors.primary.withOpacity(0.05),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        leading: const Icon(Icons.lightbulb_outline, color: AppRestaurantColors.primary, size: 20),
                        title: const Text(
                          'How to classify these parameters?',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.primary, fontSize: 13),
                        ),
                        children: [
                          const Text(
                            'Select the appropriate metrics for this ingredient. The DSS algorithm uses these values to calculate priority rankings:',
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          buildBulletInfo('• ABC (Usage):', 'A (High kitchen usage), B (Medium), C (Low/Rare).'),
                          buildBulletInfo('• HML (Price):', 'H (High/Expensive), M (Medium), L (Low/Cheap).'),
                          buildBulletInfo('• SDE (Scarcity):', 'S (Scarce/Hard to find), D (Difficult), E (Easy to buy).'),
                          buildBulletInfo('• FSN (Movement):', 'F (Fast depletion), S (Slow depletion), N (Non-moving).'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: abcClass,
                            decoration: const InputDecoration(labelText: 'ABC (Usage)', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'A', child: Text('A (High)')),
                              DropdownMenuItem(value: 'B', child: Text('B (Medium)')),
                              DropdownMenuItem(value: 'C', child: Text('C (Low)')),
                            ],
                            onChanged: (val) => setState(() => abcClass = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: hmlClass,
                            decoration: const InputDecoration(labelText: 'HML (Price)', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'H', child: Text('H (High)')),
                              DropdownMenuItem(value: 'M', child: Text('M (Medium)')),
                              DropdownMenuItem(value: 'L', child: Text('L (Low)')),
                            ],
                            onChanged: (val) => setState(() => hmlClass = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: sdeClass,
                            decoration: const InputDecoration(labelText: 'SDE (Scarcity)', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'S', child: Text('S (Scarce)')),
                              DropdownMenuItem(value: 'D', child: Text('D (Difficult)')),
                              DropdownMenuItem(value: 'E', child: Text('E (Easy)')),
                            ],
                            onChanged: (val) => setState(() => sdeClass = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: fsnClass,
                            decoration: const InputDecoration(labelText: 'FSN (Movement)', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'F', child: Text('F (Fast)')),
                              DropdownMenuItem(value: 'S', child: Text('S (Slow)')),
                              DropdownMenuItem(value: 'N', child: Text('N (Non-moving)')),
                            ],
                            onChanged: (val) => setState(() => fsnClass = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // ==========================================
                    // --- SAVE BUTTON ---
                    // ==========================================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppRestaurantColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (name.trim().isNotEmpty) {
                            vm.addIngredient(
                              name: name.trim(),
                              category: selectedCategory,
                              unit: unit,
                              currentStock: currentStock,
                              reorderPoint: reorderPoint,
                              abc: abcClass, hml: hmlClass, sde: sdeClass, fsn: fsnClass,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ingredient and parameters for restock added successfully!'), 
                                backgroundColor: Colors.green
                              )
                            );
                          }
                        },
                        child: const Text('Add Ingredient', style: TextStyle(color: AppRestaurantColors.accent, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 30),
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