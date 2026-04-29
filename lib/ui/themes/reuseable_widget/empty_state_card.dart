import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/ui/themes/background/translucent_card.dart';
import 'package:restaurant_fifo/ui/themes/typography/text_style_app.dart';

/// tampilan ketika card kosong di gunakan pada discover, kudos, dan recruit room
class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int? horizontalMargin;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.horizontalMargin,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140.h,
      child: TranslucentCard(
        margin: EdgeInsets.symmetric(
          horizontal: (horizontalMargin ?? 0).w,
        ),
        padding: const EdgeInsets.all(16).w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 60.w,
            ),
            Text(
              title,
              style: AppTextStyle.bodyMd.semibold,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodySm.regular.white70,
            ),
          ],
        ),
      ),
    );
  }
}
