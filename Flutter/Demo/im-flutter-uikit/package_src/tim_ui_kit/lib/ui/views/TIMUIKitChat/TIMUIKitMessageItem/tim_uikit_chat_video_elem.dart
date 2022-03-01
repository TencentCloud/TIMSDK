import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

import 'package:chewie/chewie.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:tim_ui_kit/ui/utils/route.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/toast.dart';
import 'package:tim_ui_kit/ui/widgets/video_custom_control.dart';
import 'package:tim_ui_kit/ui/widgets/video_screen.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

import '../../../../i18n/i18n_utils.dart';
import '../tim_uikit_chat.dart';

class TIMUIKitVideoElem extends StatefulWidget {
  const TIMUIKitVideoElem(this.message, {Key? key}) : super(key: key);
  final V2TimMessage message;

  @override
  State<StatefulWidget> createState() => _TIMUIKitVideoElemState();
}

class _TIMUIKitVideoElemState extends State<TIMUIKitVideoElem> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  late double height;
  late double width;
  bool isInit = false;
  @override
  void initState() {
    super.initState();
    setVideoMessage();
  }

  // 覆写`wantKeepAlive`返回`true`

  //保存网络视频到本地
  _savenNetworkVideo(context, String videoUrl, {bool isAsset = true}) async {
    final I18nUtils ttBuild = I18nUtils(context);
    if (Platform.isIOS) {
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
    if (Platform.isIOS) {
      if (result['isSuccess']) {
        Toast.showToast(ToastType.success, ttBuild.imt("视频保存成功"), context);
      } else {
        Toast.showToast(ToastType.fail, ttBuild.imt("视频保存失败"), context);
      }
    } else {
      if (result != null) {
        Toast.showToast(ToastType.success, ttBuild.imt("视频保存成功"), context);
      } else {
        Toast.showToast(ToastType.fail, ttBuild.imt("视频保存失败"), context);
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

  setVideoMessage() async {
    VideoPlayerController player = widget.message.videoElem!.videoUrl == null
        ? VideoPlayerController.file(File(
            widget.message.videoElem!.videoPath!,
          ))
        : VideoPlayerController.network(
            widget.message.videoElem!.videoUrl!,
          );
    await player.initialize();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // 图片目前按照缩略图尺寸走的，并未走UI图，UI图比例过大图片很糊
      double w = getVideoWidth();
      double h = getVideoHeight();
      ChewieController controller = ChewieController(
          videoPlayerController: player,
          autoPlay: false,
          looping: false,
          showControlsOnInitialize: false,
          allowPlaybackSpeedChanging: false,
          aspectRatio: w / h,
          customControls: VideoCustomControls(downloadFn: _saveVideo));
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

  Widget errorDisplay(TUITheme? theme) {
    final I18nUtils ttBuild = I18nUtils(context);
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        width: 1,
        color: Colors.black12,
      )),
      height: 100,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: theme?.cautionColor,
              size: 16,
            ),
            Text(
              ttBuild.imt("视频加载失败"),
              style: TextStyle(color: theme?.cautionColor),
            ),
          ],
        ),
      ),
    );
  }

  double getMaxWidth(isSelect) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return width - (isSelect ? 180 : 150);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SharedThemeWidget.of(context)?.theme;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            FadeRoute(page: VideoScreen(videoController: chewieController)));
      },
      child: Container(
        // constraints: BoxConstraints(
        //     maxWidth: adaptWidth["width"], maxHeight: adaptWidth["height"]),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme?.weakDividerColor ?? CommonColor.weakDividerColor,
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.4, minWidth: 0),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        child: widget.message.videoElem!.snapshotUrl == null
                            ? ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxHeight: 420.h, //宽度尽可能大
                                    maxWidth: 320.w //最小高度为50像素
                                    ),
                                child: Image.file(
                                    File(widget
                                        .message.videoElem!.snapshotPath!),
                                    fit: BoxFit.fitWidth),
                              )
                            : CachedNetworkImage(
                                placeholder: (context, url) => Image(
                                    image: MemoryImage(kTransparentImage)),
                                cacheKey: widget.message.videoElem!.UUID,
                                fit: BoxFit.fitWidth,
                                imageUrl:
                                    widget.message.videoElem!.snapshotUrl!,
                                errorWidget: (context, url, error) =>
                                    errorDisplay(theme),
                              )),
                    Positioned.fill(
                      // alignment: Alignment.center,
                      child: Center(
                          child: Image.asset('images/play.png',
                              package: 'tim_ui_kit', height: 64)),
                    ),
                    Positioned(
                        right: 10,
                        bottom: 10,
                        child: Text(
                            MessageUtils.formatVideoTime(
                                    widget.message.videoElem?.duration ?? 0)
                                .toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12))),
                  ],
                ));
          }),
        ),
      ),
    );
  }
}
