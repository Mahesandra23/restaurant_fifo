import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/customer/Profile/repository/profile_repository.dart';

class OrderHistoryModel {
  final String id;
  final String date;
  final int totalPrice;
  final String status;
  final String itemsSummary;

  OrderHistoryModel({
    required this.id,
    required this.date,
    required this.totalPrice,
    required this.status,
    required this.itemsSummary,
  });
}

class ProfileViewModel extends BaseViewModel {
  final ProfileRepository _repo;
  final String userId; // 1. Tambahkan variabel userId

  // 2. Masukkan userId ke dalam constructor
  ProfileViewModel(this._repo, this.userId);

  bool isLoading = false;
  List<OrderHistoryModel> orderHistory = [];

  // 3. Gunakan override init() bawaan BaseViewModel
  @override
  void init() {
    super.init();
    loadOrderHistory(userId); // Panggil di sini secara otomatis!
  }

  Future<void> loadOrderHistory(String uid) async {
    isLoading = true;
    notifyListeners();

    try {
      final rawData = await _repo.fetchOrderHistory(uid);
      
      orderHistory = rawData.map((row) {
        final items = row['order_items'] as List<dynamic>;
        List<String> summaryParts = [];
        for (var item in items) {
          final qty = item['quantity'];
          final menuName = item['menus']['name'];
          summaryParts.add('${qty}x $menuName');
        }

        final DateTime parsedDate = DateTime.parse(row['created_at']).toLocal();
        final String formattedDate = "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";

        return OrderHistoryModel(
          id: row['id'].toString().substring(0, 8),
          date: formattedDate,
          totalPrice: row['total_price'] as int,
          status: row['status'],
          itemsSummary: summaryParts.join(', '),
        );
      }).toList();
    } catch (e) {
      debugPrint("Error load history: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String uid, String name, String phone) async {
    try {
      isLoading = true;
      notifyListeners();
      
      await _repo.updateProfile(uid, name, phone);
      return true;
    } catch (e) {
      debugPrint("Error update profile: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String uid) async {
    isLoading = true;
    notifyListeners();
    await _repo.deleteAccount(uid);
    isLoading = false;
    notifyListeners();
  }
}