import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/kitchen/account/repository/account_repository.dart';
import 'package:restaurant_fifo/pages/kitchen/account/view_model/account_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<AccountViewModel>(
      viewModel: AccountViewModel(AccountRepository()),
      initOnce: true,
      key: const Key('AccountView'),
      view: (context) {
        final vm = context.watch<AccountViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,
          appBar: AppBar(
            title: const Text(
              'Kitchen Staff Management',
              style: TextStyle(
                color: AppRestaurantColors.background,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppRestaurantColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppRestaurantColors.background,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // --- CREATE BUTTON (PANGGIL BOTTOM SHEET) ---
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppRestaurantColors.primary,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppRestaurantColors.background,
                shape: RoundedRectangleBorder(
                  // Radius Besar standar: 16.0
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                builder: (ctx) => AdminFormBottomSheet(vm: vm),
              );
            },
            child: const Icon(
              Icons.person_add,
              color: AppRestaurantColors.accent,
            ),
          ),
          body: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppRestaurantColors.primary,
                  ),
                )
              : vm.staffList.isEmpty
              ? const Center(
                  child: Text(
                    'No staff found.',
                    style: TextStyle(color: AppRestaurantColors.secondary),
                  ),
                )
              : ListView.builder(
                  // Standarisasi padding layar utama: 16.0 (dengan bottom 100 agar aman dari FAB)
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 100,
                  ),
                  itemCount: vm.staffList.length,
                  itemBuilder: (ctx, i) {
                    final staff = vm.staffList[i];
                    final staffName = staff['display_name'] ?? 'Unknown User';

                    final isMe = staff['id'] == vm.originalAdminId;

                    return Card(
                      // Gap antar item Card standar: 16.0
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        // Radius Medium standar: 12.0
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: AppRestaurantColors.background,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isMe
                              ? AppRestaurantColors.accent
                              : AppRestaurantColors.primary,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Row(
                          children: [
                            Text(
                              staffName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppRestaurantColors.primary,
                              ),
                            ),
                            if (isMe) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppRestaurantColors.accent2
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'You',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppRestaurantColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          'ID: ${staff['id'].toString().substring(0, 8)}...\nRole: Kitchen Admin',
                          style: TextStyle(
                            color: AppRestaurantColors.secondary,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isMe)
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: AppRestaurantColors.secondary,
                                ),
                                tooltip: 'Edit My Profile',
                                onPressed: () => _showEditProfileSheet(
                                  context,
                                  vm,
                                  staff['id'],
                                  staffName,
                                  vm.currentUserEmail, // Pastikan ini sudah ada di ViewModel
                                  staff['phone'] ?? '',
                                ),
                              ),
                            if (!isMe)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete Admin',
                                onPressed: () =>
                                    _confirmDelete(context, vm, staff),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  
  // --- DIALOG DELETE ---
  void _confirmDelete(
    BuildContext context,
    AccountViewModel vm,
    Map<String, dynamic> staff,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppRestaurantColors.background,
        shape: RoundedRectangleBorder(
          // Radius Besar standar untuk Dialog/Sheet: 16.0
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Admin Account?',
          style: TextStyle(
            color: AppRestaurantColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${staff['display_name'] ?? 'this user'}? Their profile will be permanently removed.',
          style: const TextStyle(color: AppRestaurantColors.secondary),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                // Radius Medium standar tombol: 12.0
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
                // Radius Medium standar tombol: 12.0
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              vm.deleteAdminAccount(staff['id']);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET BOTTOM SHEET UNTUK FORM ADD ADMIN
// ============================================================================
class AdminFormBottomSheet extends StatefulWidget {
  final AccountViewModel vm;

  const AdminFormBottomSheet({super.key, required this.vm});

  @override
  State<AdminFormBottomSheet> createState() => _AdminFormBottomSheetState();
}

class _AdminFormBottomSheetState extends State<AdminFormBottomSheet> {
  String formEmail = '';
  String formPassword = '';
  String formName = '';
  String formPhone = '';

  bool isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    // Helper Dekorasi Input agar seragam dan rapi
    InputDecoration buildInputDecoration(String label, {Widget? suffixIcon}) {
      return InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          // Radius Medium standar: 12.0
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppRestaurantColors.primary),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
    }

    return SizedBox(
      height: 0.85*MediaQuery.of(context).size.height,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          // Standarisasi padding Sheet: 16.0
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER FORM ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Kitchen Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppRestaurantColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            // Gap standar Header ke Form: 24.0
            SizedBox(height: 24),

            // --- AREA INPUT TEKS ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: buildInputDecoration('Email'),
                      onChanged: (val) => formEmail = val,
                    ),
                    // Gap antar elemen vertikal standar: 16.0
                    SizedBox(height: 16),

                    TextFormField(
                      obscureText: isPasswordHidden,
                      decoration: buildInputDecoration(
                        'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppRestaurantColors.secondary,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordHidden = !isPasswordHidden;
                            });
                          },
                        ),
                      ),
                      onChanged: (val) => formPassword = val,
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      decoration: buildInputDecoration('Display Name'),
                      onChanged: (val) => formName = val,
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: buildInputDecoration('Phone Number'),
                      onChanged: (val) => formPhone = val,
                    ),

                    // Gap section dari form ke tombol aksi bawah: 24.0
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity, 

              height: 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppRestaurantColors.primary,
                  shape: RoundedRectangleBorder(
                    // Radius Medium standar: 12.0
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (formEmail.trim().isEmpty ||
                      formPassword.isEmpty ||
                      formName.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    await vm.createNewAdmin(
                      formEmail.trim(),
                      formPassword,
                      formName.trim(),
                      formPhone.trim(),
                    );

                    if (context.mounted) {
                      Navigator.pop(context); // Tutup BottomSheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'New kitchen admin added successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add new admin: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  'Save Admin',
                  style: TextStyle(
                    color: AppRestaurantColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // Ekstra padding bawah
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- TAMBAHKAN FUNGSI INI DI DALAM CLASS AccountView ---
void _showEditProfileSheet(
  BuildContext context,
  AccountViewModel vm,
  String userId,
  String currentName,
  String currentEmail,
  String currentPhone,
) {
  String newName = currentName;
  String newPhone = currentPhone;
  String newEmail = '';
  String newPassword = '';
  String currentPassword = '';

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
                      labelText: 'Current Password (Required for Verification)',
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
                      ), // <--- PERBAIKAN: Tutup kurung ditambahkan di sini
                      onPressed: () async {
                        if (newName.isEmpty || currentPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Name and Current Password are required',
                              ),
                            ),
                          );
                          return;
                        }

                        // 1. Update Profile (Name/Phone)
                        bool profileOk = await vm.updateProfile(
                          userId,
                          newName,
                          newPhone,
                        );

                        // 2. Update Security if needed
                        String? securityError;
                        if (newEmail.isNotEmpty || newPassword.isNotEmpty) {
                          securityError = await vm.updateSecuritySettings(
                            currentEmail,
                            currentPassword,
                            newEmail.isNotEmpty ? newEmail : null,
                            newPassword.isNotEmpty ? newPassword : null,
                          );
                        }

                        if (profileOk && securityError == null) {
                          if (context.mounted) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                securityError ?? 'Failed to update profile',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'SAVE CHANGES',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
