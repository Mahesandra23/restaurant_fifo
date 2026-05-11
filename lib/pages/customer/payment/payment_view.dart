import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/pages/customer/payment/view_model/payment_view_model.dart';
import 'package:restaurant_fifo/pages/customer/payment/repository/payment_repository.dart'; // IMPORT REPO

class PaymentView extends StatelessWidget {
  final int totalAmount; 
  final List<dynamic> cartItems; // TAMBAHKAN INI

  // Pastikan konstruktor meminta cartItems
  const PaymentView({super.key, required this.totalAmount, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<PaymentViewModel>(
      // Masukkan Repository, totalAmount, dan cartItems ke ViewModel
      viewModel: PaymentViewModel(
        PaymentRepository(), 
        totalAmount: totalAmount, 
        cartItems: cartItems,
      ),
      initOnce: true,
      key: const Key('PaymentView'),
      view: (context) {
        final vm = context.watch<PaymentViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,
          appBar: AppBar(
            backgroundColor: AppRestaurantColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppRestaurantColors.primary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Pembayaran',
              style: TextStyle(
                color: AppRestaurantColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // --- KOTAK TOTAL TAGIHAN ---
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppRestaurantColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppRestaurantColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Tagihan',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${vm.totalAmount}',
                      style: const TextStyle(
                        color: AppRestaurantColors.accent,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // --- DAFTAR METODE PEMBAYARAN ---
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Metode Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppRestaurantColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPaymentCard(vm, 'QRIS', Icons.qr_code_scanner),
                      _buildPaymentCard(vm, 'Tunai / Cash (Di Kasir)', Icons.payments),
                      _buildPaymentCard(vm, 'GoPay / OVO', Icons.account_balance_wallet),
                      _buildPaymentCard(vm, 'Transfer Bank', Icons.account_balance),
                    ],
                  ),
                ),
              ),

              // --- TOMBOL BAYAR ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppRestaurantColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: vm.isProcessing
                          ? null // Nonaktifkan tombol jika sedang loading
                          : () async {
                              final success = await vm.processPayment();
                              // Jika sukses dan widget masih aktif, tampilkan Pop-Up
                              if (success && context.mounted) {
                                _showSuccessDialog(context);
                              }
                            },
                      child: vm.isProcessing
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppRestaurantColors.accent,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'BAYAR SEKARANG',
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

  // Widget Pembuat Kartu Pilihan
  Widget _buildPaymentCard(PaymentViewModel vm, String method, IconData icon) {
    final isSelected = vm.selectedMethod == method;
    return GestureDetector(
      onTap: () => vm.selectMethod(method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppRestaurantColors.primary.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? AppRestaurantColors.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppRestaurantColors.primary.withOpacity(0.1) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                color: isSelected ? AppRestaurantColors.primary : AppRestaurantColors.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                method,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppRestaurantColors.primary : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppRestaurantColors.primary),
          ],
        ),
      ),
    );
  }

  // Dialog Sukses
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Wajib tekan tombol untuk tutup
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pesanan Anda sedang dikirim ke dapur. Silakan tunggu makanan Anda disajikan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppRestaurantColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // TODO: Arahkan ke halaman utama atau halaman status pesanan
                    // Untuk sementara, ini akan pop sampai halaman paling awal (Beranda)
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'KEMBALI KE BERANDA',
                    style: TextStyle(color: AppRestaurantColors.accent, fontWeight: FontWeight.bold),
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