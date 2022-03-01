import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({required this.videoController, Key? key})
      : super(key: key);

  final ChewieController videoController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Chewie(
          controller: videoController,
        ),
      ),
    );
  }
}
