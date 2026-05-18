import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              width: 1.sw,
              constraints: BoxConstraints(
                minHeight: 1.sh - 140.h, // Disesuaikan agar lebih compact
              ),
              margin: EdgeInsets.only(top: 190.h), // Disesuaikan agar lebih compact
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 20.h, // Diperkecil dari 24
                bottom: 20.h + MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: AppRestaurantColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "RestaurantApp",
                    style: TextStyle(
                      fontSize: 24.sp, // Diperkecil dari 28
                      fontWeight: FontWeight.bold,
                      color: AppRestaurantColors.primary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Create your account",
                    style: TextStyle(
                      fontSize: 14.sp, // Diperkecil dari 16
                      fontWeight: FontWeight.w600,
                      color: AppRestaurantColors.primary,
                    ),
                  ),
                  SizedBox(height: 20.h), // Diperkecil dari 24
                  LabeledTextField(
                    label: 'Username',
                    hint: 'Username',
                    onChanged: (value) => vm.setTextFieldValue(
                      InputSingupFieldType.username,
                      value,
                    ),
                  ),
                  SizedBox(height: 12.h), // Diperkecil dari 16
                  LabeledTextField(
                    label: 'Email',
                    hint: 'Email address',
                    onChanged: (value) =>
                        vm.setTextFieldValue(InputSingupFieldType.email, value),
                  ),
                  SizedBox(height: 12.h), // Diperkecil dari 16
                  LabeledTextField(
                    label: 'Phone Number',
                    hint: 'Phone Number',
                    onChanged: (value) =>
                        vm.setTextFieldValue(InputSingupFieldType.phone, value),
                  ),
                  SizedBox(height: 12.h), // Diperkecil dari 16
                  LabeledTextField(
                    label: 'Password',
                    hint: 'Password',
                    isPassword: true,
                    onChanged: (value) => vm.setTextFieldValue(
                      InputSingupFieldType.password,
                      value,
                    ),
                  ),
                  SizedBox(height: 20.h), // Diperkecil dari 24

                  // Tombol Signup diperkecil ukurannya menjadi 45.h
                  SizedBox(
                    height: 35.h,
                    width: 1.sw,
                    child: GradientButton(
                      width: 1.sw,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
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
                                  fontSize: 14.sp, // Teks dalam tombol diperkecil
                                  fontWeight: FontWeight.bold,
                                  color: AppRestaurantColors.accent,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          fontSize: 12.sp, // Diperkecil dari 14
                          color: AppRestaurantColors.secondary,
                        ),
                        children: [
                          TextSpan(
                            text: "Login here",
                            style: TextStyle(
                              fontSize: 12.sp, // Diperkecil dari 14
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