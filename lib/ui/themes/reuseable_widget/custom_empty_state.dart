import 'package:flutter/material.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class CustomEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color iconColor;

  const CustomEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.iconColor = Colors.green, // Default warna hijau untuk success state
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: iconColor),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppRestaurantColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}