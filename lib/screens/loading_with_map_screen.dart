import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/loading_animation_player.dart';

class LoadingWithMapScreen extends StatefulWidget {
  const LoadingWithMapScreen({super.key});

  @override
  State<LoadingWithMapScreen> createState() => _LoadingWithMapScreenState();
}

class _LoadingWithMapScreenState extends State<LoadingWithMapScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initializeMap();
  }

  void _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/loading_icon/gen4_turbo.mp4')
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
      }).catchError((error) {
        // Handle error, e.g., show fallback
        debugPrint('Video initialization error: $error');
      });
  }

  void _initializeMap() {
    // Simulate map initialization
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isMapReady = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedOpacity(
            opacity: _isVideoInitialized ? 1.0 : 0.0,
            duration: const Duration(seconds: 1),
            child: _isVideoInitialized
                ? LoadingAnimationPlayer(controller: _controller)
                : const Center(child: CircularProgressIndicator()),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Responsive spacing
          AnimatedOpacity(
            opacity: _isMapReady ? 1.0 : 0.0,
            duration: const Duration(seconds: 1),
            child: Container(
              height: 250,
              child: _isMapReady
                  ? GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(14.5995, 120.9842), // Example: Manila
                        zoom: 14,
                      ),
                      // TODO: Replace AIzaSyA2ZYkuSy0TU-5NYthX6RTL_XyCJlWn6oI
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}