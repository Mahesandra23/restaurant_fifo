import 'dart:async'; // Tambahkan ini untuk Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_all/menu_all_view.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_detail/menu_detail_view.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_main/repository/menu_main_repository.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_main/view_model/menu_main_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/custom_empty_state.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/menu_card_widget.dart';

class MenuMainView extends StatelessWidget {
  const MenuMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<MenuMainViewModel>(
      viewModel: MenuMainViewModel(MenuMainRepository()),
      initOnce: true,
      key: const Key('CustomerMain'),
      view: (context) {
        final vm = context.watch<MenuMainViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,
          appBar: _buildHeader(context, vm),
          body: SafeArea(
            child: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppRestaurantColors.primary,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Passing ViewModel ke sini
                              _buildPromoBanner(vm),
                              const SizedBox(height: 24),

                              if (vm.groupedMenus.isEmpty)
                                CustomEmptyState(
                                  icon: vm.searchQuery.isEmpty
                                      ? Icons.restaurant_menu
                                      : Icons.search_off,
                                  message: vm.searchQuery.isEmpty
                                      ? 'There are no menus available yet.'
                                      : 'No menus found for "${vm.searchQuery}".',
                                  iconColor: AppRestaurantColors.secondary,
                                ),
                              ...vm.groupedMenus.entries.map((entry) {
                                String categoryName = entry.key;
                                List<MenuModel> menuItems = entry.value;
                                return _buildMenuSection(
                                  context,
                                  categoryName,
                                  menuItems,
                                );
                              }),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  AppBar _buildHeader(BuildContext context, MenuMainViewModel vm) {
    return AppBar(
      backgroundColor: AppRestaurantColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false, // Mencegah tombol back otomatis muncul
      titleSpacing:
          16.0, // Memberikan jarak kiri-kanan yang pas di dalam AppBar
      title: Row(
        children: [
          const Text(
            'RestaurantApp',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppRestaurantColors.accent, // Warna teks accent
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                onChanged: (value) => vm.searchMenu(value),
                decoration: InputDecoration(
                  hintText: 'Search menu...',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: AppRestaurantColors.secondary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: AppRestaurantColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppRestaurantColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UPDATE _buildPromoBanner UNTUK MENGGUNAKAN DATA VM ---
  Widget _buildPromoBanner(MenuMainViewModel vm) {
    // Jika tidak ada banner aktif, tampilkan fallback atau bisa juga SizedBox.shrink()
    if (vm.bannerUrls.isEmpty) {
      return Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: AppRestaurantColors.secondary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'There are no promotions available at the moment.',
            style: TextStyle(
              color: AppRestaurantColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Panggil Widget Stateful khusus untuk Carousel
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _PromoBannerCarousel(imageUrls: vm.bannerUrls),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<MenuModel> items,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppRestaurantColors.primary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MenuAllView(categoryName: title),
                  ),
                );
              },
              child: const Text(
                'See all ➔',
                style: TextStyle(color: AppRestaurantColors.secondary),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppRestaurantColors.background,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: MenuCardWidget(
                  name: item.name,
                  formattedPrice: 'Rp ${item.price}',
                  imageUrl: item.imageUrl,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuDetailView(menu: item),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// --- WIDGET BARU: STATEFUL CAROUSEL ---
class _PromoBannerCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const _PromoBannerCarousel({required this.imageUrls});

  @override
  State<_PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<_PromoBannerCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Timer hanya jalan jika gambar lebih dari 1
    if (widget.imageUrls.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (_currentPage < widget.imageUrls.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
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
      height: 140, // Sama seperti container promo sebelumnya
      width: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          _currentPage = index;
        },
        itemBuilder: (context, index) {
          return Image.network(
            widget.imageUrls[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
