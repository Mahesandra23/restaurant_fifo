import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    await dotenv.load(fileName: ".env");
    String baseUrl = '';
    String apiKey = '';

    baseUrl = dotenv.env['DEV_BASE_URL'] ?? '';
    apiKey = dotenv.env['DEV_API_KEY'] ?? '';
    type = EnvironmentType.dev;

    await Supabase.initialize(
      url: baseUrl,
      anonKey: apiKey,
    );
  }
}
