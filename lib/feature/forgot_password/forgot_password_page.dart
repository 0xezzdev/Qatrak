import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qatrak/core/colors/app_colors.dart';
import 'package:qatrak/core/widget/custom_button.dart';
import 'package:qatrak/core/widget/custom_text_field.dart';
import 'package:qatrak/core/widget/custom_snackbar.dart';
import 'package:qatrak/feature/verify_otp/verify_otp_page.dart';
import 'package:qatrak/services/auth/auth_services.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final AuthServices _authService = AuthServices();
  bool isLoading = false;

  Future<void> sendOTP() async {
    if (emailController.text.isEmpty) return;
    
    setState(() => isLoading = true);
    try {
      await _authService.sendPasswordResetOTP(emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(title: 'Success', message: 'OTP sent to your email', color: Colors.green, icon: Icons.check),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpPage(email: emailController.text.trim()),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(title: 'Error', message: 'Failed to send OTP', color: AppColors.error, icon: Icons.error),
        );
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: AppColors.primary)),
      body: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forgot Password?', style: TextStyle(color: AppColors.foreground, fontSize: 28.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            Text('Enter your email to receive a 6-digit verification code.', style: TextStyle(color: AppColors.textHint, fontSize: 14.sp)),
            SizedBox(height: 30.h),
            CustomTextField(title: 'Email', hint: 'Enter your email', controller: emailController, keyboardType: TextInputType.emailAddress),
            SizedBox(height: 30.h),
            isLoading ? const Center(child: CircularProgressIndicator()) : CustomButton(text: 'Send Code', onPressed: sendOTP),
          ],
        ),
      ),
    );
  }
}