import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qatrak/core/colors/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveTrainTrackingPage extends StatefulWidget {
  final int trainId;
  final String trainName;
  const LiveTrainTrackingPage({
    Key? key,
    this.trainId = 17,
    required this.trainName,
  }) : super(key: key);

  @override
  _LiveTrainTrackingPageState createState() => _LiveTrainTrackingPageState();
}

class _LiveTrainTrackingPageState extends State<LiveTrainTrackingPage>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  late final Stream<List<Map<String, dynamic>>> _trainStream;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _trainStream = Supabase.instance.client
        .from('processed_location')
        .stream(primaryKey: ['train_id'])
        .eq('train_id', widget.trainId);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withAlpha(200),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(200),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 5),
            ],
          ),
          child: Text(
            "Train ${widget.trainName}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _trainStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildNoDataState();
          }

          final data = snapshot.data!.first;
          final point = LatLng(data['final_lat'], data['final_long']);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(point, _mapController.camera.zoom);
          });

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: point, initialZoom: 15.0),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b'],
                    userAgentPackageName: 'com.ezzdev.qatrak',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 120,
                        height: 120,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 80 * _pulseController.value,
                                  height: 80 * _pulseController.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green.withAlpha(
                                      (150 * (1 - _pulseController.value))
                                          .toInt(),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent.withAlpha(0),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.train,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildBottomCard(data),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoDataState() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.white,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_searching_rounded,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "No one has shared their location for this train yet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: const Text(
                "Once someone shares their location, it will appear here",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.foreground,
              ),
              child: const Text(
                "Return",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCard(Map<String, dynamic> data) {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent.withAlpha(25),
              child: const Icon(Icons.gps_fixed, color: Colors.blueAccent),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Train No: ${widget.trainName}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Last Update: ${data['last_update'].toString().substring(11, 16)}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.share_location, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}
