import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LoadingAnimationPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const LoadingAnimationPlayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }
}