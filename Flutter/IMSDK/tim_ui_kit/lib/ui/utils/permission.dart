// ignore_for_file: unused_import

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

class PermissionRequestInfo extends StatefulWidget {
  final Function removeOverLay;
  final int permissionType;
  final String appName;

  const PermissionRequestInfo(
      {Key? key,
      required this.removeOverLay,
      required this.permissionType,
      required this.appName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PermissionRequestInfo();
}

class _PermissionRequestInfo extends TIMUIKitState<PermissionRequestInfo>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      widget.removeOverLay();
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final permission = {
      1: {
        "name": TIM_t("相机"),
        "icon": "images/chat_permission_icon_camera.png",
        "text": TIM_t("为方便您将所拍摄的照片或视频发送给朋友，以及进行视频通话，请允许我们访问摄像头进行拍摄照片和视频。")
      },
      7: {
        "name": TIM_t("麦克风"),
        "icon": "images/chat_permission_icon_mic.png",
        "text": TIM_t("为方便您发送语音消息、拍摄视频以及音视频通话，请允许我们使用麦克风进行录音。")
      },
      15: {
        "name": TIM_t("存储"),
        "icon": "images/chat_permission_icon_file.png",
        "text": TIM_t("为方便您查看和选择相册里的图片视频发送给朋友，以及保存内容到设备，请允许我们访问您设备上的照片、媒体内容。")
      },
    }[widget.permissionType];
    final option2 = permission?["name"] ?? "";
    return Stack(
      children: [
        Positioned(
          child: SafeArea(
            child: Opacity(
              opacity: 0.7,
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset(
                        permission?["icon"] ?? "",
                        package: "tim_ui_kit",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      TIM_t(widget.appName) +
                          TIM_t_para(" 申请获取{{option2}}", " 申请获取$option2")(
                              option2: option2) +
                          TIM_t("权限"),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      permission?["text"] ?? "",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
          ),
          left: 0,
          right: 0,
          bottom: 0,
          top: 0,
        )
      ],
    );
  }
}

class Permissions {
  static List<String> _names(BuildContext context) {
    return <String>[
      TIM_t("日历"),
      TIM_t("相机"),
      TIM_t("联系人"),
      TIM_t("位置"),
      'locationAlways',
      'locationWhenInUse',
      'mediaLibrary',
      TIM_t("麦克风"),
      'phone',
      TIM_t("照片"),
      TIM_t("相册写入"),
      'reminders',
      'sensors',
      'sms',
      'speech',
      TIM_t("文件"),
      'ignoreBatteryOptimizations',
      'notification',
      'access_media_location',
      'activity_recognition',
      'unknown',
      'bluetooth',
      'manageExternalStorage',
      'systemAlertWindow',
      'requestInstallPackages',
      'appTrackingTransparency',
      'criticalAlerts',
      'accessNotificationPolicy',
      'bluetoothScan',
      'bluetoothAdvertise',
      'bluetoothConnect',
    ];
  }

  static String _permissionText(
      BuildContext context, String appName, int value) {
    final _prefix = TIM_t("需要授予");
    final _postfixList = <String>[
      TIM_t("日历"),
      TIM_t(" 相机权限，以正常使用拍摄图片视频、视频通话等功能。"),
      TIM_t("联系人"),
      TIM_t("位置"),
      'locationAlways',
      'locationWhenInUse',
      'mediaLibrary',
      TIM_t(" 麦克风权限，以正常使用发送语音消息、拍摄视频、音视频通话等功能。"),
      'phone',
      TIM_t(" 访问照片权限，以正常使用发送图片、视频等功能。"),
      TIM_t(" 访问相册写入权限，以正常使用存储图片、视频等功能。"),
      'reminders',
      'sensors',
      'sms',
      'speech',
      TIM_t(" 文件读写权限，以正常使用在聊天功能中的图片查看、选择能力和发送文件的能力。"),
      'ignoreBatteryOptimizations',
      'notification',
      'access_media_location',
      'activity_recognition',
      'unknown',
      'bluetooth',
      'manageExternalStorage',
      'systemAlertWindow',
      'requestInstallPackages',
      'appTrackingTransparency',
      'criticalAlerts',
      'accessNotificationPolicy',
      'bluetoothScan',
      'bluetoothAdvertise',
      'bluetoothConnect',
    ];
    return _prefix + appName + _postfixList[value];
  }

  static Future<bool> checkPermission(BuildContext context, int value) async {
    final status = await Permission.byValue(value).status;
    if (status.isGranted) {
      return true;
    }
    final bool? shouldRequestPermission =
        await showPermissionConfirmDialog(context, value);
    if (shouldRequestPermission != null && shouldRequestPermission) {
      return await Permission.byValue(value).request().isGranted;
    }
    return shouldRequestPermission ?? false;
  }

  static Future<bool> checkPermissionSetBefore(int value) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    final _hasPermissionSetBefore = prefs.getBool("permission$value");
    return _hasPermissionSetBefore ?? false;
  }

  static Future<bool> setLocalPermission(int value) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    return await prefs.setBool("permission$value", true);
  }

  static showPermissionRequestInfoDialog(BuildContext context, value) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    OverlayEntry? _entry;
    final entry = OverlayEntry(builder: (context) {
      return PermissionRequestInfo(
        appName: appName,
        removeOverLay: () => _entry?.remove(),
        permissionType: value,
      );
    });
    _entry = entry;
    Overlay.of(context)?.insert(entry);
  }

  static Future<bool?> showPermissionConfirmDialog(
      BuildContext context, value) async {
    final platformUtils = PlatformUtils();
    // 第一次直接走系统文案
    if (!await checkPermissionSetBefore(value)) {
      await setLocalPermission(value);
      if (platformUtils.isAndroid) {
        showPermissionRequestInfoDialog(context, value);
      }
      return true;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    final option2 = _names(context)[value];
    final permissionText = _permissionText(context, appName, value);
    void closeDialog() {
      Navigator.of(context).pop(false);
    }

    void getPermission() async {
      Navigator.of(context).pop(false);
      openAppSettings();
    }

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return platformUtils.isIOS
            ? CupertinoAlertDialog(
                title: Text("“$appName”" +
                    TIM_t_para(" 想访问您的{{option2}}", " 想访问您的$option2")(
                        option2: option2)),
                content: Text(permissionText),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(TIM_t("以后再说")),
                    onPressed: closeDialog, // 关闭对话框
                  ),
                  CupertinoDialogAction(
                    child: Text(TIM_t("去开启")),
                    onPressed: getPermission,
                  ),
                ],
              )
            : AlertDialog(
                content: Text(permissionText),
                actions: <Widget>[
                  const Divider(),
                  SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: TextButton(
                            child: Text(TIM_t("以后再说"),
                                style: const TextStyle(color: Colors.black)),
                            onPressed: closeDialog, // 关闭对话框
                          ),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          child: TextButton(
                            child: Text(TIM_t("去开启")),
                            onPressed: getPermission,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
      },
    );
  }
}
