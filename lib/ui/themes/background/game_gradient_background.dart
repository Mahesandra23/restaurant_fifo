import 'package:flutter/material.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

/// mengembalikan warna gradient berdasarkan nama game di gunakan pada discover, kudos, dan rooms.
class GameGradientBackground {
  static LinearGradient getGradientForGame(String gameName) {
    switch (gameName) {
      case 'Dota 2':
        return const LinearGradient(
          colors: AppColorsCustom.dota_2,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'Mobile Legend':
        return const LinearGradient(
          colors: AppColorsCustom.mlbb,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'PUBG':
        return const LinearGradient(
          colors: AppColorsCustom.pubg,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'Monster Hunter':
        return const LinearGradient(
          colors: AppColorsCustom.mhw,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      default:
        return const LinearGradient(
          colors: AppColorsCustom.defaultGame,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
    }
  }
}
