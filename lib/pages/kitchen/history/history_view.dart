import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Tambahkan ScreenUtil
import 'package:provider/provider.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/kitchen/history/repository/banner_repository.dart';
import 'package:restaurant_fifo/pages/kitchen/history/view_model/history_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/custom_empty_state.dart';

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
              title: const Text(
                'Order History',
                style: TextStyle(
                  color: AppRestaurantColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppRestaurantColors.primary,
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppRestaurantColors.background),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                // Gap awal dari AppBar: 16.0
                SizedBox(height: 16.h),
                _buildFilters(vm),
                
                // Gap antar section utama (Filter ke Revenue Card): 24.0
                SizedBox(height: 24.h),
                _buildRevenueCard(vm.formattedTotalRevenue),
                
                // Gap antar section utama (Revenue Card ke List): 24.0
                SizedBox(height: 24.h),
                
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppRestaurantColors.primary))
                      : vm.orders.isEmpty
                          ? const CustomEmptyState(
                              icon: Icons.receipt_long_outlined,
                              message: 'No completed orders found.',
                              iconColor: AppRestaurantColors.secondary,
                            )
                          : ListView.builder(
                              // Standarisasi padding layar utama: 16.0
                              padding: EdgeInsets.only(
                                left: 16.w,
                                right: 16.w,
                                bottom: 40.h, // Ruang bawah ekstra
                              ),
                              itemCount: vm.orders.length,
                              itemBuilder: (ctx, i) {
                                final order = vm.orders[i];
                                return Card(
                                  // Gap antar item list standar: 16.0
                                  margin: EdgeInsets.only(bottom: 16.h),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    // Radius Medium standar: 12.0
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  color: AppRestaurantColors.background,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 8.h),
                                    leading: const CircleAvatar(
                                      backgroundColor: AppRestaurantColors.primary,
                                      child: Icon(Icons.receipt_long, color: AppRestaurantColors.background),
                                    ),
                                    title: Text(
                                      'Order #${order['id'].toString().substring(0, 6)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppRestaurantColors.primary),
                                    ),
                                    subtitle: Text(
                                      order['created_at'].toString().split('T').first,
                                      style: const TextStyle(color: AppRestaurantColors.secondary),
                                    ),
                                    trailing: Text(
                                      order['formatted_price'],
                                      style: TextStyle(
                                        color: AppRestaurantColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp, // Menggunakan .sp
                                      ),
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
    // Helper untuk OutlineInputBorder seragam (Radius 12.0)
    InputDecoration buildDropdownDecoration(String label) {
      return InputDecoration(
        labelText: label,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppRestaurantColors.primary),
        ),
        filled: true,
        fillColor: Colors.white,
      );
    }

    return Padding(
      // Standarisasi padding horizontal: 16.0
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              decoration: buildDropdownDecoration('Year'),
              value: vm.selectedYear,
              items: vm.availableYears
                  .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                  .toList(),
              onChanged: (val) => vm.updateFilter(year: val),
            ),
          ),
          // Gap antar elemen horizontal standar: 16.0
          SizedBox(width: 16.w),
          Expanded(
            child: DropdownButtonFormField<int>(
              decoration: buildDropdownDecoration('Month'),
              value: vm.selectedMonth,
              items: vm.availableMonths.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (val) => vm.updateFilter(month: val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(String formattedRevenue) {
    return Container(
      // Margin layar standar: 16.0
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      width: 1.sw, // Mengubah double.infinity menjadi 1.sw
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppRestaurantColors.primary,
        // Radius Besar standar untuk Card Utama: 16.0
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppRestaurantColors.primary.withOpacity(0.3),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Revenue',
            style: TextStyle(fontSize: 14.sp, color: Colors.white70), // Menggunakan .sp
          ),
          SizedBox(height: 8.h),
          Text(
            formattedRevenue,
            style: TextStyle(
              fontSize: 32.sp, // Menggunakan .sp
              fontWeight: FontWeight.bold,
              color: AppRestaurantColors.background,
            ),
          ),
        ],
      ),
    );
  }
}