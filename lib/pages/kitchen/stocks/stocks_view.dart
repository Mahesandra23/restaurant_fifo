import 'package:flutter/material.dart';
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
                  color: AppRestaurantColors.accent,
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
                            padding: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              fontSize: 12,
            ),
          ),
          children: [
            // --- DROPDOWN INFO / EDUCATION BOX (MENGGUNAKAN EXPANSIONTILE) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Theme(
                // Menghilangkan garis pembatas bawaan khusus untuk dropdown internal ini
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  backgroundColor: AppRestaurantColors.primary.withOpacity(0.05),
                  collapsedBackgroundColor: AppRestaurantColors.primary.withOpacity(0.05),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  // Mengatur melengkungnya sudut border kotak info
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: const Icon(
                    Icons.lightbulb_outline, 
                    color: AppRestaurantColors.primary, 
                    size: 20
                  ),
                  title: const Text(
                    'What is the purpose of these weights?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: AppRestaurantColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  children: [
                    const Text(
                      'Weights determine the importance of each criterion when the system calculates which ingredients should be restocked first (Total must be exactly 100%):',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: vm.weights.keys.map((key) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        width: 40,
                        child: Text('${(vm.weights[key]! * 100).toInt()}%'),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            if (!isValid)
              const Padding(
                padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Text(
                  '*The total weight must be exactly 100% for the algorithm calculation to be accurate and saved.',
                  style: TextStyle(color: Colors.red, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String title, String desc) {
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

  Widget _buildResultCard(SawResult result) {
    final item = result.ingredient;
    final isCritical = item.currentStock <= item.reorderPoint;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: result.rank == 1 ? Colors.orange : AppRestaurantColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#${result.rank}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: result.rank == 1 ? Colors.white : AppRestaurantColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStockChip('Remaining: ${item.currentStock}', isCritical ? Colors.red : Colors.orange),
                      const SizedBox(width: 4),
                      _buildStockChip('ROP: ${item.reorderPoint}', Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Criteria: ABC(${item.abcClass}) HML(${item.hmlClass}) SDE(${item.sdeClass}) FSN(${item.fsnClass})',
                    style: const TextStyle(fontSize: 12, color: AppRestaurantColors.secondary),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text('Vi Score', style: TextStyle(fontSize: 10, color: AppRestaurantColors.secondary)),
                Text(
                  result.score.toStringAsFixed(3),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}