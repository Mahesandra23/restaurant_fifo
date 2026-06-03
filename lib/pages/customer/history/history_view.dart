import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/providers/session_provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/customer/History/repository/history_repository.dart';
import 'package:restaurant_fifo/pages/customer/History/view_model/history_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/custom_empty_state.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionProvider>();
    final user = session.currentUserProfile;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Silakan login untuk melihat riwayat")),
      );
    }

    return MvvmBuilder<HistoryViewModel>(
      key: const Key('HistoryViewCustomer'),
      viewModel: HistoryViewModel(HistoryRepository(), user.id),
      initOnce: true,
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
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppRestaurantColors.background,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppRestaurantColors.primary,
                    ),
                  )
                : RefreshIndicator(
                    color: AppRestaurantColors.primary,
                    onRefresh: () => vm.fetchData(),
                    child: vm.fullOrderHistory.isEmpty
                        ? const CustomEmptyState(
                            icon: Icons.history,
                            message:
                                'There are no orders yet. Start ordering to see your history here!',
                            iconColor: AppRestaurantColors.accent,
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: vm.fullOrderHistory.length,
                            itemBuilder: (context, index) {
                              final order = vm.fullOrderHistory[index];
                              Color statusColor = order.status == 'completed'
                                  ? Colors.green
                                  : Colors.orange;

                              return Container(
                                margin: EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppRestaurantColors.accent2
                                      .withOpacity(0.05),
                                  border: Border.all(
                                    color: AppRestaurantColors.accent,
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Order #${order.id}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppRestaurantColors.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          order.date,
                                          style: TextStyle(
                                            color:
                                                AppRestaurantColors.secondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      order.itemsSummary,
                                      style: TextStyle(
                                        color: AppRestaurantColors.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          order.totalPrice,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppRestaurantColors.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            order.status.toUpperCase(),
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
}
