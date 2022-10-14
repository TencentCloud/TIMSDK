// ignore_for_file: unused_field, avoid_print, unused_import

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/intl_camer_picker.dart';
import 'package:tim_ui_kit/ui/widgets/toast.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

import 'package:tim_ui_kit/ui/utils/shared_theme.dart';
import 'package:universal_html/html.dart' as html;

class MorePanelConfig {
  final bool showGalleryPickAction;
  final bool showCameraAction;
  final bool showFilePickAction;
  final bool showWebImagePickAction;
  final bool showWebVideoPickAction;
  final List<MorePanelItem>? extraAction;
  final Widget Function(MorePanelItem item)? actionBuilder;

  MorePanelConfig({
    this.showFilePickAction = true,
    this.showGalleryPickAction = true,
    this.showCameraAction = true,
    this.showWebImagePickAction = true,
    this.showWebVideoPickAction = true,
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
  final ConvType conversationType;

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

class _MorePanelState extends TIMUIKitState<MorePanel> {
  final ImagePicker _picker = ImagePicker();
  final TUISelfInfoViewModel _selfInfoViewModel =
      serviceLocator<TUISelfInfoViewModel>();
  Uint8List? fileContent;
  String? fileName;
  File? tempFile;

  List<MorePanelItem> itemList(TUIChatSeparateViewModel model) {
    final config = widget.morePanelConfig ?? MorePanelConfig();
    return [
      if (!PlatformUtils().isWeb)
        MorePanelItem(
            id: "screen",
            title: TIM_t("拍摄"),
            onTap: (c) {
              _onFeatureTap("screen", c, model);
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
      if (!PlatformUtils().isWeb)
        MorePanelItem(
            id: "photo",
            title: TIM_t("照片"),
            onTap: (c) {
              _onFeatureTap("photo", c, model);
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
      if (PlatformUtils().isWeb)
        MorePanelItem(
            id: "image",
            title: TIM_t("图片"),
            onTap: (c) {
              _onFeatureTap("image", c, model);
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
      if (PlatformUtils().isWeb)
        MorePanelItem(
            id: "video",
            title: TIM_t("视频"),
            onTap: (c) {
              _onFeatureTap("video", c, model);
            },
            icon: Container(
              height: 64,
              width: 64,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child:
                  Icon(Icons.video_file, color: hexToColor("5c6168"), size: 26),
            )),
      MorePanelItem(
          id: "file",
          title: TIM_t("文件"),
          onTap: (c) {
            _onFeatureTap("file", c, model);
          },
          icon: Container(
            height: 64,
            width: 64,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: SvgPicture.asset(
              "images/file.svg",
              package: 'tim_ui_kit',
              height: 64,
              width: 64,
            ),
          )),
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

      if (element.id == "image") {
        return config.showWebImagePickAction;
      }

      if (element.id == "video") {
        return config.showWebVideoPickAction;
      }
      return true;
    }).toList();
  }

  _sendVideoMessage(AssetEntity asset, TUIChatSeparateViewModel model) async {
    final originFile = await asset.originFile;
    final size = await originFile!.length();
    if (size >= 104857600) {
      onTIMCallback(TIMCallback(
          type: TIMCallbackType.INFO,
          infoRecommendText: TIM_t("发送失败,视频不能大于100MB"),
          infoCode: 6660405));
      return;
    }

    final duration = asset.videoDuration.inSeconds;
    final filePath = originFile.path;
    final convID = widget.conversationID;
    final convType = widget.conversationType;

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

  _sendImageMessage(TUIChatSeparateViewModel model) async {
    try {
      final bool isAndroid = PlatformUtils().isAndroid;
      if (!PlatformUtils().isWeb &&
          !await Permissions.checkPermission(context,
              isAndroid ? Permission.storage.value : Permission.photos.value)) {
        return;
      }
      final convID = widget.conversationID;
      final convType = widget.conversationType;
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
              _sendVideoMessage(asset, model);
            }
          }
        }
      }
    } catch (err) {
      print("err: $err");
    }
  }

  _sendImageFromCamera(TUIChatSeparateViewModel model) async {
    try {
      if (!await Permissions.checkPermission(
          context, Permission.camera.value)) {
        return;
      }
      final convID = widget.conversationID;
      final convType = widget.conversationType;
      // If here shows in English, not your language, you can add 'Localized resources can be mixed' with TRUE in "ios => Runner => info.plist"
      // final imageFile = await _picker.pickImage(source: ImageSource.camera);
      final pickedFile = await CameraPicker.pickFromCamera(context,
          pickerConfig: CameraPickerConfig(
              enableRecording: true,
              textDelegate: IntlCameraPickerTextDelegate()));
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
          _sendVideoMessage(pickedFile, model);
        }
      } else {
        // Toast.showToast(ToastType.fail, TIM_t("图片不能为空"), context);
      }
    } catch (error) {
      print("err: $error");
    }
  }

  _sendImageFileOnWeb(TUIChatSeparateViewModel model) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      final imageContent = await pickedFile!.readAsBytes();
      fileName = pickedFile.name;
      tempFile = File(pickedFile.path);
      fileContent = imageContent;

      html.Node? inputElem;
      inputElem = html.document
          .getElementById("__image_picker_web-file-input")
          ?.querySelector("input");
      final convID = widget.conversationID;
      final convType = widget.conversationType;
      MessageUtils.handleMessageError(
          model.sendImageMessage(
              inputElement: inputElem,
              imagePath: tempFile?.path,
              convID: convID,
              convType: convType),
          context);
    } catch (e) {
      print("_sendFileErr: ${e.toString()}");
    }
  }

  _sendVideoFileOnWeb(TUIChatSeparateViewModel model) async {
    try {
      final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      final videoContent = await pickedFile!.readAsBytes();
      fileName = pickedFile.name;
      tempFile = File(pickedFile.path);
      fileContent = videoContent;

      if (fileName!.split(".")[fileName!.split(".").length - 1] != "mp4") {
        onTIMCallback(TIMCallback(
            type: TIMCallbackType.INFO,
            infoRecommendText: TIM_t("视频消息仅限 mp4 格式"),
            infoCode: 6660412));
        return;
      }

      html.Node? inputElem;
      inputElem = html.document
          .getElementById("__image_picker_web-file-input")
          ?.querySelector("input");
      final convID = widget.conversationID;
      final convType = widget.conversationType;
      MessageUtils.handleMessageError(
          model.sendVideoMessage(
              inputElement: inputElem,
              videoPath: tempFile?.path,
              convID: convID,
              convType: convType),
          context);
    } catch (e) {
      print("_sendFileErr: ${e.toString()}");
    }
  }

  _sendFile(TUIChatSeparateViewModel model) async {
    if (!kIsWeb &&
        !await Permissions.checkPermission(context, Permission.storage.value)) {
      return;
    }
    try {
      final convID = widget.conversationID;
      final convType = widget.conversationType;
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        if (PlatformUtils().isWeb) {
          html.Node? inputElem;
          inputElem = html.document
              .getElementById("__file_picker_web-file-input")
              ?.querySelector("input");
          fileName = result.files.single.name;

          MessageUtils.handleMessageError(
              model.sendFileMessage(
                  inputElement: inputElem,
                  fileName: fileName,
                  convID: convID,
                  convType: convType),
              context);
          return;
        }

        String? option2 = result.files.single.path ?? "";
        print(TIM_t_para("选择成功{{option2}}", "选择成功$option2")(option2: option2));

        File file = File(result.files.single.path!);
        final int size = file.lengthSync();
        final String savePath = file.path;

        MessageUtils.handleMessageError(
            model.sendFileMessage(
                filePath: savePath,
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

  _onFeatureTap(
      String id, BuildContext context, TUIChatSeparateViewModel model) async {
    switch (id) {
      case "photo":
        _sendImageMessage(model);
        break;
      case "screen":
        _sendImageFromCamera(model);
        break;
      case "file":
        _sendFile(model);
        break;
      case "image":
        // only for web
        _sendImageFileOnWeb(model);
        break;
      case "video":
        // only for web
        _sendVideoFileOnWeb(model);
        break;
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final TUIChatSeparateViewModel model =
        Provider.of<TUIChatSeparateViewModel>(context);
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
        children: itemList(model)
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
