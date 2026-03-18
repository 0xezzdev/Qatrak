import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:qatrak/core/colors/app_colors.dart';
import 'package:qatrak/core/widget/custom_button.dart';
import 'package:qatrak/core/widget/custom_snackbar.dart';
import 'package:qatrak/feature/update_password/update_password_page.dart';
import 'package:qatrak/services/auth/auth_services.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;
  const VerifyOtpPage({super.key, required this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final AuthServices _authService = AuthServices();
  final pinController = TextEditingController();
  bool isLoading = false;

  final defaultPinTheme = PinTheme(
    width: 50.w,
    height: 55.h,
    textStyle: TextStyle(
      fontSize: 22.sp,
      color: AppColors.foreground,
      fontWeight: FontWeight.bold,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.textHint.withValues(alpha: 0.5)),
      borderRadius: BorderRadius.circular(10.r),
      color: AppColors.background,
    ),
  );

  Future<void> verify(String code) async {
    setState(() => isLoading = true);
    try {
      await _authService.verifyOTP(email: widget.email, token: code);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => UpdatePasswordPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: 'Error',
            message: 'Invalid OTP. Please try again.',
            color: Colors.red,
            icon: Icons.error,
          ),
        );
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              'Confirm Code',
              style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Text(
              'Enter the 6-digit code we sent to\n${widget.email}',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textHint),
            ),
            SizedBox(height: 40.h),

            Pinput(
              length: 6,
              controller: pinController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
              ),
              onCompleted: (pin) => verify(pin),
            ),

            SizedBox(height: 40.h),
            if (isLoading)
              const CircularProgressIndicator(color: AppColors.primary)
            else
              CustomButton(
                text: 'Confirm',
                onPressed: () {
                  if (pinController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar(
                        title: 'Error',
                        message: 'Please enter the 6-digit code',
                        color: Colors.orange,
                        icon: Icons.warning_amber_rounded,
                      ),
                    );
                  } else {
                    verify(pinController.text);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
