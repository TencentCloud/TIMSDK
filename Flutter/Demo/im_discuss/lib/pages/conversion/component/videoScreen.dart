import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen(
      {required this.videoController, required this.downloadFn, Key? key})
      : super(key: key);

  final ChewieController videoController;
  final void Function() downloadFn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: GestureDetector(
          onTap: () {
            videoController.pause();
            Navigator.of(context).pop();
          },
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0,
                child: Chewie(
                  controller: videoController,
                ),
              ),
              Positioned(
                left: 10,
                bottom: 50,
                child: IconButton(
                  icon: Image.asset('images/close.png'),
                  iconSize: 30,
                  onPressed: () {
                    videoController.pause();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Positioned(
                right: 10,
                bottom: 50,
                child: IconButton(
                  icon: Image.asset('images/download.png'),
                  iconSize: 30,
                  onPressed: downloadFn,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
