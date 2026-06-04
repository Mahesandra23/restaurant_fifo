import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/providers/session_provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/navigator/route_list.dart';
import 'package:restaurant_fifo/pages/customer/Profile/repository/profile_repository.dart';
import 'package:restaurant_fifo/pages/customer/Profile/view_model/profile_view_model.dart';
import 'package:restaurant_fifo/pages/customer/history/history_view.dart';
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
        final String currentPhone = vm.userPhone;

        return FocusDetector(
          onFocusGained: () => vm.init(),
          child: Scaffold(
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
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppRestaurantColors.background,
                ),
                onPressed: () => Navigator.pop(context),
              ),
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
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileCard(
                            context,
                            vm,
                            user.id,
                            user.displayName,
                            user.email,
                            currentPhone,
                            session,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Orders',
                                style: TextStyle(
                                  color: AppRestaurantColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HistoryView(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'See All ➔',
                                  style: TextStyle(
                                    color: AppRestaurantColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildOrderHistory(vm),
                          SizedBox(height: 16),
                          _buildActionButtons(context, vm, session, user.id),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildGuestView(BuildContext context, SessionProvider session) {
    return Scaffold(
      backgroundColor: AppRestaurantColors.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle,
                size: 100,
                color: AppRestaurantColors.secondary.withOpacity(0.5),
              ),
              SizedBox(height: 20),
              Text(
                'You are logged in as a Guest',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.primary,
                ),
              ),
              SizedBox(height: 8),
              const Text(
                'Login to your account or create a new one to view your profile and order history.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppRestaurantColors.secondary),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppRestaurantColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                      fontSize: 16,
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

  Widget _buildProfileCard(
    BuildContext context,
    ProfileViewModel vm,
    String userId,
    String name,
    String email,
    String phone,
    SessionProvider session,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
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
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 18,
                color: AppRestaurantColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppRestaurantColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: AppRestaurantColors.secondary,
                    fontSize: 12,
                  ),
                ),
                // Menampilkan Nomor HP jika ada
                if (phone.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    phone,
                    style: TextStyle(
                      color: AppRestaurantColors.secondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppRestaurantColors.primary),
            onPressed: () => _showEditProfileSheet(
              context,
              vm,
              session,
              userId,
              name,
              email,
              phone,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistory(ProfileViewModel vm) {
    if (vm.orderHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppRestaurantColors.accent2.withOpacity(0.05),
          border: Border.all(color: AppRestaurantColors.accent, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Belum ada riwayat pesanan.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppRestaurantColors.secondary),
        ),
      );
    }

    final displayCount = vm.orderHistory.length > 5
        ? 5
        : vm.orderHistory.length;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        final order = vm.orderHistory[index];
        Color statusColor = order.status == 'completed'
            ? Colors.green
            : Colors.orange;

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppRestaurantColors.accent2.withOpacity(0.05),
            border: Border.all(color: AppRestaurantColors.accent, width: 1.2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: Offset(0, 2),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    order.date,
                    style: TextStyle(
                      color: AppRestaurantColors.secondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                order.itemsSummary,
                style: TextStyle(
                  color: AppRestaurantColors.primary,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.totalPrice,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
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
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppRestaurantColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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

  void _showEditProfileSheet(
    BuildContext context,
    ProfileViewModel vm,
    SessionProvider session,
    String userId,
    String currentName,
    String currentEmail,
    String currentPhone,
  ) {
    String newName = currentName;
    String newPhone = currentPhone; // Pre-fill dengan nomor hp yang ada
    String newEmail = '';
    String newPassword = '';
    String currentPassword = '';

    // Variabel state untuk toggle visibility password
    bool obscureNewPassword = true;
    bool obscureCurrentPassword = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        // Gunakan StatefulBuilder agar bisa melakukan setState secara lokal di dalam BottomSheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppRestaurantColors.primary,
                      ),
                    ),
                    SizedBox(height: 16),

                    // --- DATA PROFIL UMUM ---
                    TextFormField(
                      initialValue: newName,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) => newName = val,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: newPhone,
                      decoration: InputDecoration(
                        labelText: 'New Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (val) => newPhone = val,
                    ),

                    SizedBox(height: 24),
                    Divider(color: Colors.grey.shade300),
                    SizedBox(height: 16),

                    // --- PENGATURAN KEAMANAN (SENSITIF) ---
                    Text(
                      'Security Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppRestaurantColors.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fill out this section only if you want to change your email or password.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppRestaurantColors.secondary,
                      ),
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'New Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) => newEmail = val,
                    ),
                    SizedBox(height: 16),

                    // --- PASSWORD BARU DENGAN TOGGLE EYE ---
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppRestaurantColors.primary,
                          ),
                          onPressed: () {
                            setModalState(() {
                              obscureNewPassword = !obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: obscureNewPassword,
                      onChanged: (val) => newPassword = val,
                    ),
                    SizedBox(height: 16),

                    // --- PASSWORD SAAT INI DENGAN TOGGLE EYE ---
                    TextFormField(
                      decoration: InputDecoration(
                        labelText:
                            'Current Password (Required for Verification)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.orangeAccent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.orangeAccent,
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrentPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppRestaurantColors.primary,
                          ),
                          onPressed: () {
                            setModalState(() {
                              obscureCurrentPassword = !obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: obscureCurrentPassword,
                      onChanged: (val) => currentPassword = val,
                    ),

                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppRestaurantColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (newName.isEmpty) return;

                          // 1. Eksekusi Update Nama/Nomor HP (Profil Biasa)
                          bool successProfile = await vm.updateProfile(
                            userId,
                            newName,
                            newPhone,
                          );
                          String? securityError;

                          // 2. Eksekusi Update Keamanan jika ada form yang diisi
                          if (newEmail.isNotEmpty || newPassword.isNotEmpty) {
                            if (currentPassword.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter your current password to verify the security changes.',
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            securityError = await vm.updateSecuritySettings(
                              currentEmail,
                              currentPassword,
                              newEmail.isNotEmpty ? newEmail : null,
                              newPassword.isNotEmpty ? newPassword : null,
                            );
                          }

                          if (successProfile && securityError == null) {
                            await session.fetchCurrentUser();
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Profile has been updated successfully! Please check your email if you changed it.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    securityError ??
                                        'Failed to update profile.',
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'SAVE CHANGES',
                          style: TextStyle(
                            color: AppRestaurantColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account?',
          style: TextStyle(
            color: AppRestaurantColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This action cannot be undone. All your order history data will be deleted.',
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(12),
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
              'Delete Permanently',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
