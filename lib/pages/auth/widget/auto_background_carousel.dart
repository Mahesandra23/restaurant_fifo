import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AutoBackgroundCarousel extends StatefulWidget {
  final double height;

  const AutoBackgroundCarousel({super.key, required this.height});

  @override
  State<AutoBackgroundCarousel> createState() => _AutoBackgroundCarouselState();
}

class _AutoBackgroundCarouselState extends State<AutoBackgroundCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  // Masukkan daftar path gambar kamu di sini
  final List<String> _images = [
    'assets/images/2.jpg',
    'assets/images/3.jpg',
    'assets/images/4.jpg',
    'assets/images/5.jpg',
    'assets/images/6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Timer akan berjalan setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Kembali ke gambar pertama
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800), // Kecepatan geser
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Wajib dibersihkan agar tidak memory leak
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: 1.sw,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _images.length,
        physics: const BouncingScrollPhysics(), // User tetap bisa geser manual
        onPageChanged: (index) {
          _currentPage = index;
        },
        itemBuilder: (context, index) {
          return Image.asset(_images[index], fit: BoxFit.cover);
        },
      ),
    );
  }
}
