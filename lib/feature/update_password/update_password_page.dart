import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qatrak/core/colors/app_colors.dart';
import 'package:qatrak/core/strings/app_strings.dart';
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
            title: AppStrings.updatePasswordSuccessTitle.tr(),
            message: AppStrings.updatePasswordSuccessMessage.tr(),
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
            title: AppStrings.updatePasswordErrorTitle.tr(),
            message: AppStrings.updatePasswordErrorMessage.tr(),
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
              AppStrings.updatePasswordTitle.tr(),
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30.h),
            CustomTextField(
              title: AppStrings.updatePasswordFieldTitle.tr(),
              hint: AppStrings.updatePasswordFieldHint.tr(),
              controller: passwordController,
              isPassword: isHidden,
              suffixIcon: isHidden ? Icons.visibility_off : Icons.visibility,
              onPressedSuffix: () => setState(() => isHidden = !isHidden),
            ),
            SizedBox(height: 30.h),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(text: AppStrings.updatePasswordButton.tr(), onPressed: update),
          ],
        ),
      ),
    );
  }
}
