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
  
  // Menggunakan Map untuk mencatat id_bahan -> takaran_porsi
  late Map<String, double> selectedIngQuantities;
  String searchQuery = ''; // State untuk filter pencarian bahan baku
  File? selectedImageFile;

  @override
  void initState() {
    super.initState();
    isEdit = widget.existingMenu != null;
    formName = isEdit ? widget.existingMenu!.name : '';
    formDesc = isEdit ? widget.existingMenu!.description : '';
    formPrice = isEdit ? widget.existingMenu!.price : 0;
    formCatId = isEdit
        ? widget.existingMenu!.categoryId
        : (widget.vm.categories.isNotEmpty ? widget.vm.categories.first.id : '');
        
    // Inisialisasi Map dari data menu yang diedit jika ada
    selectedIngQuantities = isEdit
        ? { for (var e in widget.existingMenu!.ingredients) e.id : e.quantityNeeded }
        : {};
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
    final vm = widget.vm;
    final existingMenu = widget.existingMenu;

    // Filter list bahan berdasarkan input pencarian pengguna
    final filteredIngredients = vm.availableIngredients.where((ing) {
      return ing.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

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
                  isEdit ? 'Edit Menu' : 'Add New Menu',
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
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppRestaurantColors.primary,
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
                            Icon(Icons.add_a_photo, color: AppRestaurantColors.secondary, size: 24),
                            SizedBox(height: 4),
                            Text(
                              'Choose Image',
                              style: TextStyle(fontSize: 11, color: AppRestaurantColors.secondary),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- AREA INPUT TEKS ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: formName,
                      decoration: const InputDecoration(
                        labelText: 'Food Name',
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
                              labelText: 'Price (Rp)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => formPrice = int.tryParse(val) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: formCatId.isNotEmpty ? formCatId : null,
                            decoration: const InputDecoration(
                              labelText: 'Category',
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
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => formDesc = val,
                    ),
                    const SizedBox(height: 16),

                    // --- BAGIAN INGREDIENTS DENGAN SEARCH & TAKARAN ---
                    const Text(
                      'Recipe or Ingredients (Per Portion):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppRestaurantColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // 2. Form Fitur Pencarian Bahan Baku
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Search ingredients...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount: filteredIngredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = filteredIngredients[index];
                            final isSelected = selectedIngQuantities.containsKey(ingredient.id);
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: AppRestaurantColors.primary,
                                    onChanged: (bool? checked) {
                                      setState(() {
                                        if (checked == true) {
                                          // Set default porsi awal 1.0 saat dicek
                                          selectedIngQuantities[ingredient.id] = 1.0;
                                        } else {
                                          selectedIngQuantities.remove(ingredient.id);
                                        }
                                      });
                                    },
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      ingredient.name,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  // 1. Kolom Input Pengurangan Takaran Bahan
                                  if (isSelected)
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: SizedBox(
                                          height: 38,
                                          child: TextFormField(
                                            initialValue: selectedIngQuantities[ingredient.id]?.toString() ?? '1',
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            style: const TextStyle(fontSize: 13),
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                              border: const OutlineInputBorder(),
                                              suffixText: ingredient.unit, // Satuan otomatis dinamis
                                              suffixStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                            onChanged: (val) {
                                              final double qty = double.tryParse(val) ?? 0.0;
                                              selectedIngQuantities[ingredient.id] = qty;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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
                onPressed: () async {
                  if (formName.trim().isEmpty || formPrice <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name and Price must be filled and valid!')),
                    );
                    return;
                  }
                  if (selectedIngQuantities.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one ingredient!')),
                    );
                    return;
                  }
                  
                  await vm.saveMenu(
                    id: isEdit ? existingMenu!.id : null,
                    name: formName,
                    desc: formDesc,
                    price: formPrice,
                    categoryId: formCatId,
                    ingredientQuantities: selectedIngQuantities, // Kirim map data bahan & takaran
                    imageFile: selectedImageFile,
                    existingImageUrl: isEdit ? existingMenu!.imageUrl : null,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Save Menu',
                  style: TextStyle(
                    color: AppRestaurantColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}