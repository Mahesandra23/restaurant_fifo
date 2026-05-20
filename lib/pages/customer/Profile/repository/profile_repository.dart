import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ProfileRepository {
  final _supabase = Supabase.instance.client;

  // --- FUNGSI BARU: Mengambil Data Profil (Nomor HP) ---
  Future<Map<String, dynamic>?> fetchUserProfile(String customerId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('phone')
          .eq('id', customerId)
          .single();
      return response;
    } catch (e) {
      debugPrint('Error fetchUserProfile: $e');
      return null;
    }
  }

  // 1. Mengambil riwayat pesanan
  Future<List<Map<String, dynamic>>> fetchOrderHistory(String customerId) async {
    final response = await _supabase
        .from('orders')
        .select('''
          id, 
          total_price, 
          status, 
          created_at, 
          order_items(quantity, menus(name))
        ''')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
        
    return response;
  }

  // 2. Mengupdate profil ke tabel `profiles` DAN ke Auth `raw_user_meta_data`
  Future<void> updateProfile(String customerId, String newName, String newPhone) async {
    // Siapkan data yang akan diupdate
    final updates = <String, dynamic>{
      'display_name': newName,
    };
    if (newPhone.isNotEmpty) {
      updates['phone'] = newPhone;
    }

    // A. Update ke tabel public.profiles (Wajib ada .select().single() untuk deteksi RLS)
    await _supabase
        .from('profiles')
        .update(updates)
        .eq('id', customerId)
        .select()
        .single();

    // B. Push data yang sama ke auth.users -> raw_user_meta_data
    await _supabase.auth.updateUser(
      UserAttributes(
        data: updates, 
      ),
    );
  }

  // 3. Memverifikasi Password Saat Ini (Re-authentication)
  Future<bool> verifyCurrentPassword(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return true; 
    } catch (e) {
      debugPrint('Verify Password Error: $e');
      return false; 
    }
  }

  // 4. Mengupdate Email dan Password (Di level root Auth dan Metadata)
  Future<void> updateAuthCredentials({String? newEmail, String? newPassword}) async {
    final Map<String, dynamic> metadataUpdates = {};
    
    // Jika email diganti, update juga value email di dalam raw_user_meta_data
    if (newEmail?.isNotEmpty == true) {
      metadataUpdates['email'] = newEmail;
    }

    final attributes = UserAttributes(
      email: newEmail?.isNotEmpty == true ? newEmail : null,
      password: newPassword?.isNotEmpty == true ? newPassword : null,
      data: metadataUpdates.isNotEmpty ? metadataUpdates : null,
    );
    
    await _supabase.auth.updateUser(attributes);
  }

  // 5. Menghapus Akun 
  Future<void> deleteAccount(String customerId) async {
    try {
      await _supabase.rpc('delete_user_account'); 
      await _supabase.auth.signOut();
    } catch (e) {
      await _supabase.from('profiles').delete().eq('id', customerId);
      await _supabase.auth.signOut();
    }
  }
}