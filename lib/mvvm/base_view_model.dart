import 'package:flutter/material.dart';

class BaseViewModel with ChangeNotifier {
  late BuildContext context;

  bool _disposed = false;

  bool get disposed => _disposed;

  BaseViewModel();

  void init() {}

  void onError(Object obj) {}

  void onResume() {}

  void onInactive() {}

  void onPause() {}

  void onDetach() {}

  void onBuild() {}

  void onDispose() {}

  @override
  void notifyListeners() {
    if (!disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    onDispose();
    super.dispose();
  }
}
