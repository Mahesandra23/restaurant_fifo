import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/kitchen/history/repository/banner_repository.dart';
import 'package:restaurant_fifo/pages/kitchen/history/view_model/history_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<HistoryViewModel>(
      viewModel: HistoryViewModel(HistoryRepository()),
      initOnce: true,
      key: const Key('HistoryView'),
      view: (context) {
        final vm = context.watch<HistoryViewModel>();

        return FocusDetector(
          onFocusGained: () => vm.fetchData(),
          child: Scaffold(
            backgroundColor: AppRestaurantColors.background,
            appBar: AppBar(
              title: const Text('Order History', style: TextStyle(color: AppRestaurantColors.accent)),
              backgroundColor: AppRestaurantColors.primary,
            ),
            body: Column(
              children: [
                _buildFilters(vm),
                _buildRevenueCard(vm.formattedTotalRevenue),
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppRestaurantColors.primary))
                      : vm.orders.isEmpty
                          ? const Center(child: Text('No completed orders found.', style: TextStyle(color: AppRestaurantColors.secondary)))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: vm.orders.length,
                              itemBuilder: (ctx, i) {
                                final order = vm.orders[i];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.receipt_long, color: AppRestaurantColors.primary),
                                    title: Text('Order #${order['id'].toString().substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(order['created_at'].toString().split('T').first), // Simple date format
                                    trailing: Text(
                                      order['formatted_price'],
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters(HistoryViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
              value: vm.selectedYear,
              items: vm.availableYears.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
              onChanged: (val) => vm.updateFilter(year: val),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder()),
              value: vm.selectedMonth,
              items: vm.availableMonths.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (val) => vm.updateFilter(month: val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(String formattedRevenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: AppRestaurantColors.primary.withOpacity(0.1),
      child: Column(
        children: [
          const Text('Total Revenue', style: TextStyle(fontSize: 14, color: AppRestaurantColors.primary)),
          const SizedBox(height: 8),
          Text(
            formattedRevenue,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary),
          ),
        ],
      ),
    );
  }
}