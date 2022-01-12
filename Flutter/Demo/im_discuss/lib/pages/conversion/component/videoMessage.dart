import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/provider/multiselect.dart';
import 'package:discuss/utils/commonUtils.dart';
import 'package:discuss/utils/permissions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_autosize_screen/auto_size_util.dart';
import 'package:provider/provider.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

import 'package:chewie/chewie.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

import 'videoScreen.dart';

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
    bool isOpen = Provider.of<MultiSelect>(context, listen: false).isopen;
    setVideoMessage(isOpen);
  }

  @override
  // 覆写`wantKeepAlive`返回`true`
  bool get wantKeepAlive => true;

  //保存网络视频到本地
  _savenNetworkVideo(context, String videoUrl, {bool isAsset = true}) async {
    if (Platform.isIOS) {
      if (!await Permissions.checkPermission(
          context, Permission.photos.value)) {
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
        Fluttertoast.showToast(msg: '保存成功', gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(msg: '保存失败', gravity: ToastGravity.CENTER);
      }
    } else {
      if (result != null) {
        Fluttertoast.showToast(msg: '保存成功', gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(msg: '保存失败', gravity: ToastGravity.CENTER);
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

  setVideoMessage([bool? isOpen = false]) {
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
      double w = getMaxWidth(isOpen);
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

  Widget errorDisplay() {
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
          children: const [
            Icon(
              Icons.warning_amber_outlined,
              color: Colors.red,
              size: 16,
            ),
            Text(
              "图片加载失败",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      return Container();
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(FadeRoute(
            page: VideoScreen(
                videoController: chewieController, downloadFn: _saveVideo)));
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: width, maxHeight: height),
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
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: widget.message.videoElem!.snapshotUrl == null
                      ? Image.file(
                          File(widget.message.videoElem!.snapshotPath!),
                        )
                      : FadeInImage.memoryNetwork(
                          height: widget.message.videoElem!.snapshotHeight!
                              .toDouble(),
                          fadeInCurve: Curves.ease,
                          fit: BoxFit.contain,
                          image: widget.message.videoElem!.snapshotUrl!,
                          placeholder: kTransparentImage,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              errorDisplay(),
                        ),
                ),
                Positioned.fill(
                  // alignment: Alignment.center,
                  child:
                      Center(child: Image.asset('images/play.png', height: 64)),
                ),
                Positioned(
                    right: 10,
                    bottom: 10,
                    child: Text(
                        CommonUtils.formatTime(
                                videoPlayerController.value.duration.inSeconds)
                            .toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12))),
              ],
            )),

        /*
    Text(
            "${widget.message.videoElem?.videoPath} 远程视频地址 ${widget.message.videoElem?.videoUrl}"
            "空的")
      */
      ),
    );
  }
}
