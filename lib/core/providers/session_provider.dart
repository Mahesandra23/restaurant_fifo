import 'package:flutter/material.dart';
import 'package:restaurant_fifo/core/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionProvider extends ChangeNotifier {
  UserProfile? _currentUserProfile;
  bool isLoading = true;

  // Getter agar halaman lain bisa baca
  UserProfile? get currentUserProfile => _currentUserProfile;

  final _supabase = Supabase.instance.client;

  // Fungsi ini dipanggil saat aplikasi baru dibuka atau setelah berhasil login
  Future<void> fetchCurrentUser() async {
    isLoading = true;
    notifyListeners();

    final user = _supabase.auth.currentUser;

    if (user != null) {
      try {
        // Ambil data tambahan dari tabel 'profiles'
        final response = await _supabase
            .from('profiles')
            .select('display_name, status')
            .eq('id', user.id)
            .single();

        _currentUserProfile = UserProfile(
          id: user.id,
          email: user.email ?? '',
          displayName: response['display_name'] ?? 'User',
          status: response['status'] ?? 0,
        );
      } catch (e) {
        debugPrint('Error fetching profile: $e');
        _currentUserProfile = null;
      }
    } else {
      _currentUserProfile = null;
    }

    isLoading = false;
    notifyListeners();
  }

  // 2. FUNGSI LOGIN GUEST (Harus di luar fetchCurrentUser)
  Future<void> loginAsGuest() async {
    try {
      final response = await Supabase.instance.client.auth.signInAnonymously();

      if (response.user != null) {
        await fetchCurrentUser();
        // print('Guest login sukses: ${response.user!.id}');
      }
    } catch (e) {
      // print('Error Guest Login: $e');
    }
  }

  // 3. FUNGSI LOGOUT
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUserProfile = null;
    notifyListeners();
  }
}
