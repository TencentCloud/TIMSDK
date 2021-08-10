import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';

import 'package:video_player/video_player.dart';
// import 'package:videos_player/model/video.model.dart';
// import 'package:videos_player/videos_player.dart';

class VideoMessage extends StatefulWidget {
  VideoMessage(this.message);
  final V2TimMessage message;

  @override
  State<StatefulWidget> createState() => VideoMessageState();
}

class VideoMessageState extends State<VideoMessage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    try {
      if (widget.message.videoElem!.videoUrl == null) {
        _controller = VideoPlayerController.file(
          File(widget.message.videoElem!.videoPath!),
        )..initialize().then((_) {
            setState(() {});
          }).catchError((err) {
            print("初始化视频发生错误$err");
          });
      } else {
        _controller = VideoPlayerController.network(
          widget.message.videoElem!.videoUrl!,
        )..initialize().then((_) {
            setState(() {});
          }).catchError((err) {
            print("初始化视频发生错误$err");
          });
      }
    } catch (err) {
      print("视频初始化发生异常");
    }

    // ignore: invalid_use_of_protected_member
    if (!_controller!.hasListeners) {
      _controller!.addListener(() {
        print(
            "播放着 ${_controller!.value.isPlaying} ${_controller!.value.position} ${_controller!.value.duration} ${_controller!.value.duration == _controller!.value.position}");
        if (_controller!.value.position == _controller!.value.duration) {
          print("到头了 ${_controller!.value.isPlaying}");
          if (!_controller!.value.isPlaying) {
            setState(() {});
          }
        }
      });
    }
  }

  getUlr() {
    if (widget.message.videoElem!.videoUrl == null) {
      return widget.message.videoElem!.videoPath;
    } else {
      return widget.message.videoElem!.videoUrl;
    }
  }

  void deactivate() {
    super.deactivate();
    print("video message deactivate call ${widget.message.msgID}");
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller!.value.isInitialized
        ? Container(
            child: Stack(
              children: [
                Positioned(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
                Positioned(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        try {
                          setState(() {});
                          if (_controller!.value.isPlaying) {
                            _controller!.pause();
                          } else {
                            if (_controller!.value.position ==
                                _controller!.value.duration) {
                              _controller!.seekTo(Duration(
                                  seconds: 0,
                                  microseconds: 0,
                                  milliseconds: 0));
                            }
                            _controller!.play();
                            setState(() {});
                          }
                        } catch (err) {
                          Utils.toast(err.toString());
                        }
                      },
                      child: Icon(
                        _controller!.value.isPlaying
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        color: CommonColors.getWitheColor(),
                        size: 40,
                      ),
                    ),
                  ),
                  top: 0,
                  left: 0,
                  bottom: 0,
                  right: 0,
                ),
              ],
            ),
          )
        : Container(
            child: LoadingIndicator(
              indicatorType: Indicator.lineSpinFadeLoader,
              color: Colors.black26,
            ),
          );
  }
}
