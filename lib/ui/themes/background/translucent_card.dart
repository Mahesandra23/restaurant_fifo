import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

/// card dengan background transluscent putih
class TranslucentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;

  const TranslucentCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsCustom.transparantWhite,
        borderRadius: borderRadius ?? BorderRadius.circular(16).r,
      ),
      width: 1.sw,
      margin: margin,
      padding: padding,
      child: child,
    );
  }
}
