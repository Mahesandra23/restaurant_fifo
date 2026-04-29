import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum InputSingupFieldType { username, email, phone, password }

class SignupViewModel extends ChangeNotifier {
  String _username = '';
  String _email = '';
  String _phone = '';
  String _password = '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setTextFieldValue(InputSingupFieldType type, String value) {
    switch (type) {
      case InputSingupFieldType.username:
        _username = value.trim();
        break;
      case InputSingupFieldType.email:
        _email = value.trim();
        break;
      case InputSingupFieldType.phone:
        _phone = value.trim();
        break;
      case InputSingupFieldType.password:
        _password = value.trim();
        break;
    }
    // Debugging: Melihat perubahan teks secara real-time
    print('[DEBUG SIGNUP] Input Berubah -> $type: $value');
  }

  Future<void> signUp(
    BuildContext context, {
    required VoidCallback onSuccess,
  }) async {
    print('[DEBUG SIGNUP] === MEMULAI PROSES SIGN UP ===');
    print(
      '[DEBUG SIGNUP] Data Siap Kirim: Email=[$_email], Username=[$_username], Phone=[$_phone]',
    );

    // 1. Pengecekan Validasi
    if (_email.isEmpty || _password.isEmpty || _username.isEmpty) {
      print(
        '[DEBUG SIGNUP] Gagal: Validasi tidak lolos (ada field wajib kosong)',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email, Password, dan Username wajib diisi!'),
        ),
      );
      return;
    }

    _setLoading(true);

    try {
      print('[DEBUG SIGNUP] Mengirim request ke server Supabase...');

      // Supabase secara otomatis mengecek keunikan email di tabel auth.users
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _email,
        password: _password,
        data: {'display_name': _username, 'phone': _phone, 'status': 0},
      );

      print('[DEBUG SIGNUP] Request berhasil dijawab oleh server!');

      if (!context.mounted) return;

      if (res.user != null) {
        // Debugging: Melihat data user yang berhasil dibuat
        print('[DEBUG SIGNUP] Sukses! User ID baru: ${res.user?.id}');
        print('[DEBUG SIGNUP] Metadata User: ${res.user?.userMetadata}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        onSuccess();
      } else {
        print(
          '[DEBUG SIGNUP] Aneh: res.user bernilai null padahal tidak ada error.',
        );
      }
    } on AuthException catch (e) {
      // Debugging: Melihat detail error dari Supabase Auth
      print('[DEBUG SIGNUP] ERROR SUPABASE: ${e.statusCode} - ${e.message}');

      // Menangkap error jika email sudah terdaftar
      String message = e.message;
      if (e.message.contains('already registered')) {
        message = "Email sudah terdaftar. Gunakan email lain.";
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      // PENTING: Debugging tambahan untuk menangkap error di luar Supabase (misal: No Internet)
      print('[DEBUG SIGNUP] ERROR SISTEM/JARINGAN: $e');

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan sistem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      print('[DEBUG SIGNUP] === PROSES SIGN UP SELESAI ===');
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
