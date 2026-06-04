import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountRepository {
  final _supabase = Supabase.instance.client;

  // --- READ ---
  Future<List<Map<String, dynamic>>> fetchKitchenStaff() async {
    try {
      // PERBAIKAN: Gunakan display_name sesuai ERD
      return await _supabase
          .from('profiles')
          .select()
          .eq('status', 1)
          .order('display_name', ascending: true);
    } catch (e) {
      debugPrint('Error fetchKitchenStaff: $e');
      return [];
    }
  }

  // --- CREATE ---
  Future<void> createAdminAccount(
    String email,
    String password,
    String displayName,
    String phone,
  ) async {
    try {
      // Sama persis seperti SignupViewModel Anda, namun status diset ke 1 (Admin)
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName, 'phone': phone, 'status': 1},
      );
    } catch (e) {
      debugPrint('Error createAdminAccount: $e');
      rethrow;
    }
  }

  // --- UPDATE PROFIL UMUM (Nama & HP) ---
  Future<bool> updateProfile(
    String profileId,
    String newName,
    String newPhone,
  ) async {
    try {
      await _supabase
          .from('profiles')
          .update({'display_name': newName, 'phone': newPhone})
          .eq('id', profileId);
      return true;
    } catch (e) {
      debugPrint('Error updateProfile: $e');
      return false;
    }
  }

  // --- UPDATE KEAMANAN (Email & Password) ---
  // Supabase membutuhkan UserAttributes untuk update auth data
  Future<String?> updateSecuritySettings({
    required String currentEmail,
    required String currentPassword,
    String? newEmail,
    String? newPassword,
  }) async {
    try {
      // 1. Re-autentikasi untuk memastikan ini benar-benar user yang sah
      await _supabase.auth.signInWithPassword(
        email: currentEmail,
        password: currentPassword,
      );

      // 2. Siapkan atribut yang akan diupdate
      final UserAttributes attributes = UserAttributes(
        email: newEmail,
        password: newPassword,
      );

      // 3. Eksekusi update
      await _supabase.auth.updateUser(attributes);

      return null; // Berhasil (tidak ada error)
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> deleteAdmin(String profileId) async {
    try {
      // 1. Panggil fungsi sakti di backend untuk menghapus dari auth.users
      await _supabase.rpc(
        'delete_user_auth',
        params: {'target_user_id': profileId},
      );

      // 2. Hapus secara manual dari tabel profiles juga (untuk berjaga-jaga jika
      // relasi ERD Anda belum menggunakan ON DELETE CASCADE)
      await _supabase.from('profiles').delete().eq('id', profileId);
    } catch (e) {
      debugPrint('Error deleteAdmin: $e');
      rethrow; // Lempar error ke ViewModel agar bisa ditampilkan di UI jika gagal
    }
  }
}
