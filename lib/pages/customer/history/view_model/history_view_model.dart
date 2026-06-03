import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/customer/History/repository/history_repository.dart';
import 'package:restaurant_fifo/pages/customer/Profile/view_model/profile_view_model.dart'; // Import lokasi OrderHistoryModel Anda

class HistoryViewModel extends BaseViewModel {
  final HistoryRepository _repo;
  final String userId;

  HistoryViewModel(this._repo, this.userId);

  bool isLoading = false;
  List<OrderHistoryModel> fullOrderHistory = [];

  @override
  void init() {
    super.init();
    fetchData(); // Dipanggil pertama kali
  }

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

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    try {
      final rawData = await _repo.fetchFullOrderHistory(userId);

      fullOrderHistory = rawData.map((row) {
        final items = row['order_items'] as List<dynamic>;
        List<String> summaryParts = [];
        for (var item in items) {
          final qty = item['quantity'];
          final menuName = item['menus']['name'];
          summaryParts.add('${qty}x $menuName');
        }

        final DateTime parsedDate = DateTime.parse(row['created_at']).toLocal();
        final String formattedDate =
            "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";

        return OrderHistoryModel(
          id: row['id'].toString().substring(0, 8),
          date: formattedDate,
          totalPrice: _formatRupiah(row['total_price'] as int),
          status: row['status'],
          itemsSummary: summaryParts.join(', '),
        );
      }).toList();
    } catch (e) {
      debugPrint("Error load full history: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}