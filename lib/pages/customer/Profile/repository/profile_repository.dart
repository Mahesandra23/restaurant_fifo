import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final _supabase = Supabase.instance.client;

  // 1. Mengambil riwayat pesanan beserta detail itemnya
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

  // 2. Mengupdate nama dan nomor telepon di tabel profiles
  Future<void> updateProfile(String customerId, String newName, String newPhone) async {
    await _supabase.from('profiles').update({
      'display_name': newName,
      'phone': newPhone,
    }).eq('id', customerId);
  }

  // 3. Menghapus Akun (Catatan: Butuh RPC di Supabase)
  Future<void> deleteAccount(String customerId) async {
    // PENTING: Supabase tidak mengizinkan hapus auth.users langsung dari aplikasi demi keamanan.
    // Solusinya: Kita panggil fungsi RPC (Database Function) yang memiliki hak akses bypass.
    // Jika belum buat RPC, ini bisa menggunakan _supabase.auth.signOut() sementara waktu.
    try {
      await _supabase.rpc('delete_user_account'); 
      await _supabase.auth.signOut();
    } catch (e) {
      // Fallback jika belum membuat RPC: Hapus dari tabel profiles saja dan sign out
      await _supabase.from('profiles').delete().eq('id', customerId);
      await _supabase.auth.signOut();
    }
  }
}