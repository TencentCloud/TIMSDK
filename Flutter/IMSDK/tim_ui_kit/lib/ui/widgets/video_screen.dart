import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:chewie/chewie.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/widgets/video_custom_control.dart';
import 'package:video_player/video_player.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({required this.message, required this.heroTag, Key? key})
      : super(key: key);

  final V2TimMessage message;
  final dynamic heroTag;

  @override
  State<StatefulWidget> createState() => _VideoScreenState();
}

class _VideoScreenState extends TIMUIKitState<VideoScreen> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();
  bool isInit = false;
  @override
  initState() {
    super.initState();
    setVideoMessage();
    // 允许横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  //保存网络视频到本地
  _savenNetworkVideo(context, String videoUrl, {bool isAsset = true}) async {
    if (PlatformUtils().isIOS) {
      if (!await Permissions.checkPermission(
          context, Permission.photosAddOnly.value)) {
        return;
      }
    } else {
      if (!await Permissions.checkPermission(
          context, Permission.storage.value)) {
        return;
      }
    }
    String savePath = videoUrl;
    if (!isAsset) {
      var appDocDir = await getTemporaryDirectory();
      savePath = appDocDir.path + "/temp.mp4";
      await Dio().download(videoUrl, savePath);
    }
    var result = await ImageGallerySaver.saveFile(savePath);
    if (PlatformUtils().isIOS) {
      if (result['isSuccess']) {
        onTIMCallback(TIMCallback(
            type: TIMCallbackType.INFO,
            infoRecommendText: TIM_t("视频保存成功"),
            infoCode: 6660402));
      } else {
        onTIMCallback(TIMCallback(
            type: TIMCallbackType.INFO,
            infoRecommendText: TIM_t("视频保存失败"),
            infoCode: 6660403));
      }
    } else {
      if (result != null) {
        onTIMCallback(TIMCallback(
            type: TIMCallbackType.INFO,
            infoRecommendText: TIM_t("视频保存成功"),
            infoCode: 6660402));
      } else {
        onTIMCallback(TIMCallback(
            type: TIMCallbackType.INFO,
            infoRecommendText: TIM_t("视频保存失败"),
            infoCode: 6660403));
      }
    }
  }

  void _saveVideo() {
    if (widget.message.videoElem!.videoUrl == null) {
      _savenNetworkVideo(context, widget.message.videoElem!.videoPath!,
          isAsset: true);
    } else {
      _savenNetworkVideo(context, widget.message.videoElem!.videoUrl!,
          isAsset: false);
    }
  }

  double getVideoHeight() {
    double height = widget.message.videoElem!.snapshotHeight!.toDouble();
    double width = widget.message.videoElem!.snapshotWidth!.toDouble();
    // 横图
    if (width > height) {
      return height * 1.3;
    }
    return height;
  }

  double getVideoWidth() {
    double height = widget.message.videoElem!.snapshotHeight!.toDouble();
    double width = widget.message.videoElem!.snapshotWidth!.toDouble();
    // 横图
    if (width > height) {
      return width * 1.3;
    }
    return width;
  }

  setVideoMessage() async {
    // 当消息发送中时请使用本地资源
    VideoPlayerController player = widget.message.videoElem!.videoUrl == null ||
            widget.message.status == MessageStatus.V2TIM_MSG_STATUS_SENDING
        ? VideoPlayerController.file(File(
            widget.message.videoElem!.videoPath!,
          ))
        : (widget.message.videoElem?.localVideoUrl == null ||
                widget.message.videoElem?.localVideoUrl == "")
            ? VideoPlayerController.network(
                widget.message.videoElem!.videoUrl!,
              )
            : VideoPlayerController.file(File(
                widget.message.videoElem!.localVideoUrl!,
              ));
    await player.initialize();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // 图片目前按照缩略图尺寸走的，并未走UI图，UI图比例过大图片很糊
      double w = getVideoWidth();
      double h = getVideoHeight();
      ChewieController controller = ChewieController(
          videoPlayerController: player,
          autoPlay: true,
          looping: false,
          showControlsOnInitialize: false,
          allowPlaybackSpeedChanging: false,
          aspectRatio: w == 0 || h == 0 ? null : w / h,
          customControls: VideoCustomControls(downloadFn: _saveVideo));
      setState(() {
        videoPlayerController = player;
        chewieController = controller;
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    if (isInit) {
      videoPlayerController.dispose();
      chewieController.dispose();
    }
    super.dispose();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return OrientationBuilder(builder: ((context, orientation) {
      return Container(
        color: Colors.transparent,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: ExtendedImageSlidePage(
            key: slidePagekey,
            slidePageBackgroundHandler: (Offset offset, Size size) {
              if (orientation == Orientation.landscape) {
                return Colors.black;
              }
              double opacity = 0.0;
              opacity = offset.distance /
                  (Offset(size.width, size.height).distance / 2.0);
              return Colors.black
                  .withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
            },
            slideType: SlideType.onlyImage,
            child: ExtendedImageSlidePageHandler(
              child: Container(
                  color: Colors.black,
                  child: isInit
                      ? Chewie(
                          controller: chewieController,
                        )
                      : const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white))),
              heroBuilderForSlidingPage: (Widget result) {
                return Hero(
                  tag: widget.heroTag,
                  child: result,
                  flightShuttleBuilder: (BuildContext flightContext,
                      Animation<double> animation,
                      HeroFlightDirection flightDirection,
                      BuildContext fromHeroContext,
                      BuildContext toHeroContext) {
                    final Hero hero =
                        (flightDirection == HeroFlightDirection.pop
                            ? fromHeroContext.widget
                            : toHeroContext.widget) as Hero;

                    return hero.child;
                  },
                );
              },
            )),
      );
    }));
  }
}
