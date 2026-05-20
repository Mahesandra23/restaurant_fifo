import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/providers/cart_provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/pages/customer/payment/view_model/payment_view_model.dart';
import 'package:restaurant_fifo/pages/customer/payment/repository/payment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentView extends StatelessWidget {
  final int totalAmount;
  final List<dynamic> cartItems;

  const PaymentView({
    super.key,
    required this.totalAmount,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    final String currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? '';

    return MvvmBuilder<PaymentViewModel>(
      viewModel: PaymentViewModel(
        PaymentRepository(),
        totalAmount: totalAmount,
        cartItems: cartItems,
        customerId: currentUserId,
      ),
      initOnce: true,
      key: const Key('PaymentView'),
      view: (context) {
        final vm = context.watch<PaymentViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,
          appBar: AppBar(
            backgroundColor: AppRestaurantColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                // Mengubah warna tombol back menjadi accent agar seragam dengan teks title
                color: AppRestaurantColors.background,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Payment',
              style: TextStyle(
                color: AppRestaurantColors.background,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // --- KOTAK TOTAL TAGIHAN ---
              Container(
                width: 1.sw, // Mengubah double.infinity menjadi 1.sw
                // Margin standar 16.0 di kiri, kanan, atas. Bottom 24.0 sebagai gap antar section
                margin: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 16.h,
                  bottom: 24.h,
                ),
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                decoration: BoxDecoration(
                  color: AppRestaurantColors.primary,
                  // Radius Besar standar: 16.0
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppRestaurantColors.primary.withOpacity(0.3),
                      blurRadius: 15.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Payment',
                      style: TextStyle(color: Colors.white70, fontSize: 16.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Rp ${vm.totalAmount}',
                      style: TextStyle(
                        color: AppRestaurantColors.accent,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // --- DAFTAR CONTENT UTAMA ---
              Expanded(
                child: SingleChildScrollView(
                  // Standarisasi padding layar: 16.0
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Payment Method',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppRestaurantColors.primary,
                        ),
                      ),
                      // Gap antar elemen standar: 16.0
                      SizedBox(height: 16.h),
                      _buildPaymentCard(vm, 'QRIS', Icons.qr_code_scanner),
                      _buildPaymentCard(
                        vm,
                        'Cash (At Counter)',
                        Icons.payments,
                      ),
                      _buildPaymentCard(
                        vm,
                        'GoPay / OVO',
                        Icons.account_balance_wallet,
                      ),
                      _buildPaymentCard(
                        vm,
                        'Bank Transfer',
                        Icons.account_balance,
                      ),

                      // Gap antar section utama: 24.0
                      SizedBox(height: 24.h),

                      Text(
                        'Order Type',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppRestaurantColors.primary,
                          fontSize: 16.sp,
                        ),
                      ),
                      // Gap antar elemen standar: 16.0
                      SizedBox(height: 16.h),

                      // --- OPSI KARTU METODE MAKAN BER-BORDER (DINE IN & TAKEAWAY) ---
                      Column(
                        children: [
                          // 1. Pilihan Takeaway
                          GestureDetector(
                            onTap: () => vm.toggleOrderType(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(
                                bottom: 16.h,
                              ), // Spacing disamakan dengan metode pembayaran
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: vm.isTakeaway == true
                                    ? AppRestaurantColors.accent2.withOpacity(
                                        0.05,
                                      )
                                    : Colors.white,
                                border: Border.all(
                                  color: vm.isTakeaway == true
                                      ? AppRestaurantColors.accent
                                      : Colors.grey.shade200,
                                  width: vm.isTakeaway == true ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: vm.isTakeaway == true
                                          ? AppRestaurantColors.primary
                                                .withOpacity(0.1)
                                          : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.fastfood,
                                      color: vm.isTakeaway == true
                                          ? AppRestaurantColors.primary
                                          : AppRestaurantColors.secondary,
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Text(
                                      'Takeaway',
                                      style: TextStyle(
                                        fontWeight: vm.isTakeaway == true
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: vm.isTakeaway == true
                                            ? AppRestaurantColors.primary
                                            : Colors.black87,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ),
                                  if (vm.isTakeaway == true)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppRestaurantColors.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // 2. Pilihan Dine In (Meja)
                          GestureDetector(
                            onTap: () => vm.toggleOrderType(false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(bottom: 16.h),
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: vm.isTakeaway == false
                                    ? AppRestaurantColors.accent2.withOpacity(
                                        0.05,
                                      )
                                    : Colors.white,
                                border: Border.all(
                                  color: vm.isTakeaway == false
                                      ? AppRestaurantColors.accent
                                      : Colors.grey.shade200,
                                  width: vm.isTakeaway == false ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: vm.isTakeaway == false
                                          ? AppRestaurantColors.primary
                                                .withOpacity(0.1)
                                          : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.table_restaurant,
                                      color: vm.isTakeaway == false
                                          ? AppRestaurantColors.primary
                                          : AppRestaurantColors.secondary,
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Text(
                                      'Dine In (Meja)',
                                      style: TextStyle(
                                        fontWeight: vm.isTakeaway == false
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: vm.isTakeaway == false
                                            ? AppRestaurantColors.primary
                                            : Colors.black87,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ),
                                  if (vm.isTakeaway == false)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppRestaurantColors.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 2. TextField Kondisional (HANYA MUNCUL JIKA DINE IN DIPILIH)
                      if (!vm.isTakeaway) ...[
                        SizedBox(height: 8.h),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Input Table Number',
                            prefixIcon: const Icon(
                              Icons.table_restaurant,
                              color: AppRestaurantColors.secondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: AppRestaurantColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: vm.setTableInput,
                        ),
                      ],

                      // Memberikan padding tambahan di bawah agar tidak menempel tombol bayar
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),

              // --- TOMBOL BAYAR ---
              Container(
                // Standarisasi padding layar bawah: 16.0
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10.r,
                      offset: Offset(0, -5.h),
                    ),
                  ],
                  borderRadius: BorderRadius.vertical(
                    // Radius Besar standar: 16.0
                    top: Radius.circular(16.r),
                  ),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: 1.sw, // Mengubah double.infinity menjadi 1.sw
                    height: 45.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppRestaurantColors.primary,
                        shape: RoundedRectangleBorder(
                          // Radius Medium standar tombol: 12.0
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: vm.isProcessing
                          ? null
                          : () async {
                              final success = await vm.processPayment();
                              if (success && context.mounted) {
                                context.read<CartProvider>().clearCart();
                                _showSuccessDialog(context);
                              }
                            },
                      child: vm.isProcessing
                          ? SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: const CircularProgressIndicator(
                                color: AppRestaurantColors.accent,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              'PAY NOW',
                              style: TextStyle(
                                color: AppRestaurantColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
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

  // Widget Pembuat Kartu Pilihan Metode Pembayaran
  Widget _buildPaymentCard(PaymentViewModel vm, String method, IconData icon) {
    final isSelected = vm.selectedMethod == method;
    return GestureDetector(
      onTap: () => vm.selectMethod(method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // Gap antar elemen (Card list) standar: 16.0
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppRestaurantColors.accent2.withOpacity(0.05)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? AppRestaurantColors.accent
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          // Radius Medium standar: 12.0
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppRestaurantColors.primary.withOpacity(0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppRestaurantColors.primary
                    : AppRestaurantColors.secondary,
                size: 24.sp,
              ),
            ),
            // Gap antar elemen horizontal standar: 16.0
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                method,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppRestaurantColors.primary
                      : Colors.black87,
                  fontSize: 15.sp,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppRestaurantColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KUSTOM BARU UNTUK KARTU METODE MAKAN BER-BORDER ---
  Widget _buildDiningMethodCard({
    required bool isSelected,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppRestaurantColors.accent2.withOpacity(0.05)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? AppRestaurantColors.accent
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppRestaurantColors.primary
                  : AppRestaurantColors.secondary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppRestaurantColors.primary
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Sukses
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            // Radius Besar standar untuk Dialog/Sheet: 16.0
            borderRadius: BorderRadius.circular(16.r),
          ),
          contentPadding: EdgeInsets.all(24.w),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80.sp),
              // Gap standar section dialog: 24.0
              SizedBox(height: 24.h),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.primary,
                ),
              ),
              // Gap elemen standar: 16.0
              SizedBox(height: 16.h),
              const Text(
                'Your order is being sent to the kitchen. Please wait while we prepare your food.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
              // Gap section standar ke tombol action: 24.0
              SizedBox(height: 24.h),
              SizedBox(
                width: 1.sw, // Mengubah double.infinity menjadi 1.sw
                height: 45.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppRestaurantColors.primary,
                    shape: RoundedRectangleBorder(
                      // Radius Medium standar tombol: 12.0
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Text(
                    'BACK TO HOMEPAGE',
                    style: TextStyle(
                      color: AppRestaurantColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
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
