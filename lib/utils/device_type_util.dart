import 'dart:ui';

import 'package:flutter/cupertino.dart';

class DeviceTypeUtil {
  static bool _isTablet = false;

  bool get isTablet => _isTablet;

  static Future<void> init() async {
    var window = PlatformDispatcher.instance.views.first;
    _isTablet = MediaQueryData.fromView(window).size.shortestSide > 600;
  }
}
