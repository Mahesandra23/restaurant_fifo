import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/pages/auth/signup/repository/signup_repository.dart';
import 'package:restaurant_fifo/pages/auth/signup/view_model/signup_view_model.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
import 'package:restaurant_fifo/ui/themes/button/gradient_button.dart';
import 'package:restaurant_fifo/ui/themes/reuseable_widget/labeled_text_field.dart';
import 'package:restaurant_fifo/ui/themes/typography/text_style_app.dart';
import 'package:provider/provider.dart';

class SignupView extends StatelessWidget {
  final VoidCallback onToggle; 

  const SignupView({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Jangan lupa masukkan Repository-nya ke ViewModel
      create: (_) => SignupViewModel(SignupRepository()), 
      child: Consumer<SignupViewModel>(
        builder: (context, vm, child) {
          // Bungkus dengan SingleChildScrollView
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              width: 1.sw,
              // Ganti height statis dengan constraints minHeight
              constraints: BoxConstraints(
                minHeight: 1.sh - 170.h,
              ),
              margin: EdgeInsets.only(top: 170.h),
              // Tambahkan viewInsets.bottom untuk menghindari keyboard
              padding: EdgeInsets.only(
                left: 25.w, 
                right: 25.w, 
                top: 25.h, 
                bottom: 25.h + MediaQuery.of(context).viewInsets.bottom
              ),
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
                    "Create your account",
                    style: AppTextStyle.bodySm.semibold.copyWith(
                      color: AppRestaurantColors.primary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  LabeledTextField(
                    label: 'Username',
                    hint: 'Username',
                    onChanged: (value) => vm.setTextFieldValue(
                      InputSingupFieldType.username,
                      value,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  LabeledTextField(
                    label: 'Email',
                    hint: 'Email address',
                    onChanged: (value) =>
                        vm.setTextFieldValue(InputSingupFieldType.email, value),
                  ),
                  SizedBox(height: 20.h),
                  LabeledTextField(
                    label: 'Phone Number',
                    hint: 'Phone Number',
                    onChanged: (value) =>
                        vm.setTextFieldValue(InputSingupFieldType.phone, value),
                  ),
                  SizedBox(height: 20.h),
                  LabeledTextField(
                    label: 'Password',
                    hint: 'Password',
                    isPassword: true,
                    onChanged: (value) => vm.setTextFieldValue(
                      InputSingupFieldType.password,
                      value,
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
                      onPressed: vm.isLoading
                          ? null
                          : () => vm.signUp(
                                context,
                                onSuccess: onToggle,
                              ),
                      child: vm.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Register',
                              style: AppTextStyle.bodySm.semibold.copyWith(
                                color: AppRestaurantColors.accent,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: AppTextStyle.bodyXs.regular.copyWith(
                          color: AppRestaurantColors.secondary,
                        ),
                        children: [
                          TextSpan(
                            text: "Login here",
                            style: AppTextStyle.bodyXs.bold.copyWith(
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