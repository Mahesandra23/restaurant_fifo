import 'dart:typed_data';
import 'package:restaurant_fifo/mvvm/base_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/banner/repository/banner_repository.dart';


class BannerViewModel extends BaseViewModel {
  final BannerRepository _repo;

  BannerViewModel(this._repo);

  bool isLoading = false;
  bool isUploading = false;
  List<Map<String, dynamic>> banners = [];

  @override
  void init() {
    super.init();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    isLoading = true;
    notifyListeners();
    banners = await _repo.fetchAllBanners();
    isLoading = false;
    notifyListeners();
  }

  Future<void> uploadNewBanner(String title, String fileName, Uint8List fileBytes) async {
    isUploading = true;
    notifyListeners();
    
    await _repo.addBanner(title: title, fileName: fileName, fileBytes: fileBytes);
    
    isUploading = false;
    await fetchBanners();
  }

  Future<void> toggleStatus(String id, bool status) async {
    await _repo.toggleBannerStatus(id, status);
    fetchBanners(); 
  }

  Future<void> deleteBanner(String id, String imagePath) async {
    isLoading = true;
    notifyListeners();
    await _repo.deleteBanner(id, imagePath);
    await fetchBanners();
  }
}