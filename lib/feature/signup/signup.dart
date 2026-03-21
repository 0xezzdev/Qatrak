import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qatrak/core/colors/app_colors.dart';
import 'package:qatrak/core/images/app_images.dart';
import 'package:qatrak/core/strings/app_strings.dart';
import 'package:qatrak/core/widget/custom_button.dart';
import 'package:qatrak/core/widget/custom_snackbar.dart';
import 'package:qatrak/core/widget/custom_text_field.dart';
import 'package:qatrak/core/widget/language_toggle.dart';
import 'package:qatrak/core/widget/social_button.dart';
import 'package:qatrak/feature/home/home.dart';
import 'package:qatrak/services/auth/auth_services.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordHidden = true;
  final AuthServices _authService = AuthServices();
  bool isLoading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      showLoadingDialog();
    });
    try {
      await _authService.signUpNewUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: AppStrings.authErrorTitle.tr(),
            message: e.toString().contains("already")
                ? AppStrings.emailAlreadyInUse.tr()
                : AppStrings.signUpFailed.tr(),
            color: AppColors.error,
            icon: Icons.error_outline,
          ),
        );
      }
    }
    if (mounted) setState(() => isLoading = false);
  }

  void initState() {
    super.initState();
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        content: SizedBox(
          width: 100.w,
          height: 200.h,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeAlign: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Positioned(
            top: 40.h,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      LanguageToggle(
                        backgroundColor: AppColors.background,
                        isEnColor: AppColors.primary,
                        isNotEnColor: AppColors.background,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                SvgPicture.asset(AppImages.logo, height: 85.h),
                Text(
                  AppStrings.appTitle.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppStrings.topicSentence.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.67,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Center(
                          child: Text(
                            AppStrings.signUpTitle.tr(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField(
                          title: AppStrings.userNameFieldTitle.tr(),
                          hint: AppStrings.userNameFieldHint.tr(),
                          controller: nameController,
                        ),
                        SizedBox(height: 10.h),
                        CustomTextField(
                          title: AppStrings.emailTextFieldTitle.tr(),
                          hint: AppStrings.emailTextFieldHint.tr(),
                          controller: emailController,
                        ),
                        SizedBox(height: 10.h),
                        CustomTextField(
                          title: AppStrings.passwordTextFieldTitle.tr(),
                          hint: AppStrings.passwordTextFieldHint.tr(),
                          controller: passwordController,
                          isPassword: isPasswordHidden,
                          suffixIcon: isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                          onPressedSuffix: () {
                            setState(() {
                              isPasswordHidden = !isPasswordHidden;
                            });
                          },
                        ),
                        SizedBox(height: 20.h),
                        CustomButton(
                          text: AppStrings.signUpButton.tr(),
                          onPressed: register,
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 1.h,
                              width: 100.w,
                              color: AppColors.textHint,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              AppStrings.orText.tr(),
                              style: TextStyle(color: AppColors.textHint),
                            ),
                            SizedBox(width: 10.w),
                            Container(
                              height: 1.h,
                              width: 100.w,
                              color: AppColors.textHint,
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        SocialButton(
                          title: AppStrings.signUpWithGoogle.tr(),
                          imagePath: AppImages.google,
                          onPressed: () async {
                            showLoadingDialog();
                            try {
                              final user = await _authService.signInWithGoogle(
                                context,
                              );
                              if (mounted) {
                                Navigator.pop(context);
                              }

                              if (user != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Home(),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  CustomSnackBar(
                                    title: AppStrings.authErrorTitle.tr(),
                                    message:
                                        e.toString().contains(
                                          "provider_disabled",
                                        )
                                        ? AppStrings.googleDisabledMessage.tr()
                                        : AppStrings.googleSignInError.tr(),
                                    icon: Icons.error,
                                    color: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.alreadyHaveAccount.tr(),
                              style: TextStyle(color: AppColors.textHint),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                AppStrings.loginButtonTitle.tr(),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
