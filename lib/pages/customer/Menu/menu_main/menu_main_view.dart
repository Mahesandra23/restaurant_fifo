import 'dart:async'; // Tambahkan ini untuk Timer
import 'package:flutter/material.dart';
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
          appBar: AppBar(
            title: const Text(
              'RestaurantApp',
              style: TextStyle(
                color: AppRestaurantColors.background,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppRestaurantColors.primary,
            elevation: 0,
            centerTitle: true,
          ),
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
                          // Standarisasi padding layar utama: 16.0
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16, 
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Search Bar diletakkan paling atas (di bawah AppBar)
                              _buildSearchBar(vm),
                              
                              // Gap antar Search Bar dan Banner
                              SizedBox(height: 8),

                              // 2. Promo Banner
                              _buildPromoBanner(vm),
                              
                              // Gap antar section utama (Banner ke List Menu)
                              SizedBox(height: 16),

                              // 3. Daftar Kategori & Menu
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
                                  vm,
                                );
                              }),

                              // Padding ekstra di bagian paling bawah
                              SizedBox(height: 40),
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

  // Search Bar dipindah ke dalam body
  Widget _buildSearchBar(MenuMainViewModel vm) {
    return SizedBox(
      height: 45, // Tinggi distandarkan sedikit lebih besar agar nyaman
      child: TextField(
        onChanged: (value) => vm.searchMenu(value),
        decoration: InputDecoration(
          hintText: 'Search menu...',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: AppRestaurantColors.secondary,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          filled: true,
          fillColor: Colors.white, // Warna fill diubah jadi putih agar lebih terlihat
          border: OutlineInputBorder(
            // Radius standar TextField: 12.0
            borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(
              color: AppRestaurantColors.primary,
            ), // Border default dengan warna primary yang lebih terang
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppRestaurantColors.primary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppRestaurantColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(MenuMainViewModel vm) {
    if (vm.bannerUrls.isEmpty) {
      return Container(
        width: double.infinity, // Menggunakan double.infinity pengganti double.infinity
        height: 120,
        decoration: BoxDecoration(
          color: AppRestaurantColors.secondary.withOpacity(0.2),
          // Radius standar Banner besar: 16.0
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

    return ClipRRect(
      // Radius standar Banner besar: 16.0
      borderRadius: BorderRadius.circular(16),
      child: _PromoBannerCarousel(imageUrls: vm.bannerUrls),
    );
  }

  Widget  _buildMenuSection(
    BuildContext context,
    String title,
    List<MenuModel> items,
    MenuMainViewModel vm,
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
              style: TextStyle(
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
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 130,
                // Gap antar Card item (Horizontal): 16.0
                margin: EdgeInsets.only(right: 16, bottom: 8), // Margin bawah untuk memberikan jarak ke bawah
                decoration: BoxDecoration(
                  color: AppRestaurantColors.background,
                  // Radius standar Card: 12.0
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: MenuCardWidget(
                  name: item.name,
                  formattedPrice: vm.formatRupiah(item.price),
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
        // Gap antar Section Kategori (Bawah ListView ke Kategori Selanjutnya): 24.0
        SizedBox(height: 24),
      ],
    );
  }
}

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
      height: 140,
      width: double.infinity, // Menggunakan double.infinity pengganti double.infinity
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