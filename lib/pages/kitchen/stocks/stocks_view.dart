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
                        // SLIVER 1: Weight Settings Header Box
                        SliverToBoxAdapter(
                          child: _buildWeightSliders(context, vm),
                        ),

                        // SLIVER 2: Empty State or Recommendation Data List
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
                            // Standarisasi padding layar: 16.0 (dengan ekstra ruang di bawah)
                            padding: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              bottom: 40.h,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) =>
                                    _buildResultCard(vm.sawRecommendations[i]),
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
    double totalWeight = vm.weights.values.fold(0, (sum, val) => sum + val);
    bool isValid = (totalWeight * 100).round() == 100;

    return Card(
      // Standarisasi margin layar: 16.0 dan Gap section: 24.0 (menuju ke list bawah)
      margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 24.h),
      shape: RoundedRectangleBorder(
        // Radius Medium standar: 12.0
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: AppRestaurantColors.accent,
        ),
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
            // --- DROPDOWN INFO / EDUCATION BOX ---
            Padding(
              // Standarisasi padding elemen internal: 16.0
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
                    // Radius Medium disamakan dengan standar: 12.0
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

            // --- SLIDERS ---
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
                                  backgroundColor: AppRestaurantColors.accent,
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

  Widget _buildResultCard(SawResult result) {
    final item = result.ingredient;
    final isCritical = item.currentStock <= item.reorderPoint;

    return Container(
      // Gap antar item list tetap aman di luar container
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        // 1. FILL COLOR (Warna Isi)
        color: AppRestaurantColors.accent2.withOpacity(0.05),

        // 2. RADIUS CORNER
        borderRadius: BorderRadius.circular(12.r),

        // 3. BORDER COLOR (Silakan sesuaikan warnanya sesuka Anda)
        border: Border.all(
          color: AppRestaurantColors.accent, // Contoh: border tipis warna primary
          width: 1.2,
        ),

        // 4. ELEVATION (Menggantikan elevation: 2 milik Card)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        // Padding internal tetap 16.0
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 45.w,
              height: 45.h,
              decoration: BoxDecoration(
                color:  AppRestaurantColors.accent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${result.rank}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color:  AppRestaurantColors.primary,
                  ),
                ),
              ),
            ),
            // Gap elemen horizontal standar: 16.0
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
                      _buildStockChip('ROP: ${item.reorderPoint}', Colors.grey),
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
}
