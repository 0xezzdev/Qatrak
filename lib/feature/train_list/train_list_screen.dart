import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qatrak/core/Utilities/string_extensions.dart';
import 'package:qatrak/core/colors/app_colors.dart';
import 'package:qatrak/core/model/train_model.dart';
import 'package:qatrak/core/strings/app_strings.dart';
import 'package:qatrak/feature/live_train_tracking/live_train_tracking_page.dart';
import 'package:qatrak/feature/live_trip_page/live_trip_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TrainListScreen extends StatefulWidget {
  final bool isSharingMode;
  const TrainListScreen({super.key, required this.isSharingMode});

  @override
  State<TrainListScreen> createState() => _TrainListScreenState();
}

class _TrainListScreenState extends State<TrainListScreen> {
  String searchQuery = "";
  String selectedType = "All";

  final List<String> trainTypes = [
    "All",
    "Talgo",
    "VIP",
    "Upgraded Spanish",
    "Sleeper & Seating",
    "Luxury Russian 2nd Class",
    "Russian AC",
    "Russian",
  ];
  InterstitialAd? _interstitialAd;

  static const String adUnitId = 'ca-app-pub-7193403289313889/5104737263';

  void loadAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  loadAd();
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  ad.dispose();
                  loadAd();
                },
              );
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void showAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
    } else {
      print('Loading ad...');
    }
  }

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isSharingMode
              ? "${AppStrings.trainListSharingTitle.tr()}"
              : "${AppStrings.trainListTrackingTitle.tr()}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: AppStrings.trainListSearchHint.tr(),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // 2. Filter Chips
          SizedBox(
            height: 50.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: trainTypes.length,
              itemBuilder: (context, index) {
                final type = trainTypes[index];
                bool isSelected = selectedType == type;
                return Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: FilterChip(
                    label: Text(type.translateTrainData(context)),
                    selected: isSelected,
                    onSelected: (val) => setState(() => selectedType = type),
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.foreground,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 10.h),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('trains')
                  .stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState(AppStrings.trainListEmptyDb.tr());
                }

                final List<TrainModel> allTrains = snapshot.data!
                    .map((json) => TrainModel.fromJson(json))
                    .toList();

                final filteredTrains = allTrains.where((train) {
                  final matchesSearch = train.trainNumber
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                  final matchesType =
                      selectedType == "All" || train.trainType == selectedType;
                  return matchesSearch && matchesType;
                }).toList();
                if (filteredTrains.isEmpty) {
                  return _buildEmptyState(AppStrings.trainListNoResults.tr());
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: filteredTrains.length,
                  itemBuilder: (context, index) {
                    final train = filteredTrains[index];
                    return _buildTrainCard(train, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.train_outlined, size: 70.sp, color: Colors.grey[300]),
          SizedBox(height: 10.h),
          Text(
            message,
            style: TextStyle(color: AppColors.textHint, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainCard(TrainModel train, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15.w),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.train, color: AppColors.primary),
        ),
        title: Text(
          "${AppStrings.trainListNumberLabel.tr()} ${train.trainNumber}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppStrings.trainListTypeLabel.tr()} ${train.trainType.translateTrainData(context)}",
              style: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
            ),
            Text(
              "${AppStrings.trainListRouteLabel.tr()} ${train.route.translateTrainData(context)}",
              style: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
            ),
            Text(
              "${AppStrings.trainListDirectionLabel.tr()} ${train.direction.translateTrainData(context)}",
              style: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.primary),
        onTap: () {
          if (widget.isSharingMode) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LiveTripPage(trainData: train.toJson()),
              ),
            );
          } else {
            showAd();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LiveTrainTrackingPage(
                  trainId: int.parse(train.id),
                  trainName: train.trainNumber,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
