// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:open_file/open_file.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_wrapper.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_file_icon.dart';
import 'package:tim_ui_kit/ui/widgets/textSize.dart';
import 'package:url_launcher/url_launcher.dart';

class TIMUIKitFileElem extends StatefulWidget {
  final String? messageID;
  final V2TimFileElem? fileElem;
  final bool isSelf;
  final bool isShowJump;
  final VoidCallback? clearJump;
  final V2TimMessage message;
  final bool? isShowMessageReaction;
  final TUIChatSeparateViewModel chatModel;

  const TIMUIKitFileElem(
      {Key? key,
        required this.chatModel,
      required this.messageID,
      required this.fileElem,
      required this.isSelf,
      required this.isShowJump,
      this.clearJump,
      required this.message,
      this.isShowMessageReaction})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitFileElemState();
}

class _TIMUIKitFileElemState extends TIMUIKitState<TIMUIKitFileElem> {
  String filePath = "";
  final TUIChatGlobalModel model = serviceLocator<TUIChatGlobalModel>();

  Future<bool?> showOpenFileConfirmDialog(
      BuildContext context, String path, TUITheme? theme) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String option2 = packageInfo.appName;
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(widget.fileElem!.fileName!),
          content: Text(TIM_t_para("“{{option2}}”暂不可以打开此类文件，你可以使用其他应用打开并预览",
              "“$option2”暂不可以打开此类文件，你可以使用其他应用打开并预览")(option2: option2)),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(TIM_t("取消"),
                  style: TextStyle(color: theme?.secondaryColor)),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            CupertinoDialogAction(
              child: Text(TIM_t("用其他应用打开"),
                  style: TextStyle(color: theme?.primaryColor)),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop();
                OpenFile.open(path);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (!PlatformUtils().isWeb) {
      getTemporaryDirectory().then((appDocDir) {
        String filePath = widget.fileElem!.path ??
            (appDocDir.path +
                '/' +
                (widget.message.msgID ?? "") +
                widget.fileElem!.fileName!);
        hasFile(filePath);
        if (widget.fileElem!.path != null) {
          hasFile(appDocDir.path +
              '/' +
              (widget.message.msgID ?? "") +
              widget.fileElem!.fileName!);
        }
      });
    }
  }

  bool hasFile(String savePath) {
    File f = File(savePath);
    if (f.existsSync() && widget.messageID != null) {
      filePath = savePath;
      model.setMessageProgress(widget.messageID!, 100);
      return true;
    }
    return false;
  }

  void _onTap(context, theme, received) async {
    if (PlatformUtils().isWeb) {
      launchUrl(
        Uri.parse(widget.fileElem?.path ?? ""),
        mode: LaunchMode.externalApplication,
      );
      return;
    }
    var appDocDir = await getTemporaryDirectory();
    String savePath = widget.fileElem!.path ??
        (appDocDir.path +
            '/' +
            (widget.message.msgID ?? "") +
            widget.fileElem!.fileName!);
    String savePathWithAppPath = appDocDir.path +
        '/' +
        (widget.message.msgID ?? "") +
        widget.fileElem!.fileName!;
    if (received == 0) {
      if (!await Permissions.checkPermission(
          context, Permission.storage.value)) {
        return;
      }
      try {
        if (hasFile(savePath)) {
          showOpenFileConfirmDialog(context, savePath, theme);
          return;
        }

        if (hasFile(savePathWithAppPath)) {
          showOpenFileConfirmDialog(context, savePathWithAppPath, theme);
          return;
        }
        model.setMessageProgress(widget.messageID!, 1);
        print('start downloading');

        await Dio().download(widget.fileElem!.url!, savePath,
            onReceiveProgress: (recv, total) {
          if (total != -1) {
            // print((received / total * 100).toStringAsFixed(0) + "%");
            model.setMessageProgress(
                widget.messageID!, (recv / total * 100).ceil());
            //you can build progressbar feature too
          }
        });
        filePath = savePath;
        print("File is saved to download folder.");
      } catch (e) {
        try {
          await Dio().download(widget.fileElem!.url!, savePathWithAppPath,
              onReceiveProgress: (recv, total) {
            if (total != -1) {
              // print((received / total * 100).toStringAsFixed(0) + "%");
              model.setMessageProgress(
                  widget.messageID!, (recv / total * 100).ceil());
              //you can build progressbar feature too
            }
          });
          filePath = savePathWithAppPath;
        } catch (e) {
          model.setMessageProgress(widget.messageID!, 0);
          print('Error $e');
          onTIMCallback(
              TIMCallback(type: TIMCallbackType.FLUTTER_ERROR, catchError: e));
        }
      }
    } else if (received == 100) {
      hasFile(savePath);
      hasFile(savePathWithAppPath);
      showOpenFileConfirmDialog(context, filePath, theme);
    }
  }

  String showFileSize(int fileSize) {
    if (fileSize < 1024) {
      return fileSize.toString() + "B";
    } else if (fileSize < 1024 * 1024) {
      return (fileSize / 1024).toStringAsFixed(2) + "KB";
    } else if (fileSize < 1024 * 1024 * 1024) {
      return (fileSize / 1024 / 1024).toStringAsFixed(2) + "MB";
    } else {
      return (fileSize / 1024 / 1024 / 1024).toStringAsFixed(2) + "GB";
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    return TIMUIKitMessageReactionWrapper(
      chatModel: widget.chatModel,
        isShowJump: widget.isShowJump,
        clearJump: widget.clearJump,
        isFromSelf: widget.message.isSelf ?? true,
        isShowMessageReaction: widget.isShowMessageReaction ?? true,
        message: widget.message,
        child: ChangeNotifierProvider.value(
            value: model,
            child:
                Consumer<TUIChatGlobalModel>(builder: (context, value, child) {
              final received = value.getMessageProgress(widget.messageID);
              final fileName = widget.fileElem!.fileName ?? "";
              final fileSize = widget.fileElem!.fileSize;
              final borderRadius = widget.isSelf
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(2),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))
                  : const BorderRadius.only(
                      topLeft: Radius.circular(2),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10));
              String? fileFormat;
              if (widget.fileElem?.fileName != null &&
                  widget.fileElem!.fileName!.isNotEmpty) {
                final String fileName = widget.fileElem!.fileName!;
                fileFormat =
                    fileName.split(".")[max(fileName.split(".").length - 1, 0)];
              }
              return GestureDetector(
                  onTap: () {
                    if (value.isDownloading) {
                      onTIMCallback(TIMCallback(
                          type: TIMCallbackType.INFO,
                          infoRecommendText: TIM_t("其他文件正在接收中"),
                          infoCode: 6660410));
                      return;
                    }
                    //if downloaded or not download can tap
                    if (received == 0 || received == 100) {
                      _onTap(context, theme, received);
                    } else {
                      onTIMCallback(TIMCallback(
                          type: TIMCallbackType.INFO,
                          infoRecommendText: TIM_t("正在接收中"),
                          infoCode: 6660411));
                    }
                  },
                  child: Container(
                    width: 237,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.weakDividerColor ??
                              CommonColor.weakDividerColor,
                        ),
                        borderRadius: borderRadius),
                    child: Stack(children: [
                      ClipRRect(
                        //剪裁为圆角矩形
                        borderRadius: borderRadius,
                        child: LinearProgressIndicator(
                            minHeight: 66,
                            value: (received == 100 ? 0 : received) / 100,
                            backgroundColor: received == 100
                                ? theme.weakBackgroundColor
                                : Colors.white,
                            valueColor: AlwaysStoppedAnimation(
                                theme.lightPrimaryMaterialColor.shade50)),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: Row(
                              mainAxisAlignment: widget.isSelf
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints:
                                          const BoxConstraints(maxWidth: 160),
                                      child: LayoutBuilder(
                                        builder:
                                            (buildContext, boxConstraints) {
                                          return ExtendText(
                                            fileName,
                                            width: boxConstraints.maxWidth,
                                            style: TextStyle(
                                              color: theme.darkTextColor,
                                              fontSize: 16,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    if (fileSize != null)
                                      Text(
                                        showFileSize(fileSize),
                                        // "${received > 0 ? (received / 1024).ceil() : (received / 1024).ceil()} KB",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: theme.weakTextColor),
                                      )
                                  ],
                                )),
                                TIMUIKitFileIcon(
                                  fileFormat: fileFormat,
                                ),
                              ])),
                    ]),
                  ));
            })));
  }
}
