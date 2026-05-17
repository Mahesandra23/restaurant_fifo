import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/customer/payment/repository/payment_repository.dart';

class PaymentViewModel extends BaseViewModel {
  final PaymentRepository _repository;

  final int totalAmount;
  final List<dynamic> cartItems;

  String selectedMethod = 'QRIS';
  bool isProcessing = false;
  bool isTakeaway = true;
  String tableInput = '';

  // 1. UBAH INI JADI STRING
  String customerId;

  PaymentViewModel(
    this._repository, {
    required this.totalAmount,
    required this.cartItems,
    required this.customerId,
  });

  void selectMethod(String method) {
    selectedMethod = method;
    notifyListeners();
  }

  void toggleOrderType(bool value) {
    isTakeaway = value;
    notifyListeners();
  }

  void setTableInput(String value) {
    tableInput = value;
    // Boleh pakai notifyListeners() kalau mau validasi real-time, tapi opsional
  }

  // Fungsi simulasi bayar + simpan data beneran ke Supabase
  Future<bool> processPayment() async {
    isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    String finalTableNumber = isTakeaway
        ? 'Takeaway'
        : (tableInput.isEmpty ? 'Meja ?' : 'Meja $tableInput');

    final success = await _repository.createOrder(
      totalAmount,
      selectedMethod,
      cartItems,
      finalTableNumber,
      customerId, // Sekarang mengirimkan String UUID
    );

    isProcessing = false;
    notifyListeners();

    return success;
  }
}
