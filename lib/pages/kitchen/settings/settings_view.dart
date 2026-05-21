import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/providers/session_provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/navigator/route_list.dart';
import 'package:restaurant_fifo/pages/kitchen/account/account_view.dart';
import 'package:restaurant_fifo/pages/kitchen/banner/banner_view.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/pages/kitchen/settings/repository/settings_repository.dart';
import 'package:restaurant_fifo/pages/kitchen/settings/view_model/settings_view_model.dart';
import 'package:restaurant_fifo/pages/kitchen/history/history_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<SettingsViewModel>(
      viewModel: SettingsViewModel(SettingsRepository()),
      initOnce: true,
      key: const Key('SettingsView'),
      view: (context) {
        final vm = context.watch<SettingsViewModel>();
        final session = context.watch<SessionProvider>();

        return FocusDetector(
          onFocusGained: () => vm.fetchDashboardData(),
          child: Scaffold(
            backgroundColor: AppRestaurantColors.background,
            appBar: AppBar(
              title: const Text(
                'Kitchen Dashboard',
                style: TextStyle(
                  color: AppRestaurantColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppRestaurantColors.primary,
              centerTitle: true,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () => _confirmLogout(context, vm, session),
                ),
              ],
            ),
            body: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppRestaurantColors.primary,
                    ),
                  )
                : RefreshIndicator(
                    color: AppRestaurantColors.primary,
                    onRefresh: () => vm.fetchDashboardData(),
                    child: ListView(
                      // Standarisasi padding layar utama: 16.0
                      padding: EdgeInsets.all(16.w),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        _buildDailyReportCard(vm.formattedDailyRevenue),
                        // Gap antar section utama: 24.0
                        SizedBox(height: 24.h),
                        _buildRecentOrdersSection(context, vm.recentOrders),
                        // Gap antar section utama: 24.0
                        SizedBox(height: 24.h),
                        _buildManagementMenu(context),
                        
                        // Ekstra padding bawah agar nyaman di-scroll
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  // --- BOX 1: DAILY REPORT ---
  Widget _buildDailyReportCard(String formattedRevenue) {
    return Container(
      // Padding di dalam Card Utama, kita buat sedikit lega
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppRestaurantColors.primary,
            AppRestaurantColors.primary.withOpacity(0.8),
          ],
        ),
        // Radius Besar standar untuk Card Utama: 16.0
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppRestaurantColors.primary.withOpacity(0.3),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Revenue",
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            formattedRevenue,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- BOX 2: RECENT ORDERS (PREVIEW) ---
  Widget _buildRecentOrdersSection(
    BuildContext context,
    List<Map<String, dynamic>> orders,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Orders',
              style: TextStyle(
                color: AppRestaurantColors.primary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigasi ke halaman Full History
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryView()),
                );
              },
              child: const Text(
                'View All ➔',
                style: TextStyle(color: AppRestaurantColors.primary),
              ),
            ),
          ],
        ),
        // Gap kecil dari judul ke List
        SizedBox(height: 8.h),
        
        if (orders.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Text(
              'No recent orders.',
              style: TextStyle(color: AppRestaurantColors.secondary),
            ),
          )
        else
          ...orders.map(
            (order) => Card(
              // Gap standar antar elemen List/Card: 16.0
              margin: EdgeInsets.only(bottom: 16.h),
              elevation: 2,
              shape: RoundedRectangleBorder(
                // Radius Medium standar: 12.0
                borderRadius: BorderRadius.circular(12.r),
              ),
              color: AppRestaurantColors.background,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                leading: const CircleAvatar(
                  backgroundColor: AppRestaurantColors.primary,
                  child: Icon(Icons.check, color: AppRestaurantColors.background),
                ),
                title: Text(
                  'Order #${order['id'].toString().substring(0, 5)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppRestaurantColors.primary,
                  ),
                ),
                subtitle: Text(
                  'Total: ${order['formatted_price'] ?? order['total_price']}',
                  style: const TextStyle(color: AppRestaurantColors.secondary),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- BOX 3: MANAGEMENT MENU ---
  Widget _buildManagementMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Management',
          style: TextStyle(
            color: AppRestaurantColors.primary,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Gap dari judul ke List: 16.0
        SizedBox(height: 16.h),
        _buildMenuTile(
          Icons.image,
          'Promo Banner Management',
          'Manage banner images for customers',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BannerView()),
            );
          },
        ),
        _buildMenuTile(
          Icons.manage_accounts,
          'Manage Staff Accounts',
          'Review and revoke kitchen access',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountView()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      // Gap standar antar elemen List/Card: 16.0
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        // Radius Medium standar: 12.0
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: AppRestaurantColors.background,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Icon(icon, color: AppRestaurantColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppRestaurantColors.primary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppRestaurantColors.secondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppRestaurantColors.secondary,
        ),
        onTap: onTap,
      ),
    );
  }

  // --- LOGOUT FUNCTION ---
  void _confirmLogout(BuildContext context, SettingsViewModel vm, SessionProvider session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppRestaurantColors.background,
        shape: RoundedRectangleBorder(
          // Radius Besar standar untuk Pop-up / Dialog: 16.0
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text(
          'Log Out of Application?',
          style: TextStyle(
            color: AppRestaurantColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'You will need to log in again to access the kitchen.',
          style: TextStyle(color: AppRestaurantColors.secondary),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                // Radius Medium standar: 12.0
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppRestaurantColors.secondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                // Radius Medium standar: 12.0
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () async {
              // 1. Tutup dialognya dulu
              Navigator.pop(ctx);

              // 2. Bersihkan memori dan hapus sesi Supabase lewat Auth Provider
              await session.logout();

              // 3. Buang semua riwayat halaman dan kembali ke halaman utama
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteList.AuthSelector,
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}