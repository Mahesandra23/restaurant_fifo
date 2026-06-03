import 'package:supabase_flutter/supabase_flutter.dart';

enum EnvironmentType { dev, prod }

class App {
  static App? _instance;
  static EnvironmentType type = EnvironmentType.prod;

  App._internal();

  factory App() {
    _instance ??= App._internal();
    return _instance!;
  }

  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://kwwilcwgyevauodoloey.supabase.co',
      anonKey: 'sb_publishable_fqtjBwYbYWhha1rlVUAO1w_mI61t1D0',
    );

    type = EnvironmentType.prod;
  }
}