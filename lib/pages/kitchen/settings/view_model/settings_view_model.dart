import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/settings/repository/settings_repository.dart';

class SettingsViewModel extends BaseViewModel {
  final SettingsRepository _repo;

  SettingsViewModel(this._repo);

  bool isLoading = false;
  
  // Kita simpan hasil formatnya langsung dalam bentuk String
  String formattedDailyRevenue = 'Rp 0';
  List<Map<String, dynamic>> recentOrders = [];

  @override
  void init() {
    super.init();
    fetchDashboardData();
  }

  // --- FUNGSI MANUAL FORMAT RUPIAH ---
  String _formatRupiah(double amount) {
    String numStr = amount.toInt().toString();
    String result = '';
    int count = 0;
    
    // Looping dari belakang untuk menambahkan titik setiap 3 angka
    for (int i = numStr.length - 1; i >= 0; i--) {
      result = numStr[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  Future<void> fetchDashboardData() async {
    isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _repo.fetchDailyRevenue(),
      _repo.fetchRecentOrders(),
    ]);

    // 1. Format Daily Revenue
    double rawDailyRevenue = results[0] as double;
    formattedDailyRevenue = _formatRupiah(rawDailyRevenue);

    // 2. Format Harga di dalam list Order
    List<Map<String, dynamic>> rawOrders = results[1] as List<Map<String, dynamic>>;
    recentOrders = rawOrders.map((order) {
      // Bikin Map baru agar bisa diedit (karena data dari Supabase bersifat read-only)
      final mutableOrder = Map<String, dynamic>.from(order); 
      double price = (mutableOrder['total_price'] as num).toDouble();
      mutableOrder['formatted_price'] = _formatRupiah(price); // Simpan string yang sudah diformat
      return mutableOrder;
    }).toList();

    isLoading = false;
    notifyListeners();
  }

  Future<void> performLogout() async {
    await _repo.logout();
  }
}