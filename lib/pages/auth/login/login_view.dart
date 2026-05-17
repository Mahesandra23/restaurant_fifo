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
            margin: EdgeInsets.only(top: 220.h),
            // Padding dihapus dari sini dan dipindahkan ke SingleChildScrollView
            decoration: BoxDecoration(
              color: AppRestaurantColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.r),
                topRight: Radius.circular(30.r),
              ),
            ),
            // Bungkus konten dengan SingleChildScrollView
            child: SingleChildScrollView(
              // Padding dinamis yang menyesuaikan dengan munculnya keyboard
              padding: EdgeInsets.only(
                left: 25.w,
                right: 25.w,
                top: 25.h,
                bottom: 25.h + MediaQuery.of(context).viewInsets.bottom, 
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
                          color: AppRestaurantColors.secondary,
                        ),
                        children: [
                          TextSpan(
                            text: "Register here",
                            style: AppTextStyle.bodyXs.bold.copyWith(
                              color: AppRestaurantColors.accent,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = onToggle,
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