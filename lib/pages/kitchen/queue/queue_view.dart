import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/kitchen/queue/view_model/queue_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

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

        return Scaffold(
          backgroundColor: AppRestaurantColors.background, 
          appBar: AppBar(
            title: const Text(
              'Kitchen Queue',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppRestaurantColors.accent, // Teks terang di atas background gelap
              ),
            ),
            backgroundColor: AppRestaurantColors.primary, 
            centerTitle: true,
            elevation: 0,
          ),
          body: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppRestaurantColors.primary),
                )
              : vm.activeOrders.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.activeOrders.length,
                  itemBuilder: (context, index) {
                    final order = vm.activeOrders[index];
                    return _buildOrderCard(context, order, vm);
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Dapur Bersih!\nTidak ada pesanan saat ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: AppRestaurantColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderQueue order,
    QueueViewModel vm,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppRestaurantColors.background,
      elevation: 3,
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
                  Text(
                    order.id,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.customerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.primary,
                    ),
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
                    style: const TextStyle(
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
    );
  }

  void _showOrderDetails(
    BuildContext context,
    OrderQueue order,
    QueueViewModel vm,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.primary,
                    ),
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
                style: const TextStyle(
                  fontSize: 16,
                  color: AppRestaurantColors.primary,
                  fontWeight: FontWeight.w600,
                ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppRestaurantColors.accent, // Badge jumlah pakai warna kuning/hijau terang
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppRestaurantColors.primary,
                                  ),
                                ),
                                if (item.notes.isNotEmpty)
                                  Text(
                                    '* ${item.notes}',
                                    style: const TextStyle(
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

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Tetap hijau karena semantik "Sukses/Selesai"
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    vm.completeOrder(order.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${order.id} selesai disiapkan!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text(
                    'MARK AS DONE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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