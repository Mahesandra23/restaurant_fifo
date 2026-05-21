import 'package:flutter/material.dart';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/customer/Profile/repository/profile_repository.dart';

class OrderHistoryModel {
  final String id;
  final String date;
  final String totalPrice;
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
  final String userId;

  ProfileViewModel(this._repo, this.userId);

  bool isLoading = false;
  List<OrderHistoryModel> orderHistory = [];

  // --- VARIABEL BARU: Menyimpan Nomor HP ---
  String userPhone = '';

  @override
  void init() {
    super.init();
    loadUserProfile(userId); // Ambil nomor telepon saat halaman dibuka
    loadOrderHistory(userId);
  }

  // --- FUNGSI BARU: Tarik Profil Terbaru ---
  Future<void> loadUserProfile(String uid) async {
    final profileData = await _repo.fetchUserProfile(uid);
    if (profileData != null && profileData['phone'] != null) {
      userPhone = profileData['phone'].toString();
      notifyListeners();
    }
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

      // Update variabel lokal agar langsung nampil di UI (Card)
      if (phone.isNotEmpty) {
        userPhone = phone;
      }

      return true;
    } catch (e) {
      debugPrint("Error update profile: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi Baru: Update Keamanan (Email & Password)
  Future<String?> updateSecuritySettings(
    String currentEmail,
    String currentPassword,
    String? newEmail,
    String? newPassword,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      // 1. Verifikasi Password Saat Ini
      final isVerified = await _repo.verifyCurrentPassword(
        currentEmail,
        currentPassword,
      );
      if (!isVerified) {
        return 'Password saat ini salah.';
      }

      // 2. Jika valid, jalankan update
      await _repo.updateAuthCredentials(
        newEmail: newEmail,
        newPassword: newPassword,
      );
      return null; // Sukses, kembalikan null
    } catch (e) {
      debugPrint("Error update security: $e");
      return 'Gagal memperbarui data keamanan.';
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
