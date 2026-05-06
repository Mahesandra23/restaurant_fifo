import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/providers/session_provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/navigator/route_list.dart';
import 'package:restaurant_fifo/pages/customer/Profile/repository/profile_repository.dart';

import 'package:restaurant_fifo/pages/customer/Profile/view_model/profile_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Membaca sesi dari Provider Global
    final session = context.watch<SessionProvider>();
    final user = session.currentUserProfile;

    // Jika user null, berarti dia GUEST
    if (user == null) {
      return _buildGuestView(context);
    }

    // Jika sudah Login, tampilkan Profile sungguhan
    return MvvmBuilder<ProfileViewModel>(
      viewModel: ProfileViewModel(ProfileRepository(), user.id),
      initOnce: true,
      key: const Key('ProfileView'),
      view: (context) {
        final vm = context.watch<ProfileViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,
          appBar: AppBar(
            title: const Text('My Profile', style: TextStyle(color: AppRestaurantColors.primary, fontWeight: FontWeight.bold)),
            backgroundColor: AppRestaurantColors.background,
            elevation: 0,
            centerTitle: true,
          ),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppRestaurantColors.primary))
              : RefreshIndicator(
                  color: AppRestaurantColors.primary,
                  onRefresh: () => vm.loadOrderHistory(user.id),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCard(context, vm, user.id, user.displayName, user.email, session),
                        const SizedBox(height: 24),
                        const Text("Order History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
                        const SizedBox(height: 12),
                        _buildOrderHistory(vm),
                        const SizedBox(height: 40),
                        _buildActionButtons(context, vm, session, user.id),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  // ==========================================
  // TAMPILAN GUEST (BELUM LOGIN)
  // ==========================================
  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppRestaurantColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 100, color: AppRestaurantColors.secondary.withOpacity(0.5)),
              const SizedBox(height: 20),
              const Text(
                'Anda masuk sebagai Guest',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login atau buat akun baru untuk mulai memesan makanan dan melihat riwayat transaksi Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppRestaurantColors.secondary),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppRestaurantColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // TODO: Arahkan ke rute Login
                    Navigator.pushNamed(context, RouteList.AuthSelector); 
                  },
                  child: const Text('Login / Sign Up', style: TextStyle(color: AppRestaurantColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAMPILAN USER LOGIN
  // ==========================================
  
  Widget _buildProfileCard(BuildContext context, ProfileViewModel vm, String userId, String name, String email, SessionProvider session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppRestaurantColors.accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppRestaurantColors.accent),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppRestaurantColors.primary,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 24, color: AppRestaurantColors.accent, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(color: AppRestaurantColors.secondary, fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppRestaurantColors.primary),
            onPressed: () => _showEditProfileSheet(context, vm, session, userId, name),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistory(ProfileViewModel vm) {
    if (vm.orderHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: const Text("Belum ada riwayat pesanan.", textAlign: TextAlign.center, style: TextStyle(color: AppRestaurantColors.secondary)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.orderHistory.length,
      itemBuilder: (context, index) {
        final order = vm.orderHistory[index];
        Color statusColor = order.status == 'completed' ? Colors.green : Colors.orange;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: AppRestaurantColors.background,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
                    Text(order.date, style: const TextStyle(color: AppRestaurantColors.secondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(order.itemsSummary, style: const TextStyle(color: AppRestaurantColors.primary, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rp ${order.totalPrice}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppRestaurantColors.primary, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(order.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ProfileViewModel vm, SessionProvider session, String userId) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppRestaurantColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout, color: AppRestaurantColors.primary),
            label: const Text('Log Out', style: TextStyle(color: AppRestaurantColors.primary, fontWeight: FontWeight.bold)),
            onPressed: () async {
              await session.logout();
              Navigator.pushNamedAndRemoveUntil(context, RouteList.AuthSelector, (route) => false);
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => _showDeleteConfirmation(context, vm, session, userId),
            child: const Text('Delete Account', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BOTTOM SHEETS & DIALOGS
  // ==========================================

  void _showEditProfileSheet(BuildContext context, ProfileViewModel vm, SessionProvider session, String userId, String currentName) {
    String newName = currentName;
    String newPhone = ''; // Asumsi dikosongkan untuk input baru atau ambil dari data jika ada

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppRestaurantColors.primary)),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: newName,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                onChanged: (val) => newName = val,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nomor HP Baru', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                onChanged: (val) => newPhone = val,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppRestaurantColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    if (newName.isNotEmpty) {
                      bool success = await vm.updateProfile(userId, newName, newPhone);
                      if (success) {
                        // Perbarui data di SessionProvider agar UI Header langsung berubah
                        await session.fetchCurrentUser();
                        Navigator.pop(ctx);
                      }
                    }
                  },
                  child: const Text('SIMPAN PERUBAHAN', style: TextStyle(color: AppRestaurantColors.accent, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, ProfileViewModel vm, SessionProvider session, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppRestaurantColors.background,
        title: const Text('Hapus Akun?', style: TextStyle(color: AppRestaurantColors.primary, fontWeight: FontWeight.bold)),
        content: const Text('Tindakan ini tidak dapat dibatalkan. Semua data riwayat pesanan Anda akan terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: AppRestaurantColors.secondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await vm.deleteAccount(userId);
              await session.logout(); // Bersihkan sesi lokal
              Navigator.pushNamedAndRemoveUntil(context, RouteList.AuthSelector, (route) => false);
            },
            child: const Text('Hapus Permanen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}