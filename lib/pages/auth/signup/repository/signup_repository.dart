import 'package:supabase_flutter/supabase_flutter.dart';

class SignupRepository {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> registerUser({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) async {
    // Supabase secara otomatis mengecek keunikan email di tabel auth.users
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': username, 
        'phone': phone, 
        'status': 0, // Default status untuk user baru (guest/customer)
      },
    );
  }
}