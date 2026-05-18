import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/providers/session_provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/navigator/route_list.dart';
import 'package:restaurant_fifo/pages/customer/Profile/repository/profile_repository.dart';

import 'package:restaurant_fifo/pages/customer/Profile/view_model/profile_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final user = session.currentUserProfile;

    final isGuest =
        Supabase.instance.client.auth.currentUser?.isAnonymous ?? false;

    if (user == null || isGuest) {
      return _buildGuestView(context, session);
    }

    return MvvmBuilder<ProfileViewModel>(
      viewModel: ProfileViewModel(ProfileRepository(), user.id),
      initOnce: true,
      key: const Key('ProfileView'),
      view: (context) {
        final vm = context.watch<ProfileViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,
          appBar: AppBar(
            title: const Text(
              'My Profile',
              style: TextStyle(
                color: AppRestaurantColors.background,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppRestaurantColors.primary,
            elevation: 0,
            centerTitle: true,
          ),
          body: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppRestaurantColors.primary,
                  ),
                )
              : RefreshIndicator(
                  color: AppRestaurantColors.primary,
                  onRefresh: () => vm.loadOrderHistory(user.id),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    // Standarisasi padding layar utama: 16.0
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCard(
                          context,
                          vm,
                          user.id,
                          user.displayName,
                          user.email,
                          session,
                        ),
                        // Gap standar antar section utama: 24.0
                        SizedBox(height: 16.h),
                        Text(
                          "Order History",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppRestaurantColors.primary,
                          ),
                        ),
                        // Gap standar elemen teks ke list: 16.0
                        SizedBox(height: 16.h),
                        _buildOrderHistory(vm),

                        // Padding ekstra di bagian paling bawah sebelum tombol
                        SizedBox(height: 16.h),
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
  Widget _buildGuestView(BuildContext context, SessionProvider session) {
    return Scaffold(
      backgroundColor: AppRestaurantColors.background,
      body: Center(
        child: Padding(
          // Standarisasi padding: 16.0
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle,
                size: 100.w,
                color: AppRestaurantColors.secondary.withOpacity(0.5),
              ),
              SizedBox(height: 20.h),
              Text(
                'Anda masuk sebagai Guest',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.primary,
                ),
              ),
              SizedBox(height: 8.h),
              const Text(
                'Login atau buat akun baru untuk mulai memesan makanan dan melihat riwayat transaksi Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppRestaurantColors.secondary),
              ),
              // Gap standar section: 24.0
              SizedBox(height: 24.h),
              SizedBox(
                width: 1.sw, // Mengubah double.infinity menjadi 1.sw
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppRestaurantColors.primary,
                    // Standarisasi padding tombol: vertical 12.0
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      // Radius standar tombol: 12.0
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () async {
                    await session.logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RouteList.AuthSelector,
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Login / Sign Up',
                    style: TextStyle(
                      color: AppRestaurantColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
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

  Widget _buildProfileCard(
    BuildContext context,
    ProfileViewModel vm,
    String userId,
    String name,
    String email,
    SessionProvider session,
  ) {
    return Container(
      // Padding dalam Card disamakan ke 16.0
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppRestaurantColors.accent.withOpacity(0.2),
        // Radius besar untuk Card Utama Profile: 16.0
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppRestaurantColors.accent),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppRestaurantColors.primary,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 18.sp,
                color: AppRestaurantColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Gap standar elemen horizontal: 16.0
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppRestaurantColors.primary,
                  ),
                ),
                // Gap kecil antar teks judul dan subtitle
                SizedBox(height: 4.h),
                Text(
                  email,
                  style: TextStyle(
                    color: AppRestaurantColors.secondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppRestaurantColors.primary),
            onPressed: () =>
                _showEditProfileSheet(context, vm, session, userId, name),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistory(ProfileViewModel vm) {
    if (vm.orderHistory.isEmpty) {
      return Container(
        width: 1.sw, // Mengubah double.infinity menjadi 1.sw
        // Standarisasi padding dalam Card: 16.0
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppRestaurantColors.accent2.withOpacity(
            0.05,
          ), // Disamakan warna fill-nya
          border: Border.all(
            color: AppRestaurantColors.accent,
            width: 1,
          ), // Border accent
          // Radius standar item list/card kecil: 12.0
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Text(
          "Belum ada riwayat pesanan.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppRestaurantColors.secondary),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.orderHistory.length,
      itemBuilder: (context, index) {
        final order = vm.orderHistory[index];
        Color statusColor = order.status == 'completed'
            ? Colors.green
            : Colors.orange;

        // Mengganti Card dengan Container agar bisa custom border color dan fill accent2
        return Container(
          // Gap vertikal antar list disamakan ke: 16.0
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(
            16.w,
          ), // Padding dalam card list standar: 16.0
          decoration: BoxDecoration(
            color: AppRestaurantColors.accent2.withOpacity(
              0.05,
            ), // Fill / Background warna accent2
            border: Border.all(
              color: AppRestaurantColors.accent, // Border warna accent
              width: 1.2, // Ketebalan border garis kartunya
            ),
            // Radius standar Card: 12.0
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.primary,
                    ),
                  ),
                  Text(
                    order.date,
                    style: TextStyle(
                      color: AppRestaurantColors.secondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                order.itemsSummary,
                style: TextStyle(
                  color: AppRestaurantColors.primary,
                  fontSize: 12.sp,
                ),
              ),
              // Gap elemen ke harga/status disamakan: 16.0
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rp ${order.totalPrice}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.primary,
                      fontSize: 14.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      // Radius proporsional untuk tag status: 8.0
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ProfileViewModel vm,
    SessionProvider session,
    String userId,
  ) {
    return Column(
      children: [
        SizedBox(
          width: 1.sw, // Mengubah double.infinity menjadi 1.sw
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              // Padding vertical standar tombol: 12.0
              padding: EdgeInsets.symmetric(vertical: 12.h),
              side: const BorderSide(color: AppRestaurantColors.primary),
              shape: RoundedRectangleBorder(
                // Radius standar tombol: 12.0
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: const Icon(Icons.logout, color: AppRestaurantColors.primary),
            label: const Text(
              'Log Out',
              style: TextStyle(
                color: AppRestaurantColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              await session.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteList.AuthSelector,
                (route) => false,
              );
            },
          ),
        ),
        // Gap standar antar tombol/elemen: 16.0
        SizedBox(height: 16.h),
        SizedBox(
          width: 1.sw, // Mengubah double.infinity menjadi 1.sw
          child: TextButton(
            style: TextButton.styleFrom(
              // Padding vertical standar tombol: 12.0
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                // Radius standar tombol: 12.0
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () =>
                _showDeleteConfirmation(context, vm, session, userId),
            child: const Text(
              'Delete Account',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BOTTOM SHEETS & DIALOGS
  // ==========================================

  void _showEditProfileSheet(
    BuildContext context,
    ProfileViewModel vm,
    SessionProvider session,
    String userId,
    String currentName,
  ) {
    String newName = currentName;
    String newPhone = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: RoundedRectangleBorder(
        // Radius standar besar untuk BottomSheet: 16.0
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            // Padding kanan, kiri, atas disamakan: 16.0
            left: 16.w,
            right: 16.w,
            top: 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.primary,
                ),
              ),
              // Gap standar judul ke form: 16.0
              SizedBox(height: 16.h),
              TextFormField(
                initialValue: newName,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  // Menambahkan radius 12.0 untuk TextField agar seragam dengan SearchBar
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onChanged: (val) => newName = val,
              ),
              // Gap standar antar form: 16.0
              SizedBox(height: 16.h),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nomor HP Baru',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (val) => newPhone = val,
              ),
              // Gap standar section form ke tombol action: 24.0
              SizedBox(height: 24.h),
              SizedBox(
                width: 1.sw, // Mengubah double.infinity menjadi 1.sw
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppRestaurantColors.primary,
                    shape: RoundedRectangleBorder(
                      // Radius standar tombol: 12.0
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () async {
                    if (newName.isNotEmpty) {
                      bool success = await vm.updateProfile(
                        userId,
                        newName,
                        newPhone,
                      );
                      if (success) {
                        await session.fetchCurrentUser();
                        Navigator.pop(ctx);
                      }
                    }
                  },
                  child: const Text(
                    'SIMPAN PERUBAHAN',
                    style: TextStyle(
                      color: AppRestaurantColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Bottom padding ekstra
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ProfileViewModel vm,
    SessionProvider session,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppRestaurantColors.background,
        shape: RoundedRectangleBorder(
          // Menambahkan Radius standar 16.0 untuk Dialog Box
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text(
          'Hapus Akun?',
          style: TextStyle(
            color: AppRestaurantColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Tindakan ini tidak dapat dibatalkan. Semua data riwayat pesanan Anda akan terhapus.',
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppRestaurantColors.secondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () async {
              await vm.deleteAccount(userId);
              await session.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteList.AuthSelector,
                (route) => false,
              );
            },
            child: const Text(
              'Hapus Permanen',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
