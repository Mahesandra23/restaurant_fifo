import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';
import 'package:restaurant_fifo/core/providers/cart_provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_detail/view_model/menu_detail_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class MenuDetailView extends StatelessWidget {
  final MenuModel menu; // Data dilempar dari halaman sebelumnya

  const MenuDetailView({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return MvvmBuilder<MenuDetailViewModel>(
      viewModel: MenuDetailViewModel(menu),
      initOnce: true,
      key: ValueKey('MenuDetail-${menu.id}'),
      view: (context) {
        final vm = context.watch<MenuDetailViewModel>();

        return Scaffold(
          backgroundColor: AppRestaurantColors.background,

          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                backgroundColor: AppRestaurantColors.primary,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: menu.imageUrl.isNotEmpty
                      ? Image.network(menu.imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.fastfood,
                            size: 80,
                            color: AppRestaurantColors.secondary,
                          ),
                        ),
                ),
              ),

              // Detail Konten
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul & Harga
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              menu.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppRestaurantColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            menu.formattedPrice,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppRestaurantColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi (Dummy, bisa Anda tambahkan di model nanti jika perlu)
                      const Text(
                        'Deskripsi Menu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppRestaurantColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hidangan spesial ini disiapkan dengan bahan-bahan pilihan berkualitas tinggi. Segera pesan untuk menikmati kelezatannya!',
                        style: TextStyle(
                          color: AppRestaurantColors.secondary,
                          height: 1.5,
                        ),
                      ),
                      const Divider(height: 40),

                      // Input Catatan (Notes)
                      const Text(
                        'Catatan Khusus (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppRestaurantColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText:
                              'Misal: Jangan pakai bawang, pedas sedang...',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
                            borderSide: const BorderSide(
                              color: AppRestaurantColors.primary,
                            ),
                          ),
                        ),
                        onChanged: vm.updateNotes,
                      ),
                      const SizedBox(
                        height: 100,
                      ), // Ruang kosong agar tidak tertutup tombol bawah
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- TOMBOL BAWAH (QTY & ADD TO CART) ---
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Pengatur Jumlah (Quantity)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove,
                            color: AppRestaurantColors.primary,
                          ),
                          onPressed: vm.decrement,
                        ),
                        Text(
                          '${vm.quantity}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppRestaurantColors.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: AppRestaurantColors.primary,
                          ),
                          onPressed: vm.increment,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Tombol Masukkan Keranjang
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppRestaurantColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        onPressed: () {
                          // 1. Ambil tas belanja (Provider) dari memori HP
                          final cartProvider = context.read<CartProvider>();

                          // 2. Lempar tas belanja itu ke ViewModel agar diisi barang
                          vm.addToCart(cartProvider);

                          // 3. Tampilkan Pop-up sukses
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${menu.name} ditambahkan ke keranjang!',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );

                          // 4. Tutup halaman detail dan kembali ke menu
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Tambah • Rp ${vm.totalPrice}',
                          style: const TextStyle(
                            color: AppRestaurantColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
