import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class GradientButton extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final double? width;

  const GradientButton({
    super.key,
    required this.child,
    this.borderRadius,
    this.width,
  });

  // Gunakan tanda [ ] untuk menjadikannya List<Color>
  // Dan tambahkan setidaknya dua warna (bisa warna yang sama jika ingin solid)
  static final LinearGradient _primaryGradient = LinearGradient(
    colors: [
      AppRestaurantColors.primary, // Warna utama
      AppRestaurantColors
          .secondary, // Gunakan warna kedua agar efek gradient terlihat
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final double radiusValue = borderRadius ?? 100.r;

    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: _primaryGradient,
        borderRadius: BorderRadius.circular(radiusValue),
      ),
      child: child,
    );
  }
}
