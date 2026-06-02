import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart'; // Tambahkan ScreenUtil
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/kitchen/banner/repository/banner_repository.dart';
import 'package:restaurant_fifo/pages/kitchen/banner/view_model/banner_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class BannerView extends StatelessWidget {
  const BannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<BannerViewModel>(
      viewModel: BannerViewModel(BannerRepository()),
      initOnce: true,
      key: const Key('BannerView'),
      view: (context) {
        final vm = context.watch<BannerViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,
          appBar: AppBar(
            title: const Text(
              'Manage Banners',
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppRestaurantColors.primary,
            onPressed: vm.isUploading
                ? null
                : () => _showAddBottomSheet(context, vm),
            child: vm.isUploading
                ? const CircularProgressIndicator(
                    color: AppRestaurantColors.accent,
                  )
                : const Icon(Icons.add, color: AppRestaurantColors.accent),
          ),
          body: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppRestaurantColors.primary,
                  ),
                )
              : vm.banners.isEmpty
              ? const Center(
                  child: Text(
                    'No banners available.',
                    style: TextStyle(color: AppRestaurantColors.secondary),
                  ),
                )
              : ListView.builder(
                  // Standarisasi padding layar: 16.0 (dengan bottom 100 agar aman dari FAB)
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 100,
                  ),
                  itemCount: vm.banners.length,
                  itemBuilder: (ctx, i) {
                    final banner = vm.banners[i];
                    final uploaderName = banner['profiles'] != null
                        ? banner['profiles']['display_name']
                        : 'Unknown Admin';

                    return Card(
                      // Clip agar gambar mengikuti radius Card
                      clipBehavior: Clip.antiAlias,
                      // Gap standar antar item list/card: 16.0
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        // Radius Medium standar: 12.0
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            banner['image_url'],
                            height: 160,
                            width:
                                double.infinity, // Mengubah double.infinity menjadi double.infinity
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              height: 160,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              banner['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppRestaurantColors.primary,
                              ),
                            ),
                            subtitle: Text(
                              'Uploaded by: $uploaderName\n${banner['is_active'] ? 'Status: Active' : 'Status: Hidden'}',
                              style: TextStyle(
                                color: banner['is_active']
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: banner['is_active'],
                                  activeColor: AppRestaurantColors.primary,
                                  onChanged: (val) => vm.toggleStatus(
                                    banner['id'],
                                    banner['is_active'],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(context, vm, banner),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _showAddBottomSheet(BuildContext context, BannerViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: RoundedRectangleBorder(
        // Radius Besar standar: 16.0
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => BannerFormBottomSheet(vm: vm),
    );
  }

  void _confirmDelete(
    BuildContext context,
    BannerViewModel vm,
    Map<String, dynamic> banner,
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
          'Delete Banner?',
          style: TextStyle(
            color: AppRestaurantColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will permanently delete the image from storage.',
          style: TextStyle(color: AppRestaurantColors.secondary),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                // Radius Medium standar: 12.0
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
                // Radius Medium standar: 12.0
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              vm.deleteBanner(banner['id'], banner['image_path']);
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

// --- NEW BOTTOM SHEET COMPONENT ---
class BannerFormBottomSheet extends StatefulWidget {
  final BannerViewModel vm;

  const BannerFormBottomSheet({super.key, required this.vm});

  @override
  State<BannerFormBottomSheet> createState() => _BannerFormBottomSheetState();
}

class _BannerFormBottomSheetState extends State<BannerFormBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  Uint8List? selectedImageBytes;
  String? selectedFileName;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        selectedImageBytes = bytes;
        selectedFileName = image.name;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    return SizedBox(
      height: 0.85 * MediaQuery.of(context).size.height,
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
            // --- FORM HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Banner',
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
            // Gap antar section utama (Header ke Image Picker): 24.0
            SizedBox(height: 24),

            // --- IMAGE PICKER AREA ---
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity, // Menggunakan .sw untuk penuh layar
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    // Radius Medium standar: 12.0
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppRestaurantColors.primary.withOpacity(0.5),
                      style: BorderStyle.solid,
                    ),
                    image: selectedImageBytes != null
                        ? DecorationImage(
                            image: MemoryImage(selectedImageBytes!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: selectedImageBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: AppRestaurantColors.secondary,
                              size: 30,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Choose Banner Image',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppRestaurantColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            // Gap antar section utama (Image Picker ke Text Input): 24.0
            SizedBox(height: 24),

            // --- TEXT INPUT AREA ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Banner Title',
                        // Radius Medium standar untuk input form: 12.0
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppRestaurantColors.primary,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    // Gap ekstra untuk ruang aman scroll
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // --- SAVE BUTTON ---
            SizedBox(
              width: double.infinity, // Mengubah double.infinity menjadi double.infinity
              // Standarisasi Tinggi Tombol: 55.0
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
                  if (_titleController.text.trim().isEmpty ||
                      selectedImageBytes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Title and Image are required!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Close bottom sheet and start upload
                  Navigator.pop(context);
                  vm.uploadNewBanner(
                    _titleController.text.trim(),
                    selectedFileName!,
                    selectedImageBytes!,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Uploading banner...'),
                      backgroundColor: AppRestaurantColors.secondary,
                    ),
                  );
                },
                child: Text(
                  'Save Banner',
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
