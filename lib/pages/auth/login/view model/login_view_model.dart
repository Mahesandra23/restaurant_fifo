import 'package:flutter/material.dart';
import 'package:restaurant_fifo/layout/customer_layout.dart';
import 'package:restaurant_fifo/layout/kitchen_layout.dart';
import 'package:restaurant_fifo/pages/auth/login/repository/login_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum InputLoginFieldType { email, password }

class LoginViewModel extends ChangeNotifier {
  // State untuk menyimpan nilai input
  String _email = '';
  String _password = '';

  // State untuk loading (misal saat hit API)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final LoginRepository _repository = LoginRepository();

  // Method untuk update nilai field (seperti yang kamu panggil di View)
  void setTextFieldValue(InputLoginFieldType type, String value) {
    switch (type) {
      case InputLoginFieldType.email:
        _email = value;
        break;
      case InputLoginFieldType.password:
        _password = value;
        break;
    }
    // Tidak perlu notifyListeners jika hanya menyimpan string
    // kecuali kamu butuh validasi real-time untuk tombol login
  }

  // Fungsi untuk proses login
  // LoginViewModel.dart

  Future<void> login(BuildContext context) async {
    if (_email.isEmpty || _password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password tidak boleh kosong!')),
      );
      return;
    }

    _setLoading(true);

    try {
      final AuthResponse res = await Supabase.instance.client.auth
          .signInWithPassword(email: _email, password: _password);

      if (!context.mounted) return;

      if (res.user != null) {
        // 1. Ambil data metadata dari user yang berhasil login
        final userMetadata = res.user!.userMetadata;

        // 2. Baca statusnya (Gunakan 0 sebagai default jika datanya kosong)
        final int status = userMetadata?['status'] ?? 0;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selamat datang kembali!'),
            backgroundColor: Colors.green,
          ),
        );

        // 3. Logika percabangan halaman berdasarkan status
        if (status == 0) {
          // Jika 0, pergi ke halaman Customer
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CustomerLayout()),
          );
        } else if (status == 1) {
          // Jika 1, pergi ke halaman Admin/Owner
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const KitchenLayout()),
          );
        }
      }
    } on AuthException catch (e) {
      // Menangkap error login (User not found / Invalid credentials)
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau Password salah!'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
