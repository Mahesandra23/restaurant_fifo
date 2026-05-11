import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/pages/auth/login/view%20model/login_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/button/gradient_button.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/labeled_text_field.dart';
import 'package:restaurant_fifo/ui/themes/typography/text_style_app.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  final VoidCallback
  onToggle; // Tambahkan parameter ini untuk tombol "Register here"

  const LoginView({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, vm, child) {
          // LANGSUNG RETURN CONTAINER PANEL PUTIHNYA
          return Container(
            width: 1.sw,
            // Karena tidak bisa di-scroll, pastikan margin top pas dengan tinggi layar
            height: 1.sh,
            margin: EdgeInsets.only(top: 220.h),
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
            decoration: BoxDecoration(
              color: AppRestaurantColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.r),
                topRight: Radius.circular(30.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "RestaurantApp",
                  style: AppTextStyle.heading3.copyWith(
                    color: AppRestaurantColors.primary,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "Login to your account",
                  style: AppTextStyle.bodySm.semibold.copyWith(
                    color: AppRestaurantColors.primary,
                  ),
                ),
                SizedBox(height: 20.h),
                LabeledTextField(
                  label: 'Email',
                  hint: 'Email address',
                  onChanged: (value) =>
                      vm.setTextFieldValue(InputLoginFieldType.email, value),
                ),
                SizedBox(height: 20.h),
                LabeledTextField(
                  label: 'Password',
                  hint: 'Password',
                  isPassword: true,
                  onChanged: (value) =>
                      vm.setTextFieldValue(InputLoginFieldType.password, value),
                ),
                SizedBox(height: 20.h),
                GradientButton(
                  width: 1.sw,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12).w,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () => vm.login(context),
                    child: Text(
                      'Login',
                      style: AppTextStyle.bodySm.semibold.copyWith(
                        color: AppRestaurantColors.accent,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                GradientButton(
                  width: 1.sw,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12).w,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () => vm.loginGuest(context),
                    child: Text(
                      'Continue as Guest',
                      style: AppTextStyle.bodySm.semibold.copyWith(
                        color: AppRestaurantColors.accent,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: AppTextStyle.bodyXs.regular.copyWith(
                        color:
                            AppRestaurantColors.secondary, // Warna teks biasa
                      ),
                      children: [
                        TextSpan(
                          text: "Register here",
                          style: AppTextStyle.bodyXs.bold.copyWith(
                            // Dibuat semibold agar lebih menonjol
                            color: AppRestaurantColors.accent,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = onToggle
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
