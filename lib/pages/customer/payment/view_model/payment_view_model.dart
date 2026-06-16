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
  
  // Tambahan: Variabel untuk menampung pesan error
  String? tableError; 

  String customerId;

  PaymentViewModel(
    this._repository, {
    required this.totalAmount,
    required this.cartItems,
    required this.customerId,
  });

  String get formattedTotalAmount => _formatRupiah(totalAmount);

  String _formatRupiah(num amount) {
    String numStr = amount.toInt().toString();
    String result = '';
    int count = 0;

    for (int i = numStr.length - 1; i >= 0; i--) {
      result = numStr[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  void selectMethod(String method) {
    selectedMethod = method;
    notifyListeners();
  }

  void toggleOrderType(bool value) {
    isTakeaway = value;
    // Hapus pesan error jika user mengganti mode pesanan
    tableError = null; 
    notifyListeners();
  }

  void setTableInput(String value) {
    tableInput = value;
    // Hapus pesan error secara real-time ketika user mulai mengetik
    if (tableError != null) {
      tableError = null;
      notifyListeners();
    }
  }

  Future<bool> processPayment() async {
    // --- VALIDASI NOMOR MEJA ---
    if (!isTakeaway && tableInput.trim().isEmpty) {
      tableError = 'Table number is required!';
      notifyListeners();
      return false; // Hentikan proses pembayaran
    }
    
    // Reset error jika validasi lolos
    tableError = null; 
    // ---------------------------

    isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    String finalTableNumber = isTakeaway
        ? 'Takeaway'
        : 'Meja $tableInput';

    final success = await _repository.createOrder(
      totalAmount, 
      selectedMethod,
      cartItems,
      finalTableNumber,
      customerId, 
    );

    isProcessing = false;
    notifyListeners();

    return success;
  }
}