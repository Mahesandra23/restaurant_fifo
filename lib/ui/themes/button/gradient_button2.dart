import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/typography/text_style_app.dart';

/// button di pakai pada add room dan setting
class GradientButton2 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double verticalPadding;
  final double borderRadius;
  final TextAlign textAlign;

  const GradientButton2({
    super.key,
    required this.text,
    required this.onPressed,
    this.verticalPadding = 12,
    this.borderRadius = 12,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColorsCustom.gradientColor2,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius).r,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
          ).h,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius).r,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyle.bodySm.semibold,
          textAlign: textAlign,
        ),
      ),
    );
  }
}
