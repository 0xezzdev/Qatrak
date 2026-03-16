import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qatrak/core/colors/app_colors.dart';
import 'package:qatrak/core/images/app_images.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Login with Google pressed");
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10.sp),
          boxShadow: [
            BoxShadow(
              color: AppColors.textHint.withValues(alpha: .2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.google, height: 25.h),
            SizedBox(width: 10.w),
            Text(
              "Login with Google",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
