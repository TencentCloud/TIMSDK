// ignore_for_file: unused_field, avoid_print, unused_local_variable, unused_import

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/widgets/toast.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';

import 'package:tim_ui_kit/ui/utils/shared_theme.dart';

class MorePanelConfig {
  final bool showGalleryPickAction;
  final bool showCameraAction;
  final bool showFilePickAction;
  final List<MorePanelItem>? extraAction;
  final Widget Function(MorePanelItem item)? actionBuilder;

  MorePanelConfig({
    this.showFilePickAction = true,
    this.showGalleryPickAction = true,
    this.showCameraAction = true,
    this.extraAction,
    this.actionBuilder,
  });
}

class MorePanelItem {
  final String title;
  final String id;
  final Widget icon;
  final Function(BuildContext context)? onTap;

  MorePanelItem(
      {this.onTap, required this.icon, required this.id, required this.title});
}

class MorePanel extends StatefulWidget {
  /// 会话ID
  final String conversationID;

  /// 会话类型
  final int conversationType;

  final MorePanelConfig? morePanelConfig;

  const MorePanel(
      {required this.conversationID,
      required this.conversationType,
      Key? key,
      this.morePanelConfig})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _MorePanelState();
}

class _MorePanelState extends State<MorePanel> {
  final ImagePicker _picker = ImagePicker();
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final TUISelfInfoViewModel _selfInfoViewModel =
      serviceLocator<TUISelfInfoViewModel>();

  List<MorePanelItem> itemList() {
    final I18nUtils ttBuild = I18nUtils(context);
    final config = widget.morePanelConfig ?? MorePanelConfig();
    return [
      MorePanelItem(
          id: "screen",
          title: ttBuild.imt("拍摄"),
          onTap: (c) {
            _onFeatureTap("screen", c);
          },
          icon: Container(
            height: 64,
            width: 64,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: SvgPicture.asset(
              "images/screen.svg",
              package: 'tim_ui_kit',
              height: 64,
              width: 64,
            ),
          )),
      MorePanelItem(
          id: "photo",
          title: ttBuild.imt("照片"),
          onTap: (c) {
            _onFeatureTap("photo", c);
          },
          icon: Container(
            height: 64,
            width: 64,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: SvgPicture.asset(
              "images/photo.svg",
              package: 'tim_ui_kit',
              height: 64,
              width: 64,
            ),
          )),
      // MorePanelItem(
      //     id: "file",
      //     title: ttBuild.imt("文件"),
      //     onTap: (c) {
      //       _onFeatureTap("file", c);
      //     },
      //     icon: Container(
      //       height: 64,
      //       width: 64,
      //       margin: const EdgeInsets.only(bottom: 4),
      //       decoration: const BoxDecoration(
      //           color: Colors.white,
      //           borderRadius: BorderRadius.all(Radius.circular(5))),
      //       child: SvgPicture.asset(
      //         "images/file.svg",
      //         package: 'tim_ui_kit',
      //         height: 64,
      //         width: 64,
      //       ),
      //     )),
      if (config.extraAction != null) ...?config.extraAction,
    ].where((element) {
      if (element.id == "screen") {
        return config.showCameraAction;
      }

      if (element.id == "file") {
        return config.showFilePickAction;
      }

      if (element.id == "photo") {
        return config.showGalleryPickAction;
      }
      return true;
    }).toList();
  }

  _sendVideoMessage(AssetEntity asset) async {
    final I18nUtils ttBuild = I18nUtils(context);
    final originFile = await asset.originFile;
    final size = await originFile!.length();
    if (size >= 104857600) {
      Toast.showToast(ToastType.fail, ttBuild.imt("发送失败,视频不能大于100MB"), context);
      return;
    }

    final duration = asset.videoDuration.inSeconds;
    final filePath = originFile.path;
    final convID = widget.conversationID;
    final convType =
        widget.conversationType == 1 ? ConvType.c2c : ConvType.group;

    String tempPath = (await getTemporaryDirectory()).path;

    String? thumbnail = await video_thumbnail.VideoThumbnail.thumbnailFile(
      video: originFile.path,
      thumbnailPath: tempPath,
      imageFormat: video_thumbnail.ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    MessageUtils.handleMessageError(
        model.sendVideoMessage(
            videoPath: filePath,
            duration: duration,
            snapshotPath: thumbnail ?? '',
            convID: convID,
            convType: convType),
        context);
  }

  _sendImageMessage() async {
    try {
      final bool isAndroid = PlatformUtils().isAndroid;
      if (!await Permissions.checkPermission(context,
          isAndroid ? Permission.storage.value : Permission.photos.value)) {
        return;
      }
      final convID = widget.conversationID;
      final convType =
          widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
      final pickedAssets = await AssetPicker.pickAssets(context);

      if (pickedAssets != null) {
        for (var asset in pickedAssets) {
          final originFile = await asset.originFile;
          final filePath = originFile?.path;
          final type = asset.type;
          if (filePath != null) {
            if (type == AssetType.image) {
              MessageUtils.handleMessageError(
                  model.sendImageMessage(
                      imagePath: filePath, convID: convID, convType: convType),
                  context);
            }

            if (type == AssetType.video) {
              _sendVideoMessage(asset);
            }
          }
        }
      }
    } catch (err) {
      print("err: $err");
    }
  }

  _sendImageFromCamera() async {
    final I18nUtils ttBuild = I18nUtils(context);
    try {
      if (!await Permissions.checkPermission(
          context, Permission.camera.value)) {
        return;
      }
      final convID = widget.conversationID;
      final convType =
          widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
      // If here shows in English, not your language, you can add 'Localized resources can be mixed' with TRUE in "ios => Runner => info.plist"
      // final imageFile = await _picker.pickImage(source: ImageSource.camera);
      final pickedFile = await CameraPicker.pickFromCamera(context,
          pickerConfig: const CameraPickerConfig(enableRecording: true));
      final originFile = await pickedFile?.originFile;
      if (originFile != null) {
        final type = pickedFile!.type;
        if (type == AssetType.image) {
          MessageUtils.handleMessageError(
              model.sendImageMessage(
                  imagePath: originFile.path,
                  convID: convID,
                  convType: convType),
              context);
        }

        if (type == AssetType.video) {
          _sendVideoMessage(pickedFile);
        }
      } else {
        // Toast.showToast(ToastType.fail, ttBuild.imt("图片不能为空"), context);
      }
    } catch (error) {
      print("err: $error");
    }
  }

  _sendFile() async {
    final I18nUtils ttBuild = I18nUtils(context);
    try {
      // if (!await Permissions.checkPermission(
      //     context, Permission.storage.value)) {
      //   return;
      // }
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      final convID = widget.conversationID;
      final convType =
          widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
      if (result != null) {
        String? option2 = result.files.single.path ?? "";
        print(ttBuild.imt_para("选择成功{{option2}}", "选择成功$option2")(
            option2: option2));
        File file = File(result.files.single.path!);
        int size = file.lengthSync();
        String savePtah = file.path;

        MessageUtils.handleMessageError(
            model.sendFileMessage(
                filePath: savePtah,
                size: size,
                convID: convID,
                convType: convType),
            context);
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
      case "file":
        _sendFile();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = SharedThemeWidget.of(context)?.theme;
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 248,
      decoration: BoxDecoration(
        // color: hexToColor("EBF0F6"),
        border: Border(
          top: BorderSide(width: 1, color: Colors.grey.shade300),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 23),
      width: screenWidth,
      child: Wrap(
        spacing: (screenWidth - (23 * 2) - 64 * 4) / 3,
        runSpacing: 20,
        children: itemList()
            .map((item) => InkWell(
                onTap: () {
                  if (item.onTap != null) {
                    item.onTap!(context);
                  }
                },
                child: widget.morePanelConfig?.actionBuilder != null
                    ? widget.morePanelConfig?.actionBuilder!(item)
                    : SizedBox(
                        height: 94,
                        width: 64,
                        child: Column(
                          children: [
                            Container(
                              height: 64,
                              width: 64,
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: item.icon,
                            ),
                            Text(
                              item.title,
                              style: TextStyle(
                                  fontSize: 12, color: theme.darkTextColor),
                            )
                          ],
                        ),
                      )))
            .toList(),
      ),
    );
  }
}
