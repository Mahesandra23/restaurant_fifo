import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/pages/customer/Cart/cart_view.dart';
import 'package:restaurant_fifo/pages/customer/Cart/view_model/cart_view_model.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_main/customer_main_view.dart';
import 'package:restaurant_fifo/pages/customer/Profile/profile_view.dart'; 
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class CustomerLayout extends StatefulWidget {
  const CustomerLayout({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<CustomerLayout> createState() => _CustomerLayoutState();
}

class _CustomerLayoutState extends State<CustomerLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Halaman khusus Customer
  final List<Widget> _pages = [
    const CustomerMainView(), 
    const CartView(),
    const ProfileView()
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
              color: Colors.black.withOpacity(0.05), // Memberikan bayangan halus ke atas
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, index: 0, icon: Icons.home_outlined, label: 'Menu'),
            _buildNavItem(context, index: 1, icon: Icons.shopping_cart_outlined, label: 'Cart'),
            _buildNavItem(context, index: 2, icon: Icons.person_outline, label: 'User'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required int index, required IconData icon, required String label}) {
    final bool isActive = index == _currentIndex;
    final cartVm = context.watch<CartViewModel>();

    // Menentukan warna berdasarkan status aktif
    final Color iconColor = isActive ? AppRestaurantColors.primary : AppRestaurantColors.secondary;

    Widget iconWidget = Icon(icon, color: iconColor, size: 24.w);

    if (label == 'Cart') {
      iconWidget = Badge(
        isLabelVisible: cartVm.totalQuantity > 0,
        label: Text(cartVm.totalQuantity.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red, // Tetap merah untuk notifikasi (Best Practice UI)
        child: iconWidget,
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque, // Agar area klik lebih luas
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
            iconWidget, 
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