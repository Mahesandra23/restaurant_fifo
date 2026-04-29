import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/ui/themes/typography/text_style_app.dart';

/// circle button di gunakan pada discover, kudos, dan recruit room
class CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? text;
  final Color iconColor;

  const CircleActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.text,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasText = text != null && text!.isNotEmpty;

    if (hasText) {
      final borderRadius = BorderRadius.circular(100.r);

      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14).w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 26.w,
              ),
              SizedBox(height: 8.h),
              Text(
                text!,
                style: AppTextStyle.bodyXs.semibold,
              ),
            ],
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(16).w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24.w,
          ),
        ),
      );
    }
  }
}
