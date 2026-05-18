import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Tambahkan ScreenUtil
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
              onPressed: () => _showAddIngredientSheet(context, vm),
              child: const Icon(Icons.add, color: AppRestaurantColors.accent),
            ),
            // Menggunakan SafeArea untuk menghindari status bar HP
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
                          // Standarisasi padding layar: 16.0, bottom 100 agar aman dari FAB
                          padding: EdgeInsets.only(
                              left: 16.w, right: 16.w, top: 16.h, bottom: 100.h),
                          itemCount: vm.groupedIngredients.keys.length,
                          itemBuilder: (context, index) {
                            String categoryName =
                                vm.groupedIngredients.keys.elementAt(index);
                            List<IngredientItem> items =
                                vm.groupedIngredients[categoryName]!;

                            return Card(
                              // Gap vertikal antar Card List: 16.0
                              margin: EdgeInsets.only(bottom: 16.h),
                              shape: RoundedRectangleBorder(
                                // Radius Medium standar: 12.0
                                borderRadius: BorderRadius.circular(12.r),
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
                                          height: 1.h,
                                          indent: 16.w,
                                          endIndent: 16.w,
                                          color: AppRestaurantColors.secondary),
                                      ListTile(
                                        // Padding dalam item list standar: 16.0 horizontal
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                                horizontal: 16.w, vertical: 4.h),
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
                                            fontSize: 12.sp,
                                            color: AppRestaurantColors.secondary,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.redAccent),
                                          onPressed: () =>
                                              vm.removeIngredient(item.id),
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

    // Helper Dekorasi Input agar seragam dan rapi
    InputDecoration buildInputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppRestaurantColors.primary),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: RoundedRectangleBorder(
        // Radius Besar standar untuk BottomSheet: 16.0
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Widget buildBulletInfo(String title, String desc) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                    children: [
                      TextSpan(
                          text: '$title ',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: desc),
                    ],
                  ),
                ),
              );
            }

            return Container(
              height: 0.85.sh, // Menggunakan .sh
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                // Standarisasi padding Sheet: 16.0
                left: 16.w,
                right: 16.w,
                top: 16.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Ingredient & Parameters',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppRestaurantColors.primary,
                      ),
                    ),
                    // Gap judul ke form pertama: 24.0
                    SizedBox(height: 24.h),

                    // ==========================================
                    // --- 1. BASIC INFO ---
                    // ==========================================
                    TextField(
                      decoration: buildInputDecoration('Ingredient Name'),
                      onChanged: (val) => name = val,
                    ),
                    // Gap antar elemen form vertikal: 16.0
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
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
                        // Gap antar elemen form horizontal: 16.0
                        SizedBox(width: 16.w),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: unit,
                            decoration: buildInputDecoration('Unit'),
                            items: ['kg', 'gram', 'liter', 'ml', 'pcs', 'ikat']
                                .map((u) =>
                                    DropdownMenuItem(value: u, child: Text(u)))
                                .toList(),
                            onChanged: (val) => setState(() => unit = val!),
                          ),
                        ),
                      ],
                    ),
                    // Gap antar section utama (Basic ke Stock): 24.0
                    SizedBox(height: 24.h),

                    // ==========================================
                    // --- 2. STOCK INFO & INPUT ---
                    // ==========================================
                    const Text('Stock Settings',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppRestaurantColors.primary)),
                    // Gap judul sub-section ke elemen: 16.0
                    SizedBox(height: 16.h),

                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        backgroundColor:
                            AppRestaurantColors.primary.withOpacity(0.05),
                        collapsedBackgroundColor:
                            AppRestaurantColors.primary.withOpacity(0.05),
                        tilePadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 0),
                        childrenPadding: EdgeInsets.only(
                            left: 16.w, right: 16.w, bottom: 16.h),
                        shape: RoundedRectangleBorder(
                          // Radius Medium standar: 12.0
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        leading: Icon(Icons.lightbulb_outline,
                            color: AppRestaurantColors.primary, size: 20.sp),
                        title: Text(
                          'What is the Reorder Point (ROP)?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppRestaurantColors.primary,
                              fontSize: 13.sp),
                        ),
                        children: [
                          Text(
                            'The Reorder Point is the minimum safety stock level. When current stock drops below this number, the system will automatically alert you to restock the ingredient before it runs out completely.',
                            style:
                                TextStyle(fontSize: 12.sp, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    // Gap antar elemen vertikal: 16.0
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: buildInputDecoration('Current Stock'),
                            onChanged: (val) =>
                                currentStock = double.tryParse(val) ?? 0,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: buildInputDecoration('Reorder Point'),
                            onChanged: (val) =>
                                reorderPoint = double.tryParse(val) ?? 0,
                          ),
                        ),
                      ],
                    ),
                    // Gap antar section utama (Stock ke SAW): 24.0
                    SizedBox(height: 24.h),

                    // ==========================================
                    // --- 3. SAW CRITERIA INFO & INPUT ---
                    // ==========================================
                    const Text('Priority Criteria (SAW Method)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppRestaurantColors.primary)),
                    SizedBox(height: 16.h),

                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        backgroundColor:
                            AppRestaurantColors.primary.withOpacity(0.05),
                        collapsedBackgroundColor:
                            AppRestaurantColors.primary.withOpacity(0.05),
                        tilePadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 0),
                        childrenPadding: EdgeInsets.only(
                            left: 16.w, right: 16.w, bottom: 16.h),
                        shape: RoundedRectangleBorder(
                          // Radius Medium standar: 12.0
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        leading: Icon(Icons.lightbulb_outline,
                            color: AppRestaurantColors.primary, size: 20.sp),
                        title: Text(
                          'How to classify these parameters?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppRestaurantColors.primary,
                              fontSize: 13.sp),
                        ),
                        children: [
                          Text(
                            'Select the appropriate metrics for this ingredient. The DSS algorithm uses these values to calculate priority rankings:',
                            style:
                                TextStyle(fontSize: 12.sp, color: Colors.black87),
                          ),
                          SizedBox(height: 8.h),
                          buildBulletInfo('• ABC (Usage):',
                              'A (High kitchen usage), B (Medium), C (Low/Rare).'),
                          buildBulletInfo('• HML (Price):',
                              'H (High/Expensive), M (Medium), L (Low/Cheap).'),
                          buildBulletInfo('• SDE (Scarcity):',
                              'S (Scarce/Hard to find), D (Difficult), E (Easy to buy).'),
                          buildBulletInfo('• FSN (Movement):',
                              'F (Fast depletion), S (Slow depletion), N (Non-moving).'),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: abcClass,
                            decoration: buildInputDecoration('ABC (Usage)'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'A', child: Text('A (High)')),
                              DropdownMenuItem(
                                  value: 'B', child: Text('B (Medium)')),
                              DropdownMenuItem(
                                  value: 'C', child: Text('C (Low)')),
                            ],
                            onChanged: (val) =>
                                setState(() => abcClass = val!),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: hmlClass,
                            decoration: buildInputDecoration('HML (Price)'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'H', child: Text('H (High)')),
                              DropdownMenuItem(
                                  value: 'M', child: Text('M (Medium)')),
                              DropdownMenuItem(
                                  value: 'L', child: Text('L (Low)')),
                            ],
                            onChanged: (val) =>
                                setState(() => hmlClass = val!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: sdeClass,
                            decoration: buildInputDecoration('SDE (Scarcity)'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'S', child: Text('S (Scarce)')),
                              DropdownMenuItem(
                                  value: 'D', child: Text('D (Difficult)')),
                              DropdownMenuItem(
                                  value: 'E', child: Text('E (Easy)')),
                            ],
                            onChanged: (val) =>
                                setState(() => sdeClass = val!),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: fsnClass,
                            decoration: buildInputDecoration('FSN (Movement)'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'F', child: Text('F (Fast)')),
                              DropdownMenuItem(
                                  value: 'S', child: Text('S (Slow)')),
                              DropdownMenuItem(
                                  value: 'N', child: Text('N (Non-moving)')),
                            ],
                            onChanged: (val) =>
                                setState(() => fsnClass = val!),
                          ),
                        ),
                      ],
                    ),
                    // Gap antar section utama (SAW ke Tombol Save): 24.0
                    SizedBox(height: 24.h),

                    // ==========================================
                    // --- SAVE BUTTON ---
                    // ==========================================
                    SizedBox(
                      width: 1.sw, // Mengubah double.infinity menjadi 1.sw
                      // Standarisasi Tinggi Tombol: 55.0
                      height: 40.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppRestaurantColors.primary,
                          shape: RoundedRectangleBorder(
                            // Radius Medium standar tombol: 12.0
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          if (name.trim().isNotEmpty) {
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
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Ingredient and parameters for restock added successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Add Ingredient',
                          style: TextStyle(
                            color: AppRestaurantColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
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