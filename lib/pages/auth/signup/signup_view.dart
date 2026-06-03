import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_fifo/pages/auth/signup/repository/signup_repository.dart';
import 'package:restaurant_fifo/pages/auth/signup/view_model/signup_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/button/gradient_button.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/labeled_text_field.dart';
import 'package:provider/provider.dart';

class SignupView extends StatelessWidget {
  final VoidCallback onToggle;

  const SignupView({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupViewModel(SignupRepository()),
      child: Consumer<SignupViewModel>(
        builder: (context, vm, child) {
          // PERBAIKAN: Container ditaruh di paling luar seperti LoginView
          return Container(
            width: double.infinity,
            height: double.infinity,
            margin: const EdgeInsets.only(top: 190), // Menyesuaikan posisi atas
            decoration: const BoxDecoration(
              color: AppRestaurantColors.background, // Ini yang bikin warna putih
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "RestaurantApp",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Create your account",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppRestaurantColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LabeledTextField(
                    label: 'Username',
                    hint: 'Username',
                    onChanged: (value) => vm.setTextFieldValue(
                      InputSingupFieldType.username,
                      value,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LabeledTextField(
                    label: 'Email',
                    hint: 'Email address',
                    onChanged: (value) =>
                        vm.setTextFieldValue(InputSingupFieldType.email, value),
                  ),
                  const SizedBox(height: 12),
                  LabeledTextField(
                    label: 'Phone Number',
                    hint: 'Phone Number',
                    onChanged: (value) =>
                        vm.setTextFieldValue(InputSingupFieldType.phone, value),
                  ),
                  const SizedBox(height: 12),
                  LabeledTextField(
                    label: 'Password',
                    hint: 'Password',
                    isPassword: true,
                    onChanged: (value) => vm.setTextFieldValue(
                      InputSingupFieldType.password,
                      value,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Signup
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
                        onPressed: vm.isLoading
                            ? null
                            : () => vm.signUp(context, onSuccess: onToggle),
                        child: vm.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppRestaurantColors.accent,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppRestaurantColors.secondary,
                        ),
                        children: [
                          TextSpan(
                            text: "Login here",
                            style: TextStyle(
                              fontSize: 12,
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