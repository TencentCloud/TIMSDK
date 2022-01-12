import 'dart:io';

import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/provider/multiselect.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_autosize_screen/auto_size_util.dart';
import 'package:provider/provider.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoMessage extends StatefulWidget {
  const VideoMessage(this.message, {Key? key}) : super(key: key);
  final V2TimMessage message;

  @override
  State<StatefulWidget> createState() => VideoMessageState();
}

class VideoMessageState extends State<VideoMessage>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  late double height;
  late double width;
  bool isInit = false;
  @override
  void initState() {
    super.initState();
    super.build(context);
    bool isopen = Provider.of<MultiSelect>(context, listen: false).isopen;
    VideoPlayerController player = widget.message.videoElem!.videoUrl == null
        ? VideoPlayerController.file(File(
            widget.message.videoElem!.videoPath!,
          ))
        : VideoPlayerController.network(
            widget.message.videoElem!.videoUrl!,
          );
    player.initialize();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      //需要创建的小组件
      double currentVideoHeight = geiVideoheight();
      double w = getMaxWidth(isopen);
      // 这里做判断是为了防止某些机型，发送视屏时无法正确获取到视屏高度的情况
      double h = currentVideoHeight == 0
          ? 490
          : ((w * currentVideoHeight) / geiVideoWidth());

      ChewieController controller = ChewieController(
        videoPlayerController: player,
        autoPlay: false,
        looping: false,
        showControlsOnInitialize: false,
        allowPlaybackSpeedChanging: false,
        aspectRatio: w / h,
      );
      setState(() {
        videoPlayerController = player;
        chewieController = controller;
        height = h;
        width = w;
        isInit = true;
      });
    });
  }

  @override
  // 覆写`wantKeepAlive`返回`true`
  bool get wantKeepAlive => true;

  setVideoMessage() {
    VideoPlayerController player = widget.message.videoElem!.videoUrl == null
        ? VideoPlayerController.file(File(
            widget.message.videoElem!.videoPath!,
          ))
        : VideoPlayerController.network(
            widget.message.videoElem!.videoUrl!,
          );
    player.initialize();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      //需要创建的小组件
      double currentVideoHeight = geiVideoheight();
      double w = getMaxWidth(false);
      // 这里做判断是为了防止某些机型，发送视屏时无法正确获取到视屏高度的情况
      double h = currentVideoHeight == 0
          ? 490
          : ((w * currentVideoHeight) / geiVideoWidth());

      ChewieController controller = ChewieController(
        videoPlayerController: player,
        autoPlay: false,
        looping: false,
        showControlsOnInitialize: false,
        allowPlaybackSpeedChanging: false,
        aspectRatio: w / h,
      );
      setState(() {
        videoPlayerController = player;
        chewieController = controller;
        height = h;
        width = w;
        isInit = true;
      });
    });
  }

  @override
  didUpdateWidget(oldWidget) {
    if (oldWidget.message.videoElem!.videoUrl !=
            widget.message.videoElem!.videoUrl ||
        oldWidget.message.videoElem!.videoPath !=
            widget.message.videoElem!.videoPath) {
      setVideoMessage();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  // double getMaxWidth(isopen) {
  //   return AutoSizeUtil.getScreenSize().width - (isopen ? 180 : 130);
  // }
  double getMaxWidth(isopen) {
    return MediaQuery.of(context).size.width - (isopen ? 180 : 130);
  }

  double geiVideoheight() {
    return widget.message.videoElem!.snapshotHeight!.toDouble();
  }

  double geiVideoWidth() {
    return widget.message.videoElem!.snapshotWidth!.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      return Container();
    }
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(
          color: hexToColor("E5E5E5"),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Chewie(
          controller: chewieController,
        ),
      ),

      /*
    Text(
            "${widget.message.videoElem?.videoPath} 远程视频地址 ${widget.message.videoElem?.videoUrl}"
            "空的")
      */
    );
  }
}
