import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_file_elem.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:open_file/open_file.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

import '../tim_uikit_chat.dart';

import '../../../../i18n/i18n_utils.dart';

class TIMUIKitFileElem extends StatefulWidget {
  final V2TimFileElem? fileElem;
  final bool isSelf;

  const TIMUIKitFileElem(
      {Key? key, required this.fileElem, required this.isSelf})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitFileElemState();
}

class _TIMUIKitFileElemState extends State<TIMUIKitFileElem> {
  int received = 0;

  Future<bool?> showOpenFileConfirmDialog(
      BuildContext context, String path, TUITheme? theme) {
        final I18nUtils ttBuild = I18nUtils(context);
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(widget.fileElem!.fileName!),
          content: Text(ttBuild.imt("“IM云通信”暂不可以打开此类文件，你可以使用其他应用打开并预览")),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(ttBuild.imt("取消"), style: TextStyle(color: theme?.primaryColor)),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            CupertinoDialogAction(
              child: Text(ttBuild.imt("用其他应用打开"),
                  style: TextStyle(color: theme?.secondaryColor)),
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

  void _onTap(context, theme) async {
    if (widget.isSelf) {
      showOpenFileConfirmDialog(context, widget.fileElem!.path!, theme);
    } else {
      var appDocDir = await getTemporaryDirectory();
      String savePath = appDocDir.path + '/' + widget.fileElem!.fileName!;
      if (received == 0) {
        if (!await Permissions.checkPermission(
            context, Permission.storage.value)) {
          return;
        }
        try {
          File f = File(savePath);
          if (f.existsSync()) {
            showOpenFileConfirmDialog(context, savePath, theme);
            return;
          }
          received = 1;
          print('start downloading');
          await Dio().download(widget.fileElem!.url!, savePath,
              onReceiveProgress: (recv, total) {
            if (total != -1) {
              // print((received / total * 100).toStringAsFixed(0) + "%");
              setState(() {
                received = (recv / total * 100).ceil();
              });
              //you can build progressbar feature too
            }
          });
          print("File is saved to download folder.");
        } on DioError catch (e) {
          received = 0;
          print(e.message);
        }
      } else if (received == 100) {
        showOpenFileConfirmDialog(context, savePath, theme);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SharedThemeWidget.of(context)?.theme;
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
    return GestureDetector(
        onTap: () {
          _onTap(context, theme);
        },
        child: Container(
          width: 237,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
              border: Border.all(
                color: theme?.weakDividerColor ?? CommonColor.weakDividerColor,
              ),
              borderRadius: borderRadius),
          child: Row(
              mainAxisAlignment: widget.isSelf
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme?.darkTextColor,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      received > 0 && received < 100
                          ? "$received%"
                          : "${(fileSize! / 1024).ceil()} KB",
                      // "${received > 0 ? (received / 1024).ceil() : (received / 1024).ceil()} KB",
                      style:
                          TextStyle(fontSize: 14, color: theme?.weakTextColor),
                    )
                  ],
                )),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Icon(
                    Icons.file_present_outlined,
                    color: theme?.cautionColor,
                    size: 40,
                  ),
                )
              ]),
        ));
  }
}
