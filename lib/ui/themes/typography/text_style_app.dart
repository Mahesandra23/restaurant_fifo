import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/typography/text_style_app_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  AppTextStyle._();

  static TextStyle? _heading1;
  static TextStyle? _heading2;
  static TextStyle? _heading3;
  static TextStyle? _heading4;
  static TextStyle? _heading4Semibold;
  static TextStyle? _heading5;

  static TextStyle? _heading2Xl;
  static TextStyle? _headingXl;
  static TextStyle? _headingLg;
  static TextStyle? _headingMd;
  static TextStyle? _headingSm;
  static TextStyle? _headingXs;

  static _DisplayXL get displayXL => _DisplayStyle.displayXL;
  static _DisplayL get displayL => _DisplayStyle.displayL;
  static _DisplayM get displayM => _DisplayStyle.displayM;
  static _DisplayS get displayS => _DisplayStyle.displayS;

  static _BodyMD get bodyMd => _BodyStyle.bodyMD;
  static _BodySM get bodySm => _BodyStyle.bodySM;
  static _BodyXS get bodyXs => _BodyStyle.bodyXS;
  static _BodyXXS get bodyXxs => _BodyStyle.bodyXXS;

  /// Reusable method to create text style
  static TextStyle _createTextStyle({
    required double fontSize,
    required FontWeightToken fontWeight,
    required LetterSpacingToken letterSpacing,
    double? height = 1.1,
  }) {
    return GoogleFonts.montserrat(
      textStyle: TextStyle(
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: fontWeight.weight,
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing.spacing,
        color: AppColors.text.white,
      ),
    );
  }

  static TextStyle get heading1 {
    _heading1 ??= _createTextStyle(
      fontSize: FontSizeToken.xl5.spValue,
      fontWeight: FontWeightToken.bold,
      letterSpacing: LetterSpacingToken.normal,
    );
    return _heading1 ?? const TextStyle();
  }

  static TextStyle get heading2 {
    _heading2 ??= _createTextStyle(
      fontSize: FontSizeToken.xl4.spValue,
      fontWeight: FontWeightToken.bold,
      letterSpacing: LetterSpacingToken.normal,
    );
    return _heading2 ?? const TextStyle();
  }

  static TextStyle get heading3 {
    _heading3 ??= _createTextStyle(
      fontSize: FontSizeToken.xl3.spValue,
      fontWeight: FontWeightToken.bold,
      letterSpacing: LetterSpacingToken.normal,
    );
    return _heading3 ?? const TextStyle();
  }

  static TextStyle get heading4 {
    _heading4 ??= _createTextStyle(
      fontSize: FontSizeToken.xl2.spValue,
      fontWeight: FontWeightToken.bold,
      letterSpacing: LetterSpacingToken.normal,
    );
    return _heading4 ?? const TextStyle();
  }

  static TextStyle get heading4Semibold {
    _heading4Semibold ??= _createTextStyle(
      fontSize: FontSizeToken.xl2.spValue,
      fontWeight: FontWeightToken.semibold,
      letterSpacing: LetterSpacingToken.normal,
    );
    return _heading4Semibold ?? const TextStyle();
  }

  static TextStyle get heading5 {
    _heading5 ??= _createTextStyle(
      fontSize: FontSizeToken.xl.spValue,
      fontWeight: FontWeightToken.bold,
      letterSpacing: LetterSpacingToken.normal,
    );
    return _heading5 ?? const TextStyle();
  }

  static TextStyle get heading2Xl {
    _heading2Xl ??= _createTextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeightToken.semibold,
      letterSpacing: LetterSpacingToken.normal,
      height: 1,
    );
    return _heading2Xl ?? const TextStyle();
  }

  static TextStyle get headingXl {
    _headingXl ??= _createTextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeightToken.semibold,
      letterSpacing: LetterSpacingToken.normal,
      height: 1,
    );
    return _headingXl ?? const TextStyle();
  }

  static TextStyle get headingLg {
    _headingLg ??= _createTextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeightToken.semibold,
      letterSpacing: LetterSpacingToken.normal,
      height: 1,
    );
    return _headingLg ?? const TextStyle();
  }

  static TextStyle get headingMd {
    _headingMd ??= _createTextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeightToken.semibold,
      letterSpacing: LetterSpacingToken.normal,
      height: 1,
    );
    return _headingMd ?? const TextStyle();
  }

  static TextStyle get headingSm {
    _headingSm ??= _createTextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeightToken.semibold,
      letterSpacing: LetterSpacingToken.normal,
      height: 1,
    );
    return _headingSm ?? const TextStyle();
  }

  static TextStyle get headingXs {
    _headingXs ??= _createTextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeightToken.semibold,
      letterSpacing: LetterSpacingToken.normal,
      height: 1,
    );
    return _headingXs ?? const TextStyle();
  }
}

class _DisplayStyle {
  static final _DisplayXL instanceXL = _DisplayXL._();
  static final _DisplayL instanceL = _DisplayL._();
  static final _DisplayM instanceM = _DisplayM._();
  static final _DisplayS instanceS = _DisplayS._();

  static _DisplayXL get displayXL => instanceXL;
  static _DisplayL get displayL => instanceL;
  static _DisplayM get displayM => instanceM;
  static _DisplayS get displayS => instanceS;
}

abstract class DisplayBase {
  final double fontSize;
  final double height;
  final LetterSpacingToken letterSpacing;

  DisplayBase({
    required this.fontSize,
    required this.height,
    required this.letterSpacing,
  });

  TextStyle? _regular;
  TextStyle? _medium;
  TextStyle? _semibold;
  TextStyle? _bold;

  TextStyle _base({required FontWeightToken fontWeight}) {
    return GoogleFonts.montserrat(
      textStyle: TextStyle(
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: fontWeight.weight,
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing.spacing,
        color: AppColors.text.white,
      ),
    );
  }

  TextStyle get regular {
    _regular ??= _base(fontWeight: FontWeightToken.regular);
    return _regular ?? const TextStyle();
  }

  TextStyle get medium {
    _medium ??= _base(fontWeight: FontWeightToken.medium);
    return _medium ?? const TextStyle();
  }

  TextStyle get semibold {
    _semibold ??= _base(fontWeight: FontWeightToken.semibold);
    return _semibold ?? const TextStyle();
  }

  TextStyle get bold {
    _bold ??= _base(fontWeight: FontWeightToken.bold);
    return _bold ?? const TextStyle();
  }
}

class _DisplayXL extends DisplayBase {
  _DisplayXL._()
      : super(
          fontSize: FontSizeToken.l.spValue,
          height: 1.1,
          letterSpacing: LetterSpacingToken.normal,
        );
}

class _DisplayL extends DisplayBase {
  _DisplayL._()
      : super(
          fontSize: FontSizeToken.m.spValue,
          height: 1.1,
          letterSpacing: LetterSpacingToken.normal,
        );
}

class _DisplayM extends DisplayBase {
  _DisplayM._()
      : super(
          fontSize: FontSizeToken.s.spValue,
          height: 1.1,
          letterSpacing: LetterSpacingToken.normal,
        );
}

class _DisplayS extends DisplayBase {
  _DisplayS._()
      : super(
          fontSize: FontSizeToken.xs.spValue,
          height: 1.1,
          letterSpacing: LetterSpacingToken.normal,
        );
}

class _BodyStyle {
  static final _BodyMD instanceMD = _BodyMD._();
  static final _BodySM instanceSM = _BodySM._();
  static final _BodyXS instanceXS = _BodyXS._();
  static final _BodyXXS instanceXXS = _BodyXXS._();

  static _BodyMD get bodyMD => instanceMD;
  static _BodySM get bodySM => instanceSM;
  static _BodyXS get bodyXS => instanceXS;
  static _BodyXXS get bodyXXS => instanceXXS;
}

abstract class BodyBase {
  final double fontSize;
  final double height;
  final LetterSpacingToken letterSpacing;

  BodyBase({
    required this.fontSize,
    required this.height,
    required this.letterSpacing,
  });

  TextStyle? _regular;
  TextStyle? _semibold;
  TextStyle? _bold;

  TextStyle _base({required FontWeightToken fontWeight}) {
    return GoogleFonts.montserrat(
      textStyle: TextStyle(
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: fontWeight.weight,
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing.spacing,
        color: AppColors.text.white,
      ),
    );
  }

  TextStyle get regular {
    _regular ??= _base(fontWeight: FontWeightToken.medium);
    return _regular ?? const TextStyle();
  }

  TextStyle get semibold {
    _semibold ??= _base(fontWeight: FontWeightToken.semibold);
    return _semibold ?? const TextStyle();
  }

  TextStyle get bold {
    _bold ??= _base(fontWeight: FontWeightToken.bold);
    return _bold ?? const TextStyle();
  }
}

class _BodyMD extends BodyBase {
  _BodyMD._()
      : super(
          fontSize: 16.sp,
          height: 20 / 16,
          letterSpacing: LetterSpacingToken.normal,
        );
}

class _BodySM extends BodyBase {
  _BodySM._()
      : super(
          fontSize: 14.sp,
          height: 20 / 14,
          letterSpacing: LetterSpacingToken.normal,
        );
}

class _BodyXS extends BodyBase {
  _BodyXS._()
      : super(
          fontSize: 12.sp,
          height: 16 / 12,
          letterSpacing: LetterSpacingToken.normal,
        );
}

class _BodyXXS extends BodyBase {
  _BodyXXS._()
      : super(
          fontSize: 10.sp,
          height: 16 / 10,
          letterSpacing: LetterSpacingToken.normal,
        );
}

extension AppTextStyleColor on TextStyle {
  TextStyle get white70 => copyWith(color: Colors.white70);
  TextStyle get white54 => copyWith(color: Colors.white54);
}
