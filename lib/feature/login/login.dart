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
import 'package:qatrak/feature/forgot_password/forgot_password_page.dart';
import 'package:qatrak/feature/home/home.dart';
import 'package:qatrak/feature/signup/signup.dart';
import 'package:qatrak/services/auth/auth_services.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordHidden = true;
  final AuthServices _authService = AuthServices();
  bool isLoading = false;
  Future<void> login() async {
    setState(() {
      isLoading = true;
      showLoadingDialog();
    });

    try {
      await _authService.signInUser(
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
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: AppStrings.authErrorTitle.tr(),
            message: AppStrings.loginFailedMessage.tr(),
            color: AppColors.error,
            icon: Icons.error_outline,
          ),
        );
        isLoading = false;
      }
    }
    if (mounted) setState(() => isLoading = false);
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
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
              height: MediaQuery.of(context).size.height * 0.65,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.0.sp,
                    horizontal: 20.0.sp,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.loginWeclome.tr(),
                          style: TextStyle(
                            color: AppColors.foreground,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        CustomTextField(
                          title: AppStrings.emailTextFieldTitle.tr(),
                          hint: AppStrings.emailTextFieldHint.tr(),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          isPassword: false,
                        ),
                        SizedBox(height: 15.h),
                        CustomTextField(
                          title: AppStrings.passwordTextFieldTitle.tr(),
                          hint: AppStrings.passwordTextFieldHint.tr(),
                          controller: passwordController,
                          keyboardType: TextInputType.text,
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
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                AppStrings.forgotPasswordButtonTitle.tr(),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        CustomButton(
                          text: AppStrings.loginButtonTitle.tr(),
                          onPressed: login,
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
                          title: AppStrings.loginWithGoogleButtonTitle.tr(),
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
                                    message: AppStrings.googleSignInError.tr(),
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
                              AppStrings.dontHaveAccountText.tr(),
                              style: TextStyle(color: AppColors.textHint),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Signup(),
                                  ),
                                );
                              },
                              child: Text(
                                AppStrings.loginSignUpButtonTitle.tr(),
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
