import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/providers/cart_provider.dart';
import 'package:restaurant_fifo/pages/customer/payment/payment_view.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/custom_empty_state.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppRestaurantColors.background,
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: AppRestaurantColors.background,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppRestaurantColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: vm.items.isEmpty
          ? const CustomEmptyState(
              icon: Icons.shopping_cart_outlined,
              message: 'Your cart is empty. Add some delicious items!',
              iconColor: AppRestaurantColors.secondary,
            )
          : SafeArea(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: vm.items.length,
                itemBuilder: (context, index) {
                  final item = vm.items[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppRestaurantColors.accent2.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppRestaurantColors.accent),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // --- BAGIAN GAMBAR YANG SUDAH DIPERBAIKI ---
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.menu.imageUrl.isNotEmpty
                                ? Image.network(
                                    item.menu.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback jika url gambar error/gagal load
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : const Center(
                                    // Fallback jika string url kosong dari database
                                    child: Icon(
                                      Icons.fastfood,
                                      color: AppRestaurantColors.secondary,
                                    ),
                                  ),
                          ),
                        ),
                        // -------------------------------------------
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.menu.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppRestaurantColors.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                vm.formatRupiah(item.menu.price),
                                style: TextStyle(
                                  color: AppRestaurantColors.secondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: AppRestaurantColors.primary,
                              ),
                              onPressed: () => vm.decreaseQuantity(item.id),
                            ),
                            Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppRestaurantColors.primary,
                                fontSize: 14,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: AppRestaurantColors.primary,
                              ),
                              onPressed: () => vm.increaseQuantity(item.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppRestaurantColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: TextStyle(
                      color: AppRestaurantColors.secondary,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    vm.formatRupiah(vm.totalPrice),
                    style: TextStyle(
                      color: AppRestaurantColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppRestaurantColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: vm.items.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentView(
                              totalAmount: vm.totalPrice,
                              cartItems: vm.items,
                            ),
                          ),
                        );
                      },
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                    color: AppRestaurantColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}