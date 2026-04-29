import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

/// background utama dengan gradient warna
class MainGradientBackground extends StatelessWidget {
  final Widget child;

  const MainGradientBackground({
    super.key,
    required this.child,
  });

  static const BoxDecoration _backgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: AppColorsCustom.bgGradientColor,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 1.sh,
      decoration: _backgroundDecoration,
      child: child,
    );
  }
}
