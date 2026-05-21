import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            color: AppRestaurantColors.background, // Warna teks accent
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppRestaurantColors.primary, // Background primary
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
                // Standarisasi padding layar utama: 16.0
                padding: EdgeInsets.all(16.w),
                itemCount: vm.items.length,
                itemBuilder: (context, index) {
                  final item = vm.items[index];
                  return Container(
                    // Gap antar Card item (Vertical): 16.0
                    margin: EdgeInsets.only(bottom: 16.h),
                    // Padding dalam Card disamakan ke 16.0 agar konsisten
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppRestaurantColors.accent2.withOpacity(0.05),
                      // Radius standar Card: 12.0
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppRestaurantColors.accent),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5.r,
                          // Offset disamakan dengan card di menu utama
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 60.h,
                          width: 60.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            // Radius untuk gambar di dalam card sedikit lebih kecil (8.0)
                            // agar proporsional dengan radius luar (12.0)
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: const Icon(
                            Icons.fastfood,
                            color: AppRestaurantColors.secondary,
                          ),
                        ),
                        // Gap standar antar elemen horizontal: 16.0
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.menu.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: AppRestaurantColors.primary,
                                ),
                              ),
                              // Gap kecil antar teks judul dan harga
                              SizedBox(height: 4.h),
                              Text(
                                vm.formatRupiah(item.menu.price),
                                style: TextStyle(
                                  color: AppRestaurantColors.secondary,
                                  fontSize: 12.sp,
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
                                fontSize: 14
                                    .sp, // Diberi ukuran spesifik agar lebih jelas
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
        // Standarisasi padding layar utama: 16.0
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppRestaurantColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
              offset: Offset(0, -5.h),
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
                      fontSize: 12.sp,
                    ),
                  ),
                  // Gap kecil untuk pemisah teks
                  SizedBox(height: 4.h),
                  Text(
                    vm.formatRupiah(vm.totalPrice),
                    style: TextStyle(
                      color: AppRestaurantColors.primary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppRestaurantColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 10.h,
                  ),
                  shape: RoundedRectangleBorder(
                    // Radius standar Tombol/Button disamakan dengan Card: 12.0
                    borderRadius: BorderRadius.circular(12.r),
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
