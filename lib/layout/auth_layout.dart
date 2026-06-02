import 'package:flutter/material.dart';
import 'package:restaurant_fifo/pages/auth/login/login_view.dart';
import 'package:restaurant_fifo/pages/auth/signup/signup_view.dart';
import 'package:restaurant_fifo/pages/auth/widget/auto_background_carousel.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';

class AuthLayout extends StatefulWidget {
  const AuthLayout({super.key});

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> {
  bool _isLogin = true;

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tentukan tinggi carousel secara kondisional
    // Misal: Login butuh gambar besar (250), Signup gambar kecil (150) agar form muat
    double currentHeight = _isLogin ? 250 : 200;

    return Scaffold(
      backgroundColor: AppRestaurantColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            // 2. Gunakan AnimatedContainer agar transisi tingginya mulus
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: currentHeight,
              child: AutoBackgroundCarousel(height: currentHeight),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: _isLogin
                  ? LoginView(
                      key: const ValueKey('login'),
                      onToggle: _toggleForm,
                    )
                  : SignupView(
                      key: const ValueKey('signup'),
                      onToggle: _toggleForm,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
