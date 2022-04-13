import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';

class Permissions {
  static List<String> _names(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    return <String>[
      ttBuild.imt("日历"),
      ttBuild.imt("相机"),
      ttBuild.imt("联系人"),
      ttBuild.imt("位置"),
      'locationAlways',
      'locationWhenInUse',
      'mediaLibrary',
      ttBuild.imt("麦克风"),
      'phone',
      ttBuild.imt("相册"),
      ttBuild.imt("相册写入"),
      'reminders',
      'sensors',
      'sms',
      'speech',
      ttBuild.imt("本地存储"),
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

  static Future<bool> checkPermission(BuildContext context, int value) async {
    if (await Permission.byValue(value).request().isGranted) {
      return true;
    }
    showPermissionConfirmDialog(context, value);
    return false;
  }

  static Future<bool?> showPermissionConfirmDialog(
      BuildContext context, value) async {
    final I18nUtils ttBuild = I18nUtils(context);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    final yoursItem = _names(context)[value];
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return ChangeNotifierProvider.value(
            value: serviceLocator<TUIThemeViewModel>(),
            child: Consumer<TUIThemeViewModel>(
              builder: (context, tuiTheme, child) => CupertinoAlertDialog(
                title: Text(appName +
                    ttBuild.imt_para("想访问您的{{yoursItem}}", "想访问您的$yoursItem")(
                        yoursItem: yoursItem)),
                content: Text(ttBuild.imt("我们需要您的同意才能获取信息")),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(ttBuild.imt("不允许"),
                        style: TextStyle(color: tuiTheme.theme.primaryColor)),
                    onPressed: () => Navigator.of(context).pop(), // 关闭对话框
                  ),
                  CupertinoDialogAction(
                    child: Text(ttBuild.imt("好"),
                        style: TextStyle(color: tuiTheme.theme.secondaryColor)),
                    onPressed: () {
                      //关闭对话框并返回true
                      Navigator.of(context).pop();
                      openAppSettings();
                    },
                  ),
                ],
              ),
            ));
      },
    );
  }
}
