import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qatrak/core/colors/app_colors.dart';
import 'package:qatrak/core/images/app_images.dart';
import 'package:qatrak/core/model/onboarding_model.dart';
import 'package:qatrak/feature/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  final List<OnboardingModel> _onboardingItems = [
    OnboardingModel(
      image: AppImages.onboarding1,
      title: 'onboarding_1_title'.tr(),
      description: 'onboarding_1_desc'.tr(),
    ),
    OnboardingModel(
      image: AppImages.onboarding2,
      title: 'onboarding_2_title'.tr(),
      description: 'onboarding_2_desc'.tr(),
    ),
    OnboardingModel(
      image: AppImages.onboarding3,
      title: 'onboarding_3_title'.tr(),
      description: 'onboarding_3_desc'.tr(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingItems.length,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = index == _onboardingItems.length - 1;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      _onboardingItems[index].image,
                      height: 250.h,
                    ),
                    SizedBox(height: 50.h),
                    Text(
                      _onboardingItems[index].title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.foreground,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      _onboardingItems[index].description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16.sp,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          if (!_isLastPage)
            Positioned(
              top: 50.h,
              left: 20.w,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  'onboarding_skip'.tr(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
                ),
              ),
            ),

          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _onboardingItems.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.primary,
                    dotColor: Colors.grey[300]!,
                    dotHeight: 10.r,
                    dotWidth: 10.r,
                    expansionFactor: 4,
                    spacing: 8,
                  ),
                ),
                SizedBox(height: 40.h),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  width: 250.w,
                  height: 60.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isLastPage) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 2,
                      padding: EdgeInsets.symmetric(
                        horizontal: _isLastPage ? 20.w : 0,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isLastPage
                          ? Text(
                              'onboarding_start'.tr(),
                              key: const ValueKey('start'),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward_ios,
                              key: ValueKey('arrow'),
                              size: 20.r,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
