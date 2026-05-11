import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/view_model/menu_view_model.dart';

class MenuFormBottomSheet extends StatefulWidget {
  final MenuViewModel vm;
  final MenuModel? existingMenu;

  const MenuFormBottomSheet({
    super.key,
    required this.vm,
    this.existingMenu,
  });

  @override
  State<MenuFormBottomSheet> createState() => _MenuFormBottomSheetState();
}

class _MenuFormBottomSheetState extends State<MenuFormBottomSheet> {
  late bool isEdit;
  late String formName;
  late String formDesc;
  late int formPrice;
  late String formCatId;
  late List<String> selectedIngIds;
  File? selectedImageFile;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data di sini (hanya dipanggil sekali saat form dibuka)
    isEdit = widget.existingMenu != null;
    formName = isEdit ? widget.existingMenu!.name : '';
    formDesc = isEdit ? widget.existingMenu!.description : '';
    formPrice = isEdit ? widget.existingMenu!.price : 0;
    formCatId = isEdit
        ? widget.existingMenu!.categoryId
        : widget.vm.categories.first.id;
    selectedIngIds = isEdit
        ? widget.existingMenu!.ingredients.map((e) => e.id).toList()
        : [];
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        selectedImageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kita gunakan widget.vm untuk memanggil fungsi dari ViewModel
    final vm = widget.vm;
    final existingMenu = widget.existingMenu;

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
                Text(
                  isEdit ? 'Edit Menu' : 'Tambah Menu Baru',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppRestaurantColors.primary,
                  ),
                ),
                if (isEdit)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      vm.deleteMenu(existingMenu!.id);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // --- AREA PEMILIH GAMBAR ---
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
                    image: selectedImageFile != null
                        ? DecorationImage(
                            image: FileImage(selectedImageFile!),
                            fit: BoxFit.cover,
                          )
                        : (isEdit && existingMenu!.imageUrl.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(existingMenu.imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: selectedImageFile == null &&
                          (!isEdit || existingMenu!.imageUrl.isEmpty)
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                color: AppRestaurantColors.secondary, size: 30),
                            SizedBox(height: 4),
                            Text(
                              'Pilih Foto',
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

            // --- AREA INPUT TEKS & CHECKBOX ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: formName,
                      decoration: const InputDecoration(
                        labelText: 'Nama Makanan',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => formName = val,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            initialValue: formPrice > 0 ? formPrice.toString() : '',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga (Rp)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => formPrice = int.tryParse(val) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: formCatId,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                              border: OutlineInputBorder(),
                            ),
                            items: vm.categories
                                .map((c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.name),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => formCatId = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: formDesc,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => formDesc = val,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Resep / Bahan Baku:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppRestaurantColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount: vm.availableIngredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = vm.availableIngredients[index];
                            final isSelected = selectedIngIds.contains(ingredient.id);
                            
                            return CheckboxListTile(
                              title: Text(
                                ingredient.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                              value: isSelected,
                              dense: true,
                              activeColor: AppRestaurantColors.primary,
                              onChanged: (bool? checked) {
                                setState(() {
                                  if (checked == true) {
                                    selectedIngIds.add(ingredient.id);
                                  } else {
                                    selectedIngIds.remove(ingredient.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

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
                onPressed: () async{
                  if (formName.trim().isEmpty || formPrice <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama dan Harga wajib diisi!'),
                      ),
                    );
                    return;
                  }
                  await vm.saveMenu(
                    id: isEdit ? existingMenu!.id : null,
                    name: formName,
                    desc: formDesc,
                    price: formPrice,
                    categoryId: formCatId,
                    ingredientIds: selectedIngIds,
                    imageFile: selectedImageFile,
                    existingImageUrl: isEdit ? existingMenu!.imageUrl : null,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'SIMPAN MENU',
                  style: TextStyle(
                    color: AppRestaurantColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}