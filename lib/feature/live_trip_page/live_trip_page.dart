import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveTripPage extends StatefulWidget {
  final Map<String, dynamic> trainData;
  const LiveTripPage({super.key, required this.trainData});

  @override
  State<LiveTripPage> createState() => _LiveTripPageState();
}

class _LiveTripPageState extends State<LiveTripPage> {
  final MapController _mapController = MapController();
  Timer? _trackingTimer;
  StreamSubscription<Position>? _backgroundServiceKeeper;

  LatLng _currentLocation = const LatLng(27.18, 31.18);
  bool _isTracking = true;
  bool _isLoadingLocation = true;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  Future<void> _initTracking() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    _startBackgroundKeeper();
    _startTimerUpdates();
  }

  void _startBackgroundKeeper() {
    final androidSettings = AndroidSettings(
      accuracy: LocationAccuracy.low,
      distanceFilter: 1000,
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText: "Tracking your train location in the background",
        notificationTitle: "Qatrak - Live Train Tracking",
        enableWakeLock: true,
        setOngoing: true,
        notificationIcon: AndroidResource(
          name: 'ic_launcher',
          defType: 'mipmap',
        ),
      ),
    );
    _backgroundServiceKeeper =
        Geolocator.getPositionStream(locationSettings: androidSettings).listen((
          _,
        ) {
          debugPrint("Background service active, keeping alive...");
        });
  }

  void _startTimerUpdates() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted || !_isTracking) {
        timer.cancel();
        return;
      }

      try {
        Position position =
            await Geolocator.getCurrentPosition(
              locationSettings: AndroidSettings(
                accuracy: LocationAccuracy.high,
                forceLocationManager: true,
              ),
            ).timeout(
              const Duration(seconds: 10),
              onTimeout: () async {
                final lastPos = await Geolocator.getLastKnownPosition();
                return lastPos ??
                    Position(
                      longitude: _currentLocation.longitude,
                      latitude: _currentLocation.latitude,
                      timestamp: DateTime.now(),
                      accuracy: 0,
                      altitude: 0,
                      heading: 0,
                      speed: 0,
                      speedAccuracy: 0,
                      altitudeAccuracy: 0,
                      headingAccuracy: 0,
                    );
              },
            );

        if (mounted) {
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
            _isLoadingLocation = false;
          });
          _mapController.move(_currentLocation, 15.0);
          _sendLocationToSupabase(position);
        }
      } catch (e) {
        debugPrint("Timeout in Background: $e");
      }
    });
  }

  Future<void> _sendLocationToSupabase(Position position) async {
    try {
      final trainId = int.tryParse(widget.trainData['id'].toString());
      if (trainId == null) return;
      await _supabase.from('user_contributions').insert({
        'train_id': trainId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'user_id': _supabase.auth.currentUser?.id,
        'sent_at': DateTime.now().toIso8601String(),
      });
      debugPrint("Location sent to Supabase: ${position.latitude}");
    } catch (e) {
      debugPrint("Database error: $e");
    }
  }

  void _stopTracking() {
    _isTracking = false;
    _trackingTimer?.cancel();
    _backgroundServiceKeeper?.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withAlpha(200), Colors.transparent],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tracking Train: ${widget.trainData['train_number'] ?? '---'}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (_isTracking)
              const Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                  SizedBox(width: 5),
                  Text(
                    "Live Tracking Active",
                    style: TextStyle(color: Colors.greenAccent, fontSize: 11),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              onPressed: _stopTracking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "End Trip",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ezzdev.qatrak',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isTracking) _PulseCircle(),
                        const Icon(Icons.train, color: Colors.green, size: 35),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (_isLoadingLocation)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent),
              ),
            ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.share_location, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You are contributing now",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        Text(
                          "Your location helps passengers in real-time",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.gps_fixed, color: Colors.blueAccent),
                    onPressed: () => _mapController.move(_currentLocation, 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _backgroundServiceKeeper?.cancel();
    super.dispose();
  }
}

class _PulseCircle extends StatefulWidget {
  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.6, end: 0.0).animate(_controller),
      child: ScaleTransition(
        scale: Tween(
          begin: 1.0,
          end: 2.2,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.greenAccent.withAlpha(100),
            border: Border.all(color: Colors.greenAccent, width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
