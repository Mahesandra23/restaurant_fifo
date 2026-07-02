import 'package:supabase_flutter/supabase_flutter.dart';

class LoginRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<bool> login(String email, String password) async {
    try {
      // print('DEBUG LOGIN -> Email: [$email] | Password: [$password]');
      
      final response = await _supabase
          .from('users') 
          .select()
          .eq('email', email)
          .eq('password', password)
          .maybeSingle();

      if (response != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // print('Supabase Login Error: $e');
      throw Exception('Terjadi kesalahan pada server');
    }
  }
}