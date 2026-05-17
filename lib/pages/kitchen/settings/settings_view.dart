import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus_detector/focus_detector.dart';
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
                'Admin Panel',
                style: TextStyle(
                  color: AppRestaurantColors.accent,
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
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        _buildDailyReportCard(vm.formattedDailyRevenue),
                        const SizedBox(height: 24),
                        _buildRecentOrdersSection(context, vm.recentOrders),
                        const SizedBox(height: 24),
                        _buildManagementMenu(context),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppRestaurantColors.primary,
            AppRestaurantColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppRestaurantColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Revenue",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            formattedRevenue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
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
            const Text(
              'Recent Orders',
              style: TextStyle(
                color: AppRestaurantColors.primary,
                fontSize: 16,
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
        if (orders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No recent orders.',
              style: TextStyle(color: AppRestaurantColors.secondary),
            ),
          )
        else
          ...orders.map(
            (order) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppRestaurantColors.accent,
                  child: Icon(Icons.check, color: Colors.white, size: 16),
                ),
                title: Text(
                  'Order #${order['id'].toString().substring(0, 5)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Total: Rp ${order['total_price']}'),
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
        const Text(
          'System Management',
          style: TextStyle(
            color: AppRestaurantColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
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
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
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
          style: const TextStyle(
            fontSize: 12,
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
    // Pastikan Anda sudah mendefinisikan 'session' di dalam fungsi build Anda
    // Contoh: final session = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out of Application?'),
        content: const Text(
          'You will need to log in again to access the kitchen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
