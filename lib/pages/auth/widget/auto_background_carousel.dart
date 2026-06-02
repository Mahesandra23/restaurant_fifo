import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/auth/widget/repository/carousel_repository.dart';
import 'package:restaurant_fifo/pages/auth/widget/view_model/carousel_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';


class AutoBackgroundCarousel extends StatelessWidget {
  final double height;

  const AutoBackgroundCarousel({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<CarouselViewModel>(
      viewModel: CarouselViewModel(CarouselRepository()),
      initOnce: true,
      key: const Key('AutoBackgroundCarousel'),
      view: (context) {
        final vm = context.watch<CarouselViewModel>();

        // 1. Tampilan saat loading narik data dari database
        if (vm.isLoading) {
          return SizedBox(
            height: height,
            width: double.infinity,
            child: const Center(
              child: CircularProgressIndicator(color: AppRestaurantColors.primary),
            ),
          );
        }

        // 2. Tampilan jika database tidak memiliki banner aktif sama sekali
        if (vm.bannerUrls.isEmpty) {
          return SizedBox(
            height: height,
            width: double.infinity,
            child: Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
              ),
            ),
          );
        }

        // 3. Tampilan jika data banner berhasil didapat
        return _CarouselSlider(height: height, imageUrls: vm.bannerUrls);
      },
    );
  }
}

// Widget internal (Stateful) murni untuk handle Timer animasi & UI
class _CarouselSlider extends StatefulWidget {
  final double height;
  final List<String> imageUrls;

  const _CarouselSlider({required this.height, required this.imageUrls});

  @override
  State<_CarouselSlider> createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<_CarouselSlider> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Timer berjalan setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < widget.imageUrls.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Kembali ke gambar pertama
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          _currentPage = index;
        },
        itemBuilder: (context, index) {
          // Ganti Image.asset menjadi Image.network
          return Image.network(
            widget.imageUrls[index],
            fit: BoxFit.cover,
            // Tambahkan error builder jaga-jaga kalau link gambar rusak
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade300,
                child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
              );
            },
          );
        },
      ),
    );
  }
}