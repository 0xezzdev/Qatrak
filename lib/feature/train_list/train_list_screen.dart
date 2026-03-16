import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qatrak/core/colors/app_colors.dart';
import 'package:qatrak/core/model/train_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isSharingMode ? 'Select Your Train' : 'Track a Train',
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
                hintText: "Search by train number...",
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
                    label: Text(type),
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

          // 3. Trains List with Empty State
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
                  return _buildEmptyState("No trains in database yet.");
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
                  return _buildEmptyState("No results match your search.");
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
          "Train No: ${train.trainNumber}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Type: ${train.trainType}",
              style: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
            ),
            Text(
              "Route: ${train.route}",
              style: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
            ),
            Text(
              "Direction: ${train.direction}",
              style: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.primary),
        onTap: () {
          // اللوجيك القادم: GPS Sharing أو Map Tracking
          if (widget.isSharingMode) {
            print("Going to start GPS for: ${train.trainNumber}");
          } else {
            print("Going to track: ${train.trainNumber}");
          }
        },
      ),
    );
  }
}
