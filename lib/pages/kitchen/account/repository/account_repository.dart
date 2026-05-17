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

  // --- UPDATE ---
  Future<void> updateStaffName(String profileId, String newName) async {
    try {
      // PERBAIKAN: Gunakan display_name
      await _supabase
          .from('profiles')
          .update({'display_name': newName})
          .eq('id', profileId);
    } catch (e) {
      debugPrint('Error updateStaffName: $e');
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
