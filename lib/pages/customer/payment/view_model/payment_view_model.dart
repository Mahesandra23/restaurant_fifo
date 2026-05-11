import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/customer/payment/repository/payment_repository.dart';

class PaymentViewModel extends BaseViewModel {
  final PaymentRepository _repository;
  
  final int totalAmount;
  final List<dynamic> cartItems; // Menerima isi keranjang dari halaman Cart
  
  String selectedMethod = 'QRIS';
  bool isProcessing = false;

  PaymentViewModel(this._repository, {required this.totalAmount, required this.cartItems});

  void selectMethod(String method) {
    selectedMethod = method;
    notifyListeners();
  }

  // Fungsi simulasi bayar + simpan data beneran ke Supabase
  Future<bool> processPayment() async {
    isProcessing = true;
    notifyListeners();

    // 1. Simulasi loading bayar ke Bank (2 detik)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Simpan orderan ke Supabase menggunakan Repository
    final success = await _repository.createOrder(
      totalAmount, 
      selectedMethod, 
      cartItems,
    );

    isProcessing = false;
    notifyListeners();

    return success; 
  }
}