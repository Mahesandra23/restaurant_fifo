import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_fifo/core/models/menu_model.dart';
import 'package:restaurant_fifo/core/providers/cart_provider.dart';
import 'package:restaurant_fifo/mvvm/mvvm.dart';
import 'package:restaurant_fifo/pages/customer/Menu/menu_detail/view_model/menu_detail_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class MenuDetailView extends StatelessWidget {
  final MenuModel menu; 

  const MenuDetailView({super.key, required this.menu});

  // --- HELPER FORMAT HARGA MANUAL TANPA LIBRARY ---
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

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
                expandedHeight: 200, 
                pinned: true,
                backgroundColor: AppRestaurantColors.primary,
                leading: Container(
                  margin: EdgeInsets.all(8), 
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
                  background: vm.menu.imageUrl.isNotEmpty
                      ? Image.network(vm.menu.imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade300,
                          child: Icon(
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
                  padding: EdgeInsets.all(16),
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
                              vm.menu.name, 
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppRestaurantColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Rp ${_formatPrice(vm.menu.price)}', // Menggunakan format manual
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppRestaurantColors.primary,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 24),

                      // Deskripsi
                      Text(
                        'Menu Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppRestaurantColors.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      Text(
                        vm.menu.description.isNotEmpty 
                            ? vm.menu.description 
                            : 'No description available for this delicious dish.',
                        style: const TextStyle(
                          color: AppRestaurantColors.secondary,
                          height: 1.5,
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      Divider(height: 1, color: Colors.grey.shade300),
                      SizedBox(height: 24),

                      // Input Catatan (Notes)
                      Text(
                        'Special Notes (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppRestaurantColors.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'E.g.: No onions, medium spice...',
                          hintStyle: TextStyle(
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
                      
                      SizedBox(height: 40), 
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- TOMBOL BAWAH (QTY & ADD TO CART) ---
          bottomNavigationBar: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Pengatur Jumlah (Quantity)
                  Container(
                    height: 35, 
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
                          style: TextStyle(
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
                  
                  SizedBox(width: 16),

                  // Tombol Masukkan Keranjang
                  Expanded(
                    child: SizedBox(
                      height: 35, 
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppRestaurantColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final cartProvider = context.read<CartProvider>();
                          vm.addToCart(cartProvider);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${vm.menu.name} added to cart!',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );

                          Navigator.pop(context);
                        },
                        child: Text(
                          'Add to Cart • Rp ${_formatPrice(vm.totalPrice)}', // Menggunakan format manual
                          style: TextStyle(
                            color: AppRestaurantColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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