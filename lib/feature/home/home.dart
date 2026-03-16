import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qatrak/core/colors/app_colors.dart';
import 'package:qatrak/feature/login/login.dart';
import 'package:qatrak/feature/train_list/train_list_screen.dart';
import 'package:qatrak/services/supabase_service.dart';
// تأكد من استيراد ملف الألوان بتاعك
// import 'package:qatrak/core/colors/app_colors.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final String userName =
        SupabaseService.client.auth.currentUser?.userMetadata?['name'] ??
        'Traveler';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $userName 👋',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'What would you like to do today?',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(100.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () async {
                          await SupabaseService.client.auth.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                            (route) => false,
                          );
                        },
                        icon: Icon(
                          Icons.logout,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildFeatureCard(
                        title: "I am a Passenger",
                        subtitle:
                            "Share your live location to help others track this train in real-time",
                        actionText: "Start Sharing",
                        isPrimary: true,
                        icon: Icons.sensors,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TrainListScreen(isSharingMode: true),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                      _buildFeatureCard(
                        title: "I'm Looking for a Train",
                        subtitle:
                            "Find and track any train on the network with real-time community updates",
                        actionText: "Search Trains",
                        isPrimary: false,
                        icon: Icons.search,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TrainListScreen(isSharingMode: false),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              _buildStatsSection(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String actionText,
    required bool isPrimary,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPrimary
                ? [AppColors.primary, AppColors.primaryGlow]
                : [AppColors.background, AppColors.background],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : const Color(0xFF0D47A1),
              ),
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isPrimary ? Colors.white : const Color(0xFF1A1C3D),
                  ),
                ),
                if (isPrimary) ...[SizedBox(width: 8.w), _buildLiveBadge()],
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.grey[600],
              ),
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                Text(
                  actionText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : const Color(0xFF0D47A1),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isPrimary ? Colors.white : const Color(0xFF0D47A1),
                  size: 18.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Text(
        '● LIVE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return StreamBuilder(
      stream: SupabaseService.client
          .from('processed_location')
          .stream(primaryKey: ['train_id']),
      builder: (context, locationSnapshot) {
        return StreamBuilder(
          stream: SupabaseService.client
              .from('profiles')
              .stream(primaryKey: ['id']),
          builder: (context, userSnapshot) {
            int activeUsers = userSnapshot.hasData
                ? userSnapshot.data!.length
                : 0;
            int trainsLive = locationSnapshot.hasData
                ? locationSnapshot.data!.length
                : 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(activeUsers.toString(), "Active Users"),
                _buildVerticalDivider(),
                _buildStatItem(trainsLive.toString(), "Trains Live"),
                _buildVerticalDivider(),
                _buildStatItem("98%", "Accuracy"),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1C3D),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30.h, width: 1.w, color: Colors.grey[300]);
  }
}
