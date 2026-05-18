import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            width: 1.sw,
            height: 1.sh,
            margin: EdgeInsets.only(top: 250.h), // Diperkecil agar tidak terlalu bawah
            decoration: BoxDecoration(
              color: AppRestaurantColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 20.h, // Diperkecil sedikit
                bottom: 20.h + MediaQuery.of(context).viewInsets.bottom,
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
                    "Login to your account",
                    style: TextStyle(
                      fontSize: 14.sp, // Diperkecil dari 16
                      fontWeight: FontWeight.w600,
                      color: AppRestaurantColors.primary,
                    ),
                  ),
                  SizedBox(height: 20.h), // Diperkecil dari 24
                  LabeledTextField(
                    label: 'Email',
                    hint: 'Email address',
                    onChanged: (value) =>
                        vm.setTextFieldValue(InputLoginFieldType.email, value),
                  ),
                  SizedBox(height: 12.h), // Diperkecil dari 16
                  LabeledTextField(
                    label: 'Password',
                    hint: 'Password',
                    isPassword: true,
                    onChanged: (value) =>
                        vm.setTextFieldValue(InputLoginFieldType.password, value),
                  ),
                  SizedBox(height: 20.h), // Diperkecil dari 24
                  
                  // Tombol Login diperkecil ukurannya menjadi 45.h
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
                        onPressed: () => vm.login(context),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 14.sp, // Teks dalam tombol diperkecil
                            fontWeight: FontWeight.bold,
                            color: AppRestaurantColors.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h), // Diperkecil dari 16
                  
                  // Tombol Guest diperkecil ukurannya menjadi 45.h
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
                        onPressed: () => vm.loginGuest(context),
                        child: Text(
                          'Continue as Guest',
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
                        text: "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 12.sp, // Diperkecil dari 14
                          color: AppRestaurantColors.secondary,
                        ),
                        children: [
                          TextSpan(
                            text: "Register here",
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