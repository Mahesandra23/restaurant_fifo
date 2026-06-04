import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/account/repository/account_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountViewModel extends BaseViewModel {
  final AccountRepository _repo;

  AccountViewModel(this._repo);

  bool isLoading = false;
  List<Map<String, dynamic>> staffList = [];

  // Variabel untuk mengunci ID Admin asli yang sedang membuka halaman ini
  String? originalAdminId;

  @override
  void init() {
    super.init();
    // Kunci ID saat halaman pertama kali diinisialisasi
    originalAdminId = Supabase.instance.client.auth.currentUser?.id;
    fetchStaff();
  }

  Future<void> fetchStaff() async {
    isLoading = true;
    notifyListeners();

    staffList = await _repo.fetchKitchenStaff();

    isLoading = false;
    notifyListeners();
  }

  Future<void> createNewAdmin(
    String email,
    String password,
    String displayName,
    String phone,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repo.createAdminAccount(email, password, displayName, phone);
      await fetchStaff();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi Update Profil Biasa
  Future<bool> updateProfile(String id, String name, String phone) async {
    final success = await _repo.updateProfile(id, name, phone);
    if (success) await fetchStaff();
    return success;
  }

  // Fungsi Update Keamanan
  Future<String?> updateSecuritySettings(
    String currentEmail,
    String currentPassword,
    String? newEmail,
    String? newPassword,
  ) async {
    isLoading = true;
    notifyListeners();

    final error = await _repo.updateSecuritySettings(
      currentEmail: currentEmail,
      currentPassword: currentPassword,
      newEmail: newEmail,
      newPassword: newPassword,
    );

    isLoading = false;
    notifyListeners();
    return error;
  }

  Future<void> deleteAdminAccount(String id) async {
    isLoading = true;
    notifyListeners();

    await _repo.deleteAdmin(id);
    await fetchStaff();
  }

  // Tambahkan getter untuk email user saat ini (diperlukan untuk form edit)
  String get currentUserEmail => Supabase.instance.client.auth.currentUser?.email ?? '';
}
