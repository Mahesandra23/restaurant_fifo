import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/view_model/menu_view_model.dart';

class MenuFormBottomSheet extends StatefulWidget {
  final MenuViewModel vm;
  final MenuModel? existingMenu;

  const MenuFormBottomSheet({super.key, required this.vm, this.existingMenu});

  @override
  State<MenuFormBottomSheet> createState() => _MenuFormBottomSheetState();
}

class _MenuFormBottomSheetState extends State<MenuFormBottomSheet> {
  late bool isEdit;
  late String formName;
  late String formDesc;
  late int formPrice;
  late String formCatId;

  late Map<String, double> selectedIngQuantities;
  String searchQuery = '';
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
        : (widget.vm.categories.isNotEmpty
              ? widget.vm.categories.first.id
              : '');

    selectedIngQuantities = isEdit
        ? {
            for (var e in widget.existingMenu!.ingredients)
              e.id: e.quantityNeeded,
          }
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

    final filteredIngredients = vm.availableIngredients.where((ing) {
      return ing.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    filteredIngredients.sort((a, b) {
      final aSelected = selectedIngQuantities.containsKey(a.id);
      final bSelected = selectedIngQuantities.containsKey(b.id);

      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return a.name.compareTo(b.name);
    });

    return SizedBox(
      height: 0.85 * MediaQuery.of(context).size.height,
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
                  style: TextStyle(
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
            SizedBox(height: 16),

            // --- AREA SCROLL (FOTO + INPUT TEKS) ---
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- AREA PEMILIH GAMBAR DIPINDAH KE SINI ---
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
                          child:
                              selectedImageFile == null &&
                                  (!isEdit || existingMenu!.imageUrl.isEmpty)
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      color: AppRestaurantColors.secondary,
                                      size: 24,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Choose Image',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppRestaurantColors.secondary,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // --- AREA INPUT TEKS ---
                    TextFormField(
                      initialValue: formName,
                      decoration: const InputDecoration(
                        labelText: 'Food Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => formName = val,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            initialValue: formPrice > 0
                                ? formPrice.toString()
                                : '',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price (Rp)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) =>
                                formPrice = int.tryParse(val) ?? 0,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: formCatId.isNotEmpty ? formCatId : null,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: vm.categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(
                                      c.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => formCatId = val!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      initialValue: formDesc,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => formDesc = val,
                    ),
                    SizedBox(height: 16),

                    // --- BAGIAN INGREDIENTS DENGAN SEARCH & TAKARAN ---
                    const Text(
                      'Recipe or Ingredients (Per Portion):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppRestaurantColors.primary,
                      ),
                    ),
                    SizedBox(height: 8),

                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Search ingredients...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                    SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredIngredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = filteredIngredients[index];
                          final isSelected = selectedIngQuantities.containsKey(
                            ingredient.id,
                          );

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  activeColor: AppRestaurantColors.primary,
                                  onChanged: (bool? checked) {
                                    setState(() {
                                      if (checked == true) {
                                        selectedIngQuantities[ingredient.id] =
                                            1.0;
                                      } else {
                                        selectedIngQuantities.remove(
                                          ingredient.id,
                                        );
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    ingredient.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: SizedBox(
                                        height: 38,
                                        child: TextFormField(
                                          initialValue:
                                              selectedIngQuantities[ingredient
                                                      .id]
                                                  ?.toString() ??
                                              '1',
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          style: TextStyle(fontSize: 13),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 4,
                                                ),
                                            border: const OutlineInputBorder(),
                                            suffixText: ingredient.unit,
                                            suffixStyle: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          onChanged: (val) {
                                            final double qty =
                                                double.tryParse(val) ?? 0.0;
                                            selectedIngQuantities[ingredient
                                                    .id] =
                                                qty;
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),

            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              height: 40,
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
                      const SnackBar(
                        content: Text(
                          'Name and Price must be filled and valid!',
                        ),
                      ),
                    );
                    return;
                  }
                  if (selectedIngQuantities.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one ingredient!'),
                      ),
                    );
                    return;
                  }

                  await vm.saveMenu(
                    id: isEdit ? existingMenu!.id : null,
                    name: formName,
                    desc: formDesc,
                    price: formPrice.toString(),
                    categoryId: formCatId,
                    ingredientQuantities: selectedIngQuantities,
                    imageFile: selectedImageFile,
                    existingImageUrl: isEdit ? existingMenu!.imageUrl : null,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Save Menu',
                  style: TextStyle(
                    color: AppRestaurantColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
