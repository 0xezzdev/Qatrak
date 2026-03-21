import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui; // عشان الـ TextDirection.ltr
import 'package:qatrak/core/colors/app_colors.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key, required this.backgroundColor, required this.isEnColor, required this.isNotEnColor});
  final Color backgroundColor;
  final Color isEnColor;
  final Color isNotEnColor;

  @override
  Widget build(BuildContext context) {
    bool isEn = context.locale.languageCode == 'en';

    final rootContext = context;

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: GestureDetector(
        onTap: () async {
          if (isEn) {
            await rootContext.setLocale(const Locale('ar'));
          } else {
            await rootContext.setLocale(const Locale('en'));
          }
          if (rootContext.mounted) {
            (rootContext as Element).markNeedsBuild();
          }
        },
        child: Container(
          width: 75.w,
          height: 35.h,
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: backgroundColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: isEn ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  width: 35.w,
                  height: 30.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'EN',
                        style: TextStyle(
                          color: isEn ? isEnColor : isNotEnColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'ع',
                        style: TextStyle(
                          color: isEn ? isNotEnColor : isEnColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
