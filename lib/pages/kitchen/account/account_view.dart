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
              style: TextStyle(color: AppRestaurantColors.accent),
            ),
            backgroundColor: AppRestaurantColors.primary,
          ),
          // --- CREATE BUTTON (PANGGIL BOTTOM SHEET) ---
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppRestaurantColors.primary,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.staffList.length,
                  itemBuilder: (ctx, i) {
                    final staff = vm.staffList[i];
                    final staffName = staff['display_name'] ?? 'Unknown User';

                    // PERBAIKAN: Gunakan ID yang sudah dikunci dari ViewModel
                    final isMe = staff['id'] == vm.originalAdminId;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
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
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppRestaurantColors.accent2.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'You',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppRestaurantColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          'ID: ${staff['id'].toString().substring(0, 8)}...\nRole: Kitchen Admin',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppRestaurantColors.secondary),
                              tooltip: 'Edit Name',
                              onPressed: () => _showEditDialog(context, vm, staff),
                            ),
                            if (!isMe)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete Admin',
                                onPressed: () => _confirmDelete(context, vm, staff),
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

  // --- DIALOG UPDATE (EDIT NAME) ---
  void _showEditDialog(BuildContext context, AccountViewModel vm, Map<String, dynamic> staff) {
    final nameController = TextEditingController(text: staff['display_name']); // Ganti ke display_name

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Admin Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppRestaurantColors.accent),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                vm.editStaffName(staff['id'], nameController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- DIALOG DELETE ---
  void _confirmDelete(BuildContext context, AccountViewModel vm, Map<String, dynamic> staff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Admin Account?'),
        content: Text(
          'Are you sure you want to delete ${staff['display_name'] ?? 'this user'}? Their profile will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              vm.deleteAdminAccount(staff['id']);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER FORM ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
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
            const SizedBox(height: 16),

            // --- AREA INPUT TEKS ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => formEmail = val,
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      obscureText: isPasswordHidden,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordHidden ? Icons.visibility_off : Icons.visibility,
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
                    const SizedBox(height: 12),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => formName = val,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => formPhone = val,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppRestaurantColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (formEmail.trim().isEmpty || formPassword.isEmpty || formName.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // Panggil fungsi API melalui ViewModel
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
                          content: Text('New kitchen admin added successfully!'),
                          backgroundColor: AppRestaurantColors.accent,
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
                child: const Text(
                  'Save Admin',
                  style: TextStyle(
                    color: AppRestaurantColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}