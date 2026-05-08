import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/repository/menu_repository.dart';
import 'package:restaurant_fifo/pages/kitchen/menu/view_model/menu_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<MenuViewModel>(
      viewModel: MenuViewModel(MenuRepository()),
      initOnce: true,
      key: const Key('MenuView'),
      view: (context) {
        final vm = context.watch<MenuViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,
          
          // APPBAR DIHAPUS, DIGANTI 2 TOMBOL MELAYANG INI:
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Tombol Kelola Kategori (Kecil)
              FloatingActionButton(
                heroTag: 'manageCategoryBtn',
                backgroundColor: AppRestaurantColors.secondary,
                mini: true,
                onPressed: () => _showCategoryManager(context, vm),
                child: const Icon(Icons.category, color: AppRestaurantColors.accent),
              ),
              const SizedBox(height: 12),
              // Tombol Tambah Menu (Besar)
              FloatingActionButton(
                heroTag: 'addMenuBtn',
                backgroundColor: AppRestaurantColors.primary,
                onPressed: () => _showMenuForm(context, vm, null),
                child: const Icon(Icons.add, color: AppRestaurantColors.accent),
              ),
            ],
          ),

          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppRestaurantColors.primary))
              : Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(
                      child: vm.groupedMenus.isEmpty
                          ? const Center(child: Text('Belum ada menu.', style: TextStyle(color: AppRestaurantColors.secondary)))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 80.0), // Padding bawah agar list tidak tertutup tombol
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: vm.groupedMenus.entries.map((entry) {
                                  return _buildMenuSection(context, vm, entry.key, entry.value);
                                }).toList(),
                              ),
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari menu untuk diubah...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppRestaurantColors.secondary,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppRestaurantColors.primary),
          ),
        ),
      ),
    );
  }

  // --- STYLE CUSTOMER (HORIZONTAL SCROLL) ---
  Widget _buildMenuSection(
    BuildContext context,
    MenuViewModel vm,
    String title,
    List<KitchenMenuData> items,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppRestaurantColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190, // Ditinggikan sedikit agar pas
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final menu = items[index];
              return GestureDetector(
                onTap: () =>
                    _showMenuForm(context, vm, menu), // Buka form saat dipencet
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppRestaurantColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppRestaurantColors.secondary.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          // Tampilkan gambar jika ada URL-nya, jika kosong tampilkan warna saja
                          image: menu.imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(menu.imageUrl),
                                  fit: BoxFit
                                      .cover, // Agar gambar memenuhi kotak
                                )
                              : null,
                        ),
                        // Tampilkan ikon garpu pisau HANYA JIKA gambar kosong
                        child: menu.imageUrl.isEmpty
                            ? const Icon(
                                Icons.fastfood,
                                size: 50,
                                color: AppRestaurantColors.secondary,
                              )
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menu.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppRestaurantColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${menu.price}',
                              style: const TextStyle(
                                color: AppRestaurantColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${menu.ingredients.length} Bahan',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ==========================================
  // BOTTOM SHEET KELOLA KATEGORI
  // ==========================================
  void _showCategoryManager(BuildContext context, MenuViewModel vm) {
    String newCategoryName = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kelola Kategori',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Form Tambah Kategori
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nama Kategori Baru',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (val) => newCategoryName = val,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppRestaurantColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (newCategoryName.trim().isNotEmpty) {
                        vm.addCategory(newCategoryName.trim());
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text(
                      'Tambah',
                      style: TextStyle(color: AppRestaurantColors.accent),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Daftar Kategori
              const Text(
                'Daftar Kategori Saat Ini:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppRestaurantColors.secondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: vm.categories.length,
                  itemBuilder: (context, index) {
                    final cat = vm.categories[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(cat.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          vm.deleteCategory(cat.id);
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // BOTTOM SHEET FORM MENU
  // ==========================================
  void _showMenuForm(
    BuildContext context,
    MenuViewModel vm,
    KitchenMenuData? existingMenu,
  ) {
    if (vm.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buat Kategori terlebih dahulu!')),
      );
      return;
    }

    final bool isEdit = existingMenu != null;
    String formName = isEdit ? existingMenu.name : '';
    String formDesc = isEdit ? existingMenu.description : '';
    int formPrice = isEdit ? existingMenu.price : 0;
    String formCatId = isEdit
        ? existingMenu.categoryId
        : vm.categories.first.id;
    List<String> selectedIngIds = isEdit
        ? existingMenu.ingredients.map((e) => e.id).toList()
        : [];
    File? selectedImageFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppRestaurantColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                  0.85, // Buat lebih tinggi
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
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              vm.deleteMenu(existingMenu.id);
                              Navigator.pop(context);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- AREA PEMILIH GAMBAR ---
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          // Buka Galeri HP
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
                        },
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
                                : (isEdit && existingMenu.imageUrl.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(existingMenu.imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              selectedImageFile == null &&
                                  (!isEdit || existingMenu.imageUrl.isEmpty)
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      color: AppRestaurantColors.secondary,
                                      size: 30,
                                    ),
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
                                    initialValue: formPrice > 0
                                        ? formPrice.toString()
                                        : '',
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Harga (Rp)',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val) =>
                                        formPrice = int.tryParse(val) ?? 0,
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
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c.id,
                                            child: Text(c.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => formCatId = val!),
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
                                    final ingredient =
                                        vm.availableIngredients[index];
                                    final isSelected = selectedIngIds.contains(
                                      ingredient.id,
                                    );
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
                                          if (checked == true)
                                            selectedIngIds.add(ingredient.id);
                                          else
                                            selectedIngIds.remove(
                                              ingredient.id,
                                            );
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
                        onPressed: () {
                          if (formName.trim().isEmpty || formPrice <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nama dan Harga wajib diisi!'),
                              ),
                            );
                            return;
                          }
                          vm.saveMenu(
                            id: isEdit ? existingMenu.id : null,
                            name: formName,
                            desc: formDesc,
                            price: formPrice,
                            categoryId: formCatId,
                            ingredientIds: selectedIngIds,
                            imageFile: selectedImageFile, // Masukkan foto baru
                            existingImageUrl: isEdit
                                ? existingMenu.imageUrl
                                : null, // Masukkan foto lama
                          );
                          Navigator.pop(context);
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
          },
        );
      },
    );
  }
}
