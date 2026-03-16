import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qatrak/core/colors/app_colors.dart';
import 'package:qatrak/core/images/app_images.dart';
import 'package:qatrak/core/widget/custom_button.dart';
import 'package:qatrak/core/widget/custom_snackbar.dart';
import 'package:qatrak/core/widget/custom_text_field.dart';
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
    setState(() => isLoading = true);
    try {
      await _authService.signUpNewUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } catch (e) {
      if (mounted) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: 'Error',
            message: e.toString().contains("already")
                ? 'Email already in use'
                : 'Failed to sign up. Please try again.',
            color: AppColors.error,
            icon: Icons.error_outline,
          ),
        );
      }
    }
    if (mounted) setState(() => isLoading = false);
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
                SvgPicture.asset(AppImages.logo, height: 85.h),
                Text(
                  'Qatrak',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Track trains, Together',
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
                            "Create Account",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField(
                          title: 'Name',
                          hint: 'Enter your name',
                          controller: nameController,
                        ),
                        SizedBox(height: 10.h),
                        CustomTextField(
                          title: 'Email',
                          hint: 'Enter your email',
                          controller: emailController,
                        ),
                        SizedBox(height: 10.h),
                        CustomTextField(
                          title: 'Password',
                          hint: 'Enter your password',
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
                          text: "Sign Up",
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
                              'OR',
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
                          title: 'Sign Up with Google',
                          imagePath: AppImages.google,
                          onPressed: () {
                            print("Sign Up with Google pressed");
                          },
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(color: AppColors.textHint),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Login",
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
