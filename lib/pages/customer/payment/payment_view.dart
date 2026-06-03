import 'package:flutter/material.dart';
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
                width: double.infinity, // Mengubah double.infinity menjadi double.infinity
                // Margin standar 16.0 di kiri, kanan, atas. Bottom 24.0 sebagai gap antar section
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 24,
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                  color: AppRestaurantColors.primary,
                  // Radius Besar standar: 16.0
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppRestaurantColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Payment',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      vm.formattedTotalAmount,
                      style: TextStyle(
                        color: AppRestaurantColors.accent,
                        fontSize: 26,
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
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Payment Method',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppRestaurantColors.primary,
                        ),
                      ),
                      // Gap antar elemen standar: 16.0
                      SizedBox(height: 16),
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
                      SizedBox(height: 24),

                      Text(
                        'Order Type',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppRestaurantColors.primary,
                          fontSize: 16,
                        ),
                      ),
                      // Gap antar elemen standar: 16.0
                      SizedBox(height: 16),

                      // --- OPSI KARTU METODE MAKAN BER-BORDER (DINE IN & TAKEAWAY) ---
                      Column(
                        children: [
                          // 1. Pilihan Takeaway
                          GestureDetector(
                            onTap: () => vm.toggleOrderType(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(
                                bottom: 16,
                              ), // Spacing disamakan dengan metode pembayaran
                              padding: EdgeInsets.all(8),
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
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
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 16),
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
                                        fontSize: 15,
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
                              margin: EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.all(8),
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
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
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 16),
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
                                        fontSize: 15,
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
                        SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Input Table Number',
                            prefixIcon: const Icon(
                              Icons.table_restaurant,
                              color: AppRestaurantColors.secondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // --- TOMBOL BAYAR ---
              Container(
                // Standarisasi padding layar bawah: 16.0
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                  borderRadius: BorderRadius.vertical(
                    // Radius Besar standar: 16.0
                    top: Radius.circular(16),
                  ),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppRestaurantColors.primary,
                        shape: RoundedRectangleBorder(
                          // Radius Medium standar tombol: 12.0
                          borderRadius: BorderRadius.circular(12),
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
                              height: 24,
                              width: 24,
                              child: const CircularProgressIndicator(
                                color: AppRestaurantColors.accent,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              'Pay Now',
                              style: TextStyle(
                                color: AppRestaurantColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(8),
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
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
                size: 24,
              ),
            ),
            // Gap antar elemen horizontal standar: 16.0
            SizedBox(width: 16),
            Expanded(
              child: Text(
                method,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppRestaurantColors.primary
                      : Colors.black87,
                  fontSize: 15,
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
  // Widget _buildDiningMethodCard({
  //   required bool isSelected,
  //   required String title,
  //   required IconData icon,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 200),
  //       padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  //       decoration: BoxDecoration(
  //         color: isSelected
  //             ? AppRestaurantColors.accent2.withOpacity(0.05)
  //             : Colors.white,
  //         border: Border.all(
  //           color: isSelected
  //               ? AppRestaurantColors.accent
  //               : Colors.grey.shade200,
  //           width: isSelected ? 2 : 1,
  //         ),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             icon,
  //             color: isSelected
  //                 ? AppRestaurantColors.primary
  //                 : AppRestaurantColors.secondary,
  //             size: 20,
  //           ),
  //           SizedBox(width: 8),
  //           Text(
  //             title,
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
  //               color: isSelected
  //                   ? AppRestaurantColors.primary
  //                   : Colors.black87,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Dialog Sukses
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            // Radius Besar standar untuk Dialog/Sheet: 16.0
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              // Gap standar section dialog: 24.0
              SizedBox(height: 24),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.primary,
                ),
              ),
              // Gap elemen standar: 16.0
              SizedBox(height: 16),
              const Text(
                'Your order is being sent to the kitchen. Please wait while we prepare your food.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
              // Gap section standar ke tombol action: 24.0
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity, // Mengubah double.infinity menjadi double.infinity
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppRestaurantColors.primary,
                    shape: RoundedRectangleBorder(
                      // Radius Medium standar tombol: 12.0
                      borderRadius: BorderRadius.circular(12),
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
                      fontSize: 14,
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
