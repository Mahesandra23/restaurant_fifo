import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum FontSizeToken { xs, s, m, l, xl, xl2, xl3, xl4, xl5, xl6 }

extension FontSizeTokenExtension on FontSizeToken {
  double get spValue {
    switch (this) {
      case FontSizeToken.xs:
        return 10.sp;
      case FontSizeToken.s:
        return 12.sp;
      case FontSizeToken.m:
        return 14.sp;
      case FontSizeToken.l:
        return 16.sp;
      case FontSizeToken.xl:
        return 18.sp;
      case FontSizeToken.xl2:
        return 20.sp;
      case FontSizeToken.xl3:
        return 24.sp;
      case FontSizeToken.xl4:
        return 30.sp;
      case FontSizeToken.xl5:
        return 40.sp;
      case FontSizeToken.xl6:
        return 46.sp;
    }
  }
}

enum FontWeightToken { regular, medium, semibold, bold }

extension FontWeightTokenExtension on FontWeightToken {
  FontWeight get weight {
    switch (this) {
      case FontWeightToken.regular:
        return FontWeight.w400;
      case FontWeightToken.medium:
        return FontWeight.w500;
      case FontWeightToken.semibold:
        return FontWeight.w600;
      case FontWeightToken.bold:
        return FontWeight.w700;
    }
  }
}

enum LetterSpacingToken { normal }

extension LetterSpacingTokenExtension on LetterSpacingToken {
  double get spacing {
    switch (this) {
      case LetterSpacingToken.normal:
        return 0;
    }
  }
}
