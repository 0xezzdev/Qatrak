import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qatrak/core/colors/app_colors.dart';
import 'package:qatrak/core/widget/custom_button.dart';
import 'package:qatrak/core/widget/custom_text_field.dart';
import 'package:qatrak/core/widget/custom_snackbar.dart';
import 'package:qatrak/feature/login/login.dart';
import 'package:qatrak/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  bool isHidden = true;
  bool isLoading = false;

  Future<void> update() async {
    if (passwordController.text.length < 6) return;

    setState(() => isLoading = true);
    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: passwordController.text.trim()),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: 'Success',
            message: 'Password updated!',
            color: Colors.green,
            icon: Icons.lock_reset,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: 'Error',
            message: 'Failed to update password',
            color: AppColors.error,
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
      body: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Set New Password',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30.h),
            CustomTextField(
              title: 'New Password',
              hint: 'Enter your new password',
              controller: passwordController,
              isPassword: isHidden,
              suffixIcon: isHidden ? Icons.visibility_off : Icons.visibility,
              onPressedSuffix: () => setState(() => isHidden = !isHidden),
            ),
            SizedBox(height: 30.h),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(text: 'Update Password', onPressed: update),
          ],
        ),
      ),
    );
  }
}
