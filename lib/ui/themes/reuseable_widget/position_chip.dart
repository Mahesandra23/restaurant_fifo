import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/typography/text_style_app.dart';

/// chip untuk game preference di gunakan pada discover dan recruit room
class PositionChip extends StatelessWidget {
  final String text;
  final int index;

  const PositionChip({
    super.key,
    required this.text,
    required this.index,
  });

  Color _getPositionTextColor(int index) {
    switch (index) {
      case 0:
        return AppColorsCustom.textFirstPosition;
      case 1:
        return AppColorsCustom.textSecondPosition;
      case 2:
        return AppColorsCustom.textThirdPosition;
      default:
        return AppColorsCustom.textDefaultPosition;
    }
  }

  Color _getPositionBackgroundColor(int index) {
    switch (index) {
      case 0:
        return AppColorsCustom.firstPosition;
      case 1:
        return AppColorsCustom.secondPosition;
      case 2:
        return AppColorsCustom.thirdPosition;
      default:
        return AppColorsCustom.defaultPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = _getPositionTextColor(index);
    final Color backgroundColor = _getPositionBackgroundColor(index);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4).w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100).r,
        color: backgroundColor,
        border: Border.all(
          color: textColor,
          width: 1.0,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyle.bodyXs.regular.copyWith(color: textColor),
      ),
    );
  }
}
