import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:tim_ui_kit/ui/widgets/toast.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../../i18n/i18n_utils.dart';

import '../tim_uikit_chat.dart';

class MorePanel extends StatefulWidget {
  /// 会话ID
  final String conversationID;

  /// 会话类型
  final int conversationType;
  const MorePanel(
      {required this.conversationID, required this.conversationType, Key? key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _MorePanelState();
}

class _MorePanelState extends State<MorePanel> {
  final ImagePicker _picker = ImagePicker();
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();

  List itemList() {
    final I18nUtils ttBuild = I18nUtils(context);
    return [
    {"title": ttBuild.imt("照相"), "id": "screen", "assetName": "images/screen.svg"},
    {"title": ttBuild.imt("视频"), "id": "video", "assetName": "images/video-call.svg"},
    // {"title": t.morePanelPhoto, "id": "photo", "assetName": "images/photo.svg"},
    // {"title": t.morePanelFile, "id": "file", "assetName": "images/file.svg"},
    //   {"title": ttBuild.imt("拍摄"), "id": "screen", "assetName": "images/screen.svg"},
    //   {"title": ttBuild.imt("视频"), "id": "video", "assetName": "images/video-call.svg"},
      {"title": ttBuild.imt("相片"), "id": "photo", "assetName": "images/photo.svg"},
      {"title": ttBuild.imt("文件"), "id": "file", "assetName": "images/file.svg"},
    // {"title": ttBuild.imt("语音通话"), "id": "voice-call", "assetName": "images/voice-call.svg"},
    // {"title": ttBuild.imt("名片"), "id": "card", "assetName": "images/card.svg"},
    // {"title": ttBuild.imt("戳一戳"), "id": "poke", "assetName": "images/poke.svg"},
    // {"title": ttBuild.imt("自定义消息"), "id": "custom-msg", "assetName": "images/custom-msg.svg"}
  ];
  }

  _sendImageMessage() async {
    try {
      if (!await Permissions.checkPermission(
          context, Permission.photos.value)) {
        return;
      }
      final convID = widget.conversationID;
      final convType =
          widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        model.sendImageMessage(
            imagePath: pickedFile.path, convID: convID, convType: convType);
      }
    } catch (err) {
      print("err: $err");
    }
  }

  _sendImageFromCamera() async {
    try {
      if (!await Permissions.checkPermission(
          context, Permission.camera.value)) {
        return;
      }
      final convID = widget.conversationID;
      final convType =
          widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
      // If here shows in English, not your language, you can add 'Localized resources can be mixed' with TRUE in "ios => Runner => info.plist"
      final imageFile = await _picker.pickImage(source: ImageSource.camera);
      if (imageFile != null && convID != null) {
        model.sendImageMessage(
            imagePath: imageFile.path, convID: convID, convType: convType);
      }
    } catch (error) {
      print("err: $error");
    }
  }

  _sendVideoFromCamera(BuildContext context) async {
    final I18nUtils ttBuild = I18nUtils(context);
    try {
      if (!await Permissions.checkPermission(
          context, Permission.camera.value)) {
        return;
      }
      final convID = widget.conversationID;
      final convType =
          widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
      final videoFile = await _picker.pickVideo(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front);
      if (videoFile != null && convID != null) {
        String tempPath = (await getTemporaryDirectory()).path;

        String? thumbnail = await VideoThumbnail.thumbnailFile(
          video: videoFile.path,
          thumbnailPath: tempPath,
          imageFormat: ImageFormat.JPEG,
          maxWidth:
              128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 25,
        );

        // 获取视频文件大小(默认为字节)
        final file = File(videoFile.path);
        VideoPlayerController controller = VideoPlayerController.file(file);
        int size = await file.length();
        if (size >= 104857600) {
          Toast.showToast(ToastType.fail, ttBuild.imt("发送失败,视频不能大于100MB"), context);
          return;
        }
        await controller.initialize();
        model.sendVideoMessage(
            videoPath: videoFile.path,
            duration: controller.value.duration.inSeconds,
            snapshotPath: thumbnail ?? '',
            convID: convID,
            convType: convType);
      }
    } catch (error) {
      print("err: $error");
    }
  }

  _sendFile() async {
    final I18nUtils ttBuild = I18nUtils(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      final convID = widget.conversationID;
      final convType =
          widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
      if (result != null && convID != null) {
        final successPath = result.files.single.path;
        print(ttBuild.imt_para("选择成功{{successPath}}", "选择成功${successPath}")(successPath: successPath));
        File file = File(result.files.single.path!);
        int size = file.lengthSync();
        model.sendFileMessage(
            filePath: file.path,
            size: size,
            convID: convID,
            convType: convType);
      } else {
        throw NullThrownError();
      }
    } catch (e) {
      print("_sendFileErr: ${e.toString()}");
    }
  }

  _onFeatureTap(String id, BuildContext context) async {
    switch (id) {
      case "photo":
        _sendImageMessage();
        break;
      case "screen":
        _sendImageFromCamera();
        break;
      case "video":
        _sendVideoFromCamera(context);
        break;
      case "file":
        _sendFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SharedThemeWidget.of(context)?.theme;
    return Container(
      height: 248,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 23),
      color: theme?.weakBackgroundColor,
      alignment: Alignment.topCenter,
      width: MediaQuery.of(context).size.width,
      child: Wrap(
        spacing: 24,
        runSpacing: 20,
        children: itemList()
            .map((item) => InkWell(
                onTap: () {
                  _onFeatureTap(item["id"] as String, context);
                },
                child: SizedBox(
                  height: 94,
                  width: 64,
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: SvgPicture.asset(
                          item["assetName"] as String,
                          package: 'tim_ui_kit',
                          // color: const Color.fromRGBO(68, 68, 68, 1),
                          height: 64,
                          width: 64,
                        ),
                      ),
                      Text(
                        item['title'].toString(),
                        style: TextStyle(
                            fontSize: 12, color: theme?.darkTextColor),
                      )
                    ],
                  ),
                )))
            .toList(),
      ),
    );
  }
}
