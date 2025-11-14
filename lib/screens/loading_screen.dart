import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  final Widget nextScreen;

  const LoadingScreen({super.key, required this.nextScreen});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/loading_icon/gen4_turbo.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();

        // Add timeout fallback (10 seconds)
        Timer(const Duration(seconds: 10), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => widget.nextScreen),
            );
          }
        });

        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration - const Duration(milliseconds: 100)) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => widget.nextScreen),
              );
            }
          }
        });
      }).catchError((error) {
        // Handle initialization error
        print('Video initialization error: $error');
        // Fallback navigation after 2 seconds
        Timer(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => widget.nextScreen),
            );
          }
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
      backgroundColor: Colors.white,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}