import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/auth/widget/repository/carousel_repository.dart';

class CarouselViewModel extends BaseViewModel {
  final CarouselRepository _repo;

  List<String> bannerUrls = [];
  bool isLoading = true;

  CarouselViewModel(this._repo);

  @override
  void init() {
    super.init();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    isLoading = true;
    notifyListeners();

    // Ambil data dari repository
    bannerUrls = await _repo.fetchActiveBanners();

    isLoading = false;
    notifyListeners();
  }
}