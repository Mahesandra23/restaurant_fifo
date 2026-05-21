import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_fifo/ui/themes/app_colors.dart';
// import 'package:restaurant_fifo/ui/themes/typography/text_style_app.dart';

/// ini adalah tampilan untuk text field dengan label dan hint. Di gunakan pada halaman setup profile, add new room, dan setting.
class LabeledTextField extends StatefulWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  final bool isPassword;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.initialValue,
    this.isPassword = false,
  });

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late final TextEditingController controller;
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue ?? "");
    _isObscure = widget.isPassword;
  }

  @override
  void didUpdateWidget(covariant LabeledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// kalau initialValue berubah dari luar, update controller
    if (oldWidget.initialValue != widget.initialValue) {
      controller.text = widget.initialValue ?? "";
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: widget.onChanged,
          obscureText: _isObscure,
          style: TextStyle(
            fontSize: 12.sp, // Ukuran font dari bodyXs
            fontWeight: FontWeight.w500,
            color: AppRestaurantColors.secondary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppRestaurantColors.secondary,
            ),
            filled: true,
            fillColor: AppRestaurantColors.accent2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide.none,
            ),
            // 2. SOLUSI TOMBOL MATA (HIDE/UNHIDE)
            // suffixIcon hanya akan muncul jika isPassword bernilai true
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: AppRestaurantColors.primary, // Warna ikon mata
                      size: 20.sp,
                    ),
                    onPressed: () {
                      // Mengubah state untuk membalikkan nilai _isObscure
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
