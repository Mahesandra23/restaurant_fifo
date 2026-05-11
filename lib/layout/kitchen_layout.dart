import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/pages/kitchen/kitchen_catalog_view.dart';
import 'package:restaurant_fifo/pages/kitchen/queue/queue_view.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart'; // Import App Colors

class KitchenLayout extends StatefulWidget {
  const KitchenLayout({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<KitchenLayout> createState() => _KitchenLayoutState();
}

class _KitchenLayoutState extends State<KitchenLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Halaman khusus Dapur
  final List<Widget> _pages = [
    const QueueView(),
    const KitchenCatalogView(),
    const Center(child: Text("Stocks", style: TextStyle(color: AppRestaurantColors.primary))),
    const Center(child: Text("user", style: TextStyle(color: AppRestaurantColors.primary))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppRestaurantColors.background, // Menggunakan warna background app
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: AppRestaurantColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(index: 0, icon: Icons.receipt_long, label: 'Queue'),
            _buildNavItem(index: 1, icon: Icons.fastfood, label: 'Catalog'),
            _buildNavItem(index: 2, icon: Icons.inventory, label: 'Stocks'), 
            _buildNavItem(index: 3, icon: Icons.person, label: 'User'), 
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required IconData icon, required String label}) {
     final bool isActive = index == _currentIndex;
     
     // Menentukan warna berdasarkan status aktif
     final Color iconColor = isActive ? AppRestaurantColors.primary : AppRestaurantColors.secondary;

     return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          // Latar belakang kapsul menggunakan warna Accent saat aktif
          color: isActive ? AppRestaurantColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24.w),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10, 
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}