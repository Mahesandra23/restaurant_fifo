import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Tambahkan ScreenUtil
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class MenuCardWidget extends StatelessWidget {
  final String name;
  final String formattedPrice;
  final String imageUrl;
  final VoidCallback? onTap;

  const MenuCardWidget({
    super.key,
    required this.name,
    required this.formattedPrice,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppRestaurantColors.background,
          // Radius standar: 12.r
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5.r,
              offset: Offset(0, 2.h),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gunakan Expanded agar area gambar mengisi sisa ruang secara fleksibel
            Expanded(
              child: Container(
                width: 1.sw,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: imageUrl.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.fastfood,
                          color: AppRestaurantColors.secondary,
                          size: 24.sp, // Ukuran icon dibuat dinamis
                        ),
                      )
                    : null,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: AppRestaurantColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    formattedPrice,
                    style: TextStyle(
                      color: AppRestaurantColors.primary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}