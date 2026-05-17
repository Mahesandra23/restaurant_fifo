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

  Future<void> createNewAdmin(String email, String password, String displayName, String phone) async {
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

  Future<void> editStaffName(String id, String newName) async {
    isLoading = true;
    notifyListeners();
    
    await _repo.updateStaffName(id, newName);
    await fetchStaff();
  }

  Future<void> deleteAdminAccount(String id) async {
    isLoading = true;
    notifyListeners();
    
    await _repo.deleteAdmin(id);
    await fetchStaff();
  }
}