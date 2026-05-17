import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/history/repository/banner_repository.dart';

class HistoryViewModel extends BaseViewModel {
  final HistoryRepository _repo;

  HistoryViewModel(this._repo);

  bool isLoading = false;
  List<Map<String, dynamic>> orders = [];
  
  // Simpan hasil dalam bentuk String yang sudah di-format
  String formattedTotalRevenue = 'Rp 0';

  int selectedYear = DateTime.now().year;
  int selectedMonth = 0; 

  final List<int> availableYears = [2025, 2026, 2027];
  final Map<int, String> availableMonths = {
    0: 'All Months', 1: 'January', 2: 'February', 3: 'March', 
    4: 'April', 5: 'May', 6: 'June', 7: 'July', 
    8: 'August', 9: 'September', 10: 'October', 11: 'November', 12: 'December'
  };

  @override
  void init() {
    super.init();
    fetchData();
  }

  // --- FUNGSI MANUAL FORMAT RUPIAH ---
  String _formatRupiah(double amount) {
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

  void updateFilter({int? year, int? month}) {
    if (year != null) selectedYear = year;
    if (month != null) selectedMonth = month;
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    List<Map<String, dynamic>> rawOrders = await _repo.fetchHistory(year: selectedYear, month: selectedMonth);
    
    double rawTotalRevenue = 0;
    
    // Hitung total dan sisipkan harga terformat ke masing-masing pesanan
    orders = rawOrders.map((order) {
      final mutableOrder = Map<String, dynamic>.from(order);
      double price = (mutableOrder['total_price'] as num).toDouble();
      
      rawTotalRevenue += price;
      mutableOrder['formatted_price'] = _formatRupiah(price);
      
      return mutableOrder;
    }).toList();

    // Format grand totalnya
    formattedTotalRevenue = _formatRupiah(rawTotalRevenue);

    isLoading = false;
    notifyListeners();
  }
}