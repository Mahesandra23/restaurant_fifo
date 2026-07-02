import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/kitchen/queue/view_model/queue_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/custom_empty_state.dart';

class QueueView extends StatelessWidget {
  const QueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<QueueViewModel>(
      viewModel: QueueViewModel(),
      initOnce: true,
      key: const Key('KitchenMain'),
      view: (context) {
        final vm = context.watch<QueueViewModel>();

        return FocusDetector(
          onFocusGained: () {
            vm.fetchData();
          },
          child: Scaffold(
            backgroundColor: AppRestaurantColors.background,
            appBar: AppBar(
              title: const Text(
                'Kitchen Queue',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.background,
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
                    onRefresh: () => vm.fetchData(),
                    child: vm.activeOrders.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: 300,
                              child: const CustomEmptyState(
                                icon: Icons.check_circle_outline,
                                message:
                                    'There are no active orders in the queue.',
                                iconColor: AppRestaurantColors.accent,
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            // Standarisasi padding layar utama: 16.0
                            padding: EdgeInsets.all(16),
                            itemCount: vm.activeOrders.length,
                            itemBuilder: (context, index) {
                              final order = vm.activeOrders[index];
                              final isFrontQueue = vm.isFrontOrder(order.rawId);

                              return _buildOrderCard(
                                context,
                                order,
                                vm,
                                isFrontQueue,
                              );
                            },
                          ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderQueue order,
    QueueViewModel vm,
    bool isFrontQueue,
  ) {
    final bool isCooking = order.status == 'cooking';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppRestaurantColors.accent2.withOpacity(0.05),
        // Radius standar Card: 12.0
        borderRadius: BorderRadius.circular(12),
        // Border kuning tipis hanya muncul jika statusnya COOKING (sesuai gambar)
        // Menggunakan warna transparent saat PENDING agar ukuran card tidak bergeser/lompat
        border: isCooking
            ? Border.all(color: AppRestaurantColors.accent, width: 1.5)
            : Border.all(color: AppRestaurantColors.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            // Offset disamakan dengan card di menu utama
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors
            .transparent, // Penting agar background dari Container tidak tertutup
        child: InkWell(
          onTap: () => _showOrderDetails(context, order, vm, isFrontQueue),
          borderRadius: BorderRadius.circular(
            12,
          ), // Menjaga efek klik tetap di dalam radius
          child: Padding(
            // Padding dalam Card disamakan ke 16.0
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.id,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppRestaurantColors.secondary,
                          ),
                        ),
                        SizedBox(width: 8),
                        // Badge Status
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppRestaurantColors.background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isCooking ? 'COOKING' : 'PENDING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppRestaurantColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${order.customerName} - ${order.tableNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppRestaurantColors.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${order.items.length} Items',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppRestaurantColors.secondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppRestaurantColors.secondary,
                      size: 20,
                    ),
                    SizedBox(height: 4),
                    Text(
                      order.orderTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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

  void _showOrderDetails(
    BuildContext context,
    OrderQueue order,
    QueueViewModel vm,
    bool isFrontQueue,
  ) {
    final bool isPending = order.status == 'pending';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: RoundedRectangleBorder(
        // Radius Besar standar untuk BottomSheet: 16.0
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          // Standarisasi padding layar: 16.0
          padding: EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: 0.7 * MediaQuery.of(context).size.height,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppRestaurantColors.secondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Gap standar: 16.0
              SizedBox(height: 16),

              // Header Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail ${order.id}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.primary,
                    ),
                  ),
                  Text(
                    order.orderTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppRestaurantColors.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                order.customerName,
                style: TextStyle(
                  fontSize: 16,
                  color: AppRestaurantColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Divider berfungsi ganda memberi spacing vertikal setara 16.0 atas-bawah
              Divider(
                height: 32,
                thickness: 1,
                color: AppRestaurantColors.secondary,
              ),

              // Item List
              Expanded(
                child: ListView.builder(
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Padding(
                      // Gap standar antar item list: 16.0
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppRestaurantColors.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.quantity}x',
                              style: const TextStyle(
                                color: AppRestaurantColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Gap standar horizontal antar elemen: 16.0
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppRestaurantColors.primary,
                                  ),
                                ),
                                if (item.notes.isNotEmpty)
                                  Text(
                                    '* ${item.notes}',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Gap section utama (List ke Action Button): 24.0
              SizedBox(height: 24),

              // --- TOMBOL AKSI DINAMIS BERDASARKAN STATUS ---
              SizedBox(
                width: 1 * MediaQuery.of(context).size.width,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isFrontQueue
                        ? Colors.grey
                        : isPending
                        ? AppRestaurantColors.accent
                        : AppRestaurantColors.primary,
                    shape: RoundedRectangleBorder(
                      // Radius Medium standar: 12.0
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: !isFrontQueue
                      ? null
                      : () async {
                          if (isPending) {
                            final success = await vm.acceptToCook(order.rawId);
                            if (context.mounted && success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${order.id} Started Cooking! and Stock Updated!',
                                  ),
                                  backgroundColor: AppRestaurantColors.primary,
                                ),
                              );
                            }
                          } else {
                            final success = await vm.completeOrder(order.rawId);
                            if (context.mounted && success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${order.id} Completed!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                  child: Text(
                    !isFrontQueue
                        ? 'WAITING PREVIOUS ORDER'
                        : isPending
                        ? 'START COOKING'
                        : 'COOKING COMPLETE',
                    style: TextStyle(
                      color: !isFrontQueue
                          ? Colors.white70
                          : isPending
                          ? AppRestaurantColors.primary
                          : AppRestaurantColors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Memberikan ruang bawah ekstra jika HP tidak memiliki SafeArea
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
