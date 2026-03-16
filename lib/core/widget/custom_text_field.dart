import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qatrak/core/colors/app_colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.title,
    required this.hint,
    this.isPassword = false,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.onPressedSuffix,
  });

  final String title;
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? suffixIcon;
  final void Function()? onPressedSuffix;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppColors.textHint)),
          SizedBox(height: 10.h),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: IconButton(
                icon: Icon(suffixIcon, color: AppColors.textHint),
                onPressed: onPressedSuffix,
              ),
              hintStyle: TextStyle(color: AppColors.textHint),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.sp),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.secondary,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.sp),
                borderSide: BorderSide(color: AppColors.primaryGlow),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
