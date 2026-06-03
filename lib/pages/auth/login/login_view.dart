import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_fifo/pages/auth/login/view%20model/login_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/button/gradient_button.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/labeled_text_field.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  final VoidCallback onToggle;

  const LoginView({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, vm, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            margin: EdgeInsets.only(top: 240), // Diperkecil agar tidak terlalu bawah
            decoration: BoxDecoration(
              color: AppRestaurantColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20, // Diperkecil sedikit
                bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "RestaurantApp",
                    style: TextStyle(
                      fontSize: 24, // Diperkecil dari 28
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.primary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Login to your account",
                    style: TextStyle(
                      fontSize: 14, // Diperkecil dari 16
                      fontWeight: FontWeight.w600,
                      color: AppRestaurantColors.primary,
                    ),
                  ),
                  SizedBox(height: 20), // Diperkecil dari 24
                  LabeledTextField(
                    label: 'Email',
                    hint: 'Email address',
                    onChanged: (value) =>
                        vm.setTextFieldValue(InputLoginFieldType.email, value),
                  ),
                  SizedBox(height: 12), // Diperkecil dari 16
                  LabeledTextField(
                    label: 'Password',
                    hint: 'Password',
                    isPassword: true,
                    onChanged: (value) =>
                        vm.setTextFieldValue(InputLoginFieldType.password, value),
                  ),
                  SizedBox(height: 20), // Diperkecil dari 24
                  
                  // Tombol Login diperkecil ukurannya menjadi 45
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: GradientButton(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => vm.login(context),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 14, // Teks dalam tombol diperkecil
                            fontWeight: FontWeight.bold,
                            color: AppRestaurantColors.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12), // Diperkecil dari 16
                  
                  // Tombol Guest diperkecil ukurannya menjadi 45
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: GradientButton(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => vm.loginGuest(context),
                        child: Text(
                          'Continue as Guest',
                          style: TextStyle(
                            fontSize: 14, // Teks dalam tombol diperkecil
                            fontWeight: FontWeight.bold,
                            color: AppRestaurantColors.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 12, // Diperkecil dari 14
                          color: AppRestaurantColors.secondary,
                        ),
                        children: [
                          TextSpan(
                            text: "Register here",
                            style: TextStyle(
                              fontSize: 12, // Diperkecil dari 14
                              fontWeight: FontWeight.bold,
                              color: AppRestaurantColors.accent,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = onToggle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}