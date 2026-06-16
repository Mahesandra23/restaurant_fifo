import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/services/saw_restock_service.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/kitchen/stocks/repository/stocks_repository.dart';
import 'package:restaurant_fifo/pages/kitchen/stocks/view_model/stocks_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/custom_empty_state.dart';
import 'package:restaurant_fifo/core/models/ingredients_model.dart'; // Pastikan import model bahan

class StockView extends StatelessWidget {
  const StockView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<StockViewModel>(
      viewModel: StockViewModel(StockRepository()),
      initOnce: true,
      key: const Key('StockView'),
      view: (context) {
        final vm = context.watch<StockViewModel>();

        return FocusDetector(
          onFocusGained: () {
            vm.fetchStockData();
          },
          child: Scaffold(
            backgroundColor: AppRestaurantColors.background,
            appBar: AppBar(
              title: const Text(
                'Restock Recommendations',
                style: TextStyle(
                  color: AppRestaurantColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppRestaurantColors.primary,
              centerTitle: true,
              elevation: 0,
            ),
            body: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppRestaurantColors.primary,
                    ),
                  )
                : RefreshIndicator(
                    color: AppRestaurantColors.primary,
                    onRefresh: () => vm.fetchStockData(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildWeightSliders(context, vm),
                        ),
                        if (vm.sawRecommendations.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: const CustomEmptyState(
                              icon: Icons.check_circle_outline,
                              message:
                                  'Stock is Safe!\nNo raw materials have reached the\nReorder Point limit yet.',
                              iconColor: AppRestaurantColors.accent,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              bottom: 40.h,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) => _buildResultCard(
                                  context,
                                  vm,
                                  vm.sawRecommendations[i],
                                ),
                                childCount: vm.sawRecommendations.length,
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

  Widget _buildWeightSliders(BuildContext context, StockViewModel vm) {
    // ... [Kode _buildWeightSliders persis sama seperti sebelumnya] ...
    double totalWeight = vm.weights.values.fold(0, (sum, val) => sum + val);
    bool isValid = (totalWeight * 100).round() == 100;

    return Card(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: AppRestaurantColors.accent),
      ),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.tune, color: AppRestaurantColors.primary),
          title: const Text(
            'Priority Weight Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppRestaurantColors.primary,
            ),
          ),
          subtitle: Text(
            'Current Total: ${(totalWeight * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: isValid ? AppRestaurantColors.secondary : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  backgroundColor: AppRestaurantColors.primary.withOpacity(
                    0.05,
                  ),
                  collapsedBackgroundColor: AppRestaurantColors.primary
                      .withOpacity(0.05),
                  tilePadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 0,
                  ),
                  childrenPadding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    bottom: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  leading: Icon(
                    Icons.lightbulb_outline,
                    color: AppRestaurantColors.primary,
                    size: 20.sp,
                  ),
                  title: Text(
                    'What is the purpose of these weights?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.primary,
                      fontSize: 14.sp,
                    ),
                  ),
                  children: [
                    Text(
                      'Weights determine the importance of each criterion when the system calculates which ingredients should be restocked first (Total must be exactly 100%):',
                      style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                    ),
                    SizedBox(height: 8.h),
                    _buildInfoText(
                      '• ABC (Usage Frequency):',
                      'How often the ingredient is used in the kitchen.',
                    ),
                    _buildInfoText(
                      '• FSN (Consumption Speed):',
                      'How fast the stock of this ingredient depletes.',
                    ),
                    _buildInfoText(
                      '• SDE (Sourcing Difficulty):',
                      'How difficult it is to find this item in the market.',
                    ),
                    _buildInfoText(
                      '• HML (Material Price):',
                      'How expensive the price of the ingredient is.',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: vm.weights.keys.map((key) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 40.w,
                        child: Text(
                          key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: vm.weights[key]!,
                          min: 0.0,
                          max: 1.0,
                          divisions: 20,
                          activeColor: AppRestaurantColors.primary,
                          label: '${(vm.weights[key]! * 100).toInt()}%',
                          onChanged: (val) {
                            vm.updateWeight(key, val);
                            vm.runSawSpk();
                          },
                          onChangeEnd: (val) async {
                            bool isSaved = await vm.saveCurrentWeightsToDb();

                            if (isSaved && context.mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Weights successfully saved!'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40.w,
                        child: Text('${(vm.weights[key]! * 100).toInt()}%'),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            if (!isValid)
              Padding(
                padding: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
                child: Text(
                  '*The total weight must be exactly 100% for the algorithm calculation to be accurate and saved.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String title, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 12.sp, color: Colors.black87),
          children: [
            TextSpan(
              text: '$title ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: desc),
          ],
        ),
      ),
    );
  }

  // Parameter ditambah `context` dan `vm` untuk meneruskan fungsi Restock
  Widget _buildResultCard(
    BuildContext context,
    StockViewModel vm,
    SawResult result,
  ) {
    final item = result.ingredient;
    final isCritical = item.currentStock <= item.reorderPoint;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppRestaurantColors.accent, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      // Dibungkus Material & InkWell agar tombol responsif dan memiliki animasi Ripple
      child: Material(
        color: AppRestaurantColors.accent2.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _showRestockBottomSheet(context, vm, item),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 45.w,
                  height: 45.h,
                  decoration: const BoxDecoration(
                    color: AppRestaurantColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${result.rank}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppRestaurantColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppRestaurantColors.primary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          _buildStockChip(
                            'Remaining: ${item.currentStock}',
                            isCritical ? Colors.red : Colors.orange,
                          ),
                          SizedBox(width: 4.w),
                          _buildStockChip(
                            'ROP: ${item.reorderPoint}',
                            Colors.grey,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Criteria: ABC(${item.abcClass}) HML(${item.hmlClass}) SDE(${item.sdeClass}) FSN(${item.fsnClass})',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppRestaurantColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Vi Score',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppRestaurantColors.secondary,
                      ),
                    ),
                    Text(
                      result.score.toStringAsFixed(3),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppRestaurantColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showRestockBottomSheet(
    BuildContext context,
    StockViewModel vm,
    IngredientModel ingredient,
  ) {
    double inputQuantity = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16.w,
            right: 16.w,
            top: 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Stock: ${ingredient.name}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.primary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Current Stock: ${ingredient.currentStock} ${ingredient.unit}', // Ditampilkan di sini
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppRestaurantColors.secondary,
                ),
              ),
              SizedBox(height: 24.h),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Quantity to Add',
                  // Menambahkan unit sebagai suffix agar user tahu satuan inputnya
                  suffixText: ingredient.unit,
                  suffixStyle: TextStyle(
                    color: AppRestaurantColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: AppRestaurantColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (val) {
                  inputQuantity = double.tryParse(val) ?? 0.0;
                },
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: 1.sw,
                height: 40.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppRestaurantColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () async {
                    if (inputQuantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Quantity must be greater than 0'),
                        ),
                      );
                      return;
                    }

                    // Mengirim objek ingredient utuh agar Repository bisa mengambil 'unit'
                    bool success = await vm.restockIngredient(
                      ingredient,
                      inputQuantity,
                    );

                    if (success && ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Successfully restocked $inputQuantity ${ingredient.unit} of ${ingredient.name}!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Update Stock',
                    style: TextStyle(
                      color: AppRestaurantColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}
