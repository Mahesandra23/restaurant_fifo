import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const bg = _BackgroundColors();
  static const brand = _BrandColors();
  static const text = _TextColors();
  static const border = _BorderColors();
  static const icon = _IconColors();
  static const gradient = _GradientColors();
  static const button = _ButtonColors();
  static const skeleton = _SkeletonColors();

  static const blue50 = Color(0xFFE9E8FD);
  static const blue100 = Color(0xFFBCBBFA);
  static const blue300 = Color(0xFF4C4AF1);
  static const blue500 = Color(0xFF1F1DEE);
  static const blue600 = Color(0xFF1311DF);
  static const blue800 = Color(0xFF0F0DAE);
  static const blue900 = Color(0xFF0D0B95);
  static const blue950 = Color(0xFF0A097C);
  static const lime800 = Color(0xFF5EA000);
  static const lime600 = Color(0xFF79CE00);
  static const lime300 = Color(0xFF9FEA33);
  static const lime100 = Color(0xFFDBF7B3);
  static const lime50 = Color(0xFFF3FCE6);
  static const orange50 = Color(0xFFFCF0E6);
  static const orange200 = Color(0xFFE99351);
  static const orange400 = Color(0xFFE2741F);
  static const red50 = Color(0xFFFAEBEA);
  static const red400 = Color(0xFFD14C3E);

  static const neutral100 = Color(0xFFd9dce3);
  static const neutral950 = Color(0xFF2f333f);
}

class _BrandColors {
  const _BrandColors();
  Color get boldDefault => const Color(0xFF87E500);
  Color get subtleDefault => const Color(0xFFF3FCE6);
  Color get subtleDefaultPressed => const Color(0xFFDBF7B3);
  Color get subtleSecondary => const Color(0xFFE9E8FD);
}

class _BackgroundColors {
  const _BackgroundColors();

  Color get black => const Color(0xFF1A1A1A);
  Color get white => const Color(0xFFFFFFFF);
  Color get disabled => const Color(0xFFD9D9D9);
  Color get grey => const Color(0xFF222222);
  Color get blueLow => const Color(0xFFE1ECF2);
  Color get red => const Color(0xFFF45A5A);
  Color get blue => const Color(0xFF24329B);
  Color get green => const Color(0xFF87E500);
  Color get male => const Color(0xFF3D87FF);
  Color get female => const Color(0xFFFA8FD3);
  Color get greyLow => const Color(0xFF3A3939);
  Color get greySubtle => const Color(0xFFF4F5F6);
}

class _IconColors {
  const _IconColors();

  Color get blackHigh => const Color(0xFF0C0C0C);
  Color get blackMedium => const Color(0xFF626262);
  Color get white => const Color(0xFFFFFFFF);
  Color get neutral => const Color(0xFF767676);
  Color get disabled => const Color(0xFFD9D9D9);
  Color get defaultColor => const Color(0xFF2F333F);
  Color get brandSecondary => const Color(0xFF1F1DEE);
  Color get subtle => const Color(0xFF78829B);
}

class _TextColors {
  const _TextColors();

  Color get black => const Color(0xFF1A1A1A);
  Color get blackLow => const Color(0xFF8E8E8E);
  Color get white => const Color(0xFFFFFFFF);
  Color get red => const Color(0xFFF45A5A);
  Color get blue => const Color(0xFF24329B);
  Color get disabled => const Color(0xFFA1A8B9);
  Color get comingSoon => const Color(0xFFB6B3B3);
  Color get inverse => const Color(0xFFF4F5F6);
  Color get defaultColor => const Color(0xFF2F333F);
  Color get subtle => const Color(0xFF78829B);
  Color get link => const Color(0xFF1F1DEE);
  Color get success => const Color(0XFF5EA000);
}

class _BorderColors {
  const _BorderColors();

  Color get blackHigh => const Color(0xFF0C0C0C);
  Color get divider => const Color(0xFFE8E8E8);
  Color get blue => const Color(0xFF24329B);
  Color get red => const Color(0xFFF45A5A);
  Color get white => const Color(0xFFFFFFFF);
  Color get grey => const Color(0xFFD9D9D9);
  Color get greyLow => const Color(0xFF3A3939);
  Color get defaultColor => const Color(0xFFE8EAED);
  Color get brand => const Color(0xFFABED4D);
}

class _GradientColors {
  const _GradientColors();

  LinearGradient get splash => const LinearGradient(
        end: Alignment(-1, 0),
        begin: Alignment(0, 1),
        colors: [
          Color(0xFF1A1A1A),
          Color(0xFF24238F),
        ],
        stops: [0.05, 1.0],
      );

  LinearGradient get gameTitle => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF110FC7),
          Color(0xFF0A097C),
        ],
        stops: [0.0, 1.0],
      );
  LinearGradient get isPopular => const LinearGradient(
        begin: AlignmentDirectional(-0.15, -1.0), // Approx for 82.24°
        end: AlignmentDirectional(1.0, 1.0),
        colors: [
          Color(0xFF1F1DEE), // #1F1DEE
          Color(0xFF121088), // #121088
        ],
      );
  LinearGradient get communityAppBarGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2F333F),
          Color.fromRGBO(47, 51, 63, 0),
        ],
      );
  LinearGradient get koth => const LinearGradient(
        begin: Alignment(1.0, 0.0),
        end: Alignment(-1.0, 0.0),
        colors: [
          Color(0xFF87E500),
          Color(0xFF5EA000),
        ],
        stops: [0.0, 1.0],
      );
}

class _ButtonColors {
  const _ButtonColors();

  Color get green => const Color(0xFF87E500);
  Color get white => const Color(0xFFFFFFFF);
  Color get blue => const Color(0xFF24329B);
  Color get red => const Color(0xFFF45A5A);
  Color get black => const Color(0xFF1A1A1A);
}

class _SkeletonColors {
  const _SkeletonColors();

  Color get light => const Color(0xFFE8E8E8);
}

class AppRestaurantColors {
  const AppRestaurantColors();

  static const Color primary = Color(0xFF524747);
  static const Color secondary = Color(0xFF383030);
  static const Color accent = Color(0xFFFFEF42);
  static const Color accent2 = Color(0xFFE6F082);
  static const Color background = Color(0xFFFFFFFF);
}

/// tambahan warna sesuai dari UI yang di berikan
class AppColorsCustom {
  const AppColorsCustom._();

  /// Warna ungu button select pada setup
  static const Color buttonPurple = Color(0xFF693995);
  static const Color borderButtonPurple = Color(0xFFA252EF);

  /// Warna abu gelap
  static const Color darkGray = Color(0xFF1F2937);

  /// warna untuk available list time add room
  static const Color darkGray2 = Color.fromARGB(255, 51, 60, 71);

  /// Warna ungu untuk ikon
  static const Color iconPurple = Color(0xFF9333EA);

  /// Warna decline (merah) & button close room chat
  static const Color decline = Colors.red;

  /// Warna accept (hijau) & vote reveal = true
  static const Color accept = Colors.green;

  /// Warna circle avatar (background profil)
  static const Color avatarBg = Colors.purple;

  /// Warna icon kudos/rating bintang
  static const Color iconKudos = Colors.amber;

  /// Warna in-chat notification
  static const Color inChatNotif = Color(0xFF374151);

  /// Warna position chip
  static const Color textFirstPosition = Colors.lightGreenAccent;
  static const Color textSecondPosition = Colors.yellow;
  static const Color textThirdPosition = Colors.orange;
  static const Color textDefaultPosition = Colors.white;

  static Color firstPosition = Colors.lightGreenAccent.withValues(alpha: 0.2);
  static Color secondPosition = Colors.yellow.withValues(alpha: 0.2);
  static Color thirdPosition = Colors.orange.withValues(alpha: 0.2);
  static Color defaultPosition = Colors.white.withValues(alpha: 0.2);

  /// Warna game gradient
  static const List<Color> dota_2 = [Color(0xFFEF4543), Color(0xFFF97316)];
  static const List<Color> mlbb = [Color(0xFF3B83F6), Color(0xFF06B5D4)];
  static const List<Color> pubg = [Color(0xFFBDAD04), Color(0xFFE8DD61)];
  static const List<Color> mhw = [Color(0xFF21C45E), Color(0xFF10B981)];
  static const List<Color> defaultGame = [Color(0xFF0A7993), Color(0xFF5AD6F1)];

  /// Warna gradient untuk main background
  static const List<Color> bgGradientColor = [
    Color(0xFF171930),
    Color(0xFF311A52),
    Color(0xFF4D1C78),
    Color(0xFF4F2086),
    Color(0xFF303088),
    Color(0xFF23388B),
  ];

  /// warna gradient color untuk button dan background dialog/pop up (discover page)
  static const List<Color> gradientColor = [
    Color(0xFF8E37E8),
    Color(0xFF5A4CEA),
    Color(0xFF2D61EB)
  ];

  /// warna gradient collor untuk button yang ada di add room
  static const List<Color> gradientColor2 = [
    Color(0xFF17A150),
    Color(0xFF1E829E),
    Color(0xFF1E829E),
  ];

  /// warna putih opacity 0.1 untuk bakcground container
  static Color transparantWhite = Colors.white.withValues(alpha: 0.1);

  static Color transparantWhite2 = Colors.white.withValues(alpha: 0.05);

  /// warna hitam opacity 0.2 untuk warna container
  static Color transparantBlack = Colors.black.withValues(alpha: 0.2);
}
