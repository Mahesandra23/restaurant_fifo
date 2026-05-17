import 'dart:typed_data';
import 'package:flutter/material.dart';
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
            title: const Text('Manage Banners', style: TextStyle(color: AppRestaurantColors.accent)),
            backgroundColor: AppRestaurantColors.primary,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppRestaurantColors.primary,
            onPressed: vm.isUploading ? null : () => _showAddBottomSheet(context, vm),
            child: vm.isUploading 
                ? const CircularProgressIndicator(color: AppRestaurantColors.accent)
                : const Icon(Icons.add, color: AppRestaurantColors.accent),
          ),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppRestaurantColors.primary))
              : vm.banners.isEmpty 
                  ? const Center(child: Text('No banners available.', style: TextStyle(color: AppRestaurantColors.secondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.banners.length,
                      itemBuilder: (ctx, i) {
                        final banner = vm.banners[i];
                        final uploaderName = banner['profiles'] != null ? banner['profiles']['display_name'] : 'Unknown Admin';

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                banner['image_url'], 
                                height: 160, 
                                width: double.infinity, 
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(height: 160, color: Colors.grey.shade300, child: const Center(child: Icon(Icons.broken_image))),
                              ),
                              ListTile(
                                title: Text(banner['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  'Uploaded by: $uploaderName\n${banner['is_active'] ? 'Status: Active' : 'Status: Hidden'}', 
                                  style: TextStyle(color: banner['is_active'] ? Colors.green : Colors.red, fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value: banner['is_active'],
                                      activeColor: AppRestaurantColors.primary,
                                      onChanged: (val) => vm.toggleStatus(banner['id'], banner['is_active']),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDelete(context, vm, banner),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BannerFormBottomSheet(vm: vm),
    );
  }

  void _confirmDelete(BuildContext context, BannerViewModel vm, Map<String, dynamic> banner) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Banner?'),
        content: const Text('This will permanently delete the image from storage.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              vm.deleteBanner(banner['id'], banner['image_path']);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- NEW BOTTOM SHEET COMPONENT ---
class BannerFormBottomSheet extends StatefulWidget {
  final BannerViewModel vm;

  const BannerFormBottomSheet({
    super.key,
    required this.vm,
  });

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
            // --- FORM HEADER ---
            const Text(
              'Add New Banner',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppRestaurantColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            // --- IMAGE PICKER AREA ---
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppRestaurantColors.primary,
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
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                color: AppRestaurantColors.secondary, size: 30),
                            SizedBox(height: 4),
                            Text(
                              'Choose Image',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppRestaurantColors.secondary,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- TEXT INPUT AREA ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Banner Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // --- SAVE BUTTON ---
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
                  if (_titleController.text.trim().isEmpty || selectedImageBytes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Title and Image are required!'),
                      ),
                    );
                    return;
                  }
                  
                  // Close bottom sheet and start upload
                  Navigator.pop(context);
                  vm.uploadNewBanner(
                    _titleController.text, 
                    selectedFileName!, 
                    selectedImageBytes!
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Uploading banner...'))
                  );
                },
                child: const Text(
                  'Save Banner',
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
  }
}