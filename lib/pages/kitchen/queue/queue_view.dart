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
                style: TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.accent),
              ),
              backgroundColor: AppRestaurantColors.primary,
              centerTitle: true,
              elevation: 0,
            ),
            body: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppRestaurantColors.primary),
                  )
                : RefreshIndicator(
                    color: AppRestaurantColors.primary,
                    onRefresh: () => vm.fetchData(),
                    child: vm.activeOrders.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: const SizedBox(
                              height: 300, 
                              child: CustomEmptyState(
                                icon: Icons.check_circle_outline,
                                message: 'There are no active orders in the queue.',
                                iconColor: AppRestaurantColors.accent,
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(), 
                            padding: const EdgeInsets.all(16),
                            itemCount: vm.activeOrders.length,
                            itemBuilder: (context, index) {
                              final order = vm.activeOrders[index];
                              return _buildOrderCard(context, order, vm);
                            },
                          ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderQueue order, QueueViewModel vm) {
    final bool isCooking = order.status == 'cooking';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Berikan border highlight tipis berwarna orange jika pesanan sedang dimasak
        side: isCooking 
            ? const BorderSide(color: AppRestaurantColors.accent, width: 1.5) 
            : BorderSide.none,
      ),
      color: AppRestaurantColors.background,
      elevation: isCooking ? 5 : 2,
      shadowColor: AppRestaurantColors.primary.withOpacity(0.2),
      child: InkWell(
        onTap: () => _showOrderDetails(context, order, vm),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.secondary),
                      ),
                      const SizedBox(width: 8),
                      // Badge Status Tambahan di UI Kartu
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCooking ? Colors.orange.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isCooking ? 'COOKING' : 'PENDING',
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold, 
                            color: isCooking ? Colors.orange.shade800 : Colors.grey.shade700
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.customerName} - ${order.tableNumber}', 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.items.length} Items',
                    style: const TextStyle(color: AppRestaurantColors.secondary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.access_time, color: AppRestaurantColors.secondary, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    order.orderTime,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppRestaurantColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderQueue order, QueueViewModel vm) {
    // Cek apakah status order saat ini masih berupa antrean pending baru
    final bool isPending = order.status == 'pending';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail ${order.id}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary),
                  ),
                  Text(
                    order.orderTime,
                    style: const TextStyle(fontSize: 16, color: AppRestaurantColors.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                order.customerName,
                style: const TextStyle(fontSize: 16, color: AppRestaurantColors.primary, fontWeight: FontWeight.w600),
              ),
              const Divider(height: 32, thickness: 1, color: AppRestaurantColors.secondary),

              Expanded(
                child: ListView.builder(
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppRestaurantColors.accent, 
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.quantity}x',
                              style: const TextStyle(color: AppRestaurantColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppRestaurantColors.primary),
                                ),
                                if (item.notes.isNotEmpty)
                                  Text(
                                    '* ${item.notes}',
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontStyle: FontStyle.italic),
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

              const SizedBox(height: 16),
              // --- TOMBOL AKSI DINAMIS BERDASARKAN STATUS ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Warna orange jika mau dimasak, warna hijau jika mau diselesaikan
                    backgroundColor: isPending ? AppRestaurantColors.accent : AppRestaurantColors.primary, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (isPending) {
                      // Proses pindah ke status Cooking + Kurangi Stok FIFO
                      final success = await vm.acceptToCook(order.rawId);
                      if (context.mounted && success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${order.id} Started Cooking! and Stock Updated!'),
                            backgroundColor: AppRestaurantColors.accent,
                          ),
                        );
                      }
                    } else {
                      // Selesaikan pesanan ke status Completed
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
                    isPending ? 'START COOKING' : 'COOKING COMPLETE',
                    style: const TextStyle(color: AppRestaurantColors.accent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}