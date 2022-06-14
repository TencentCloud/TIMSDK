import 'package:tim_ui_kit_push_plugin/tim_ui_kit_push_plugin.dart';

import '../push_constant.dart';

class ChannelPush{
  static final TimUiKitPushPlugin cPush = TimUiKitPushPlugin(
    isUseGoogleFCM: false,
  );

  static init(PushClickAction pushClickAction) async {
    cPush.init(
        pushClickAction: pushClickAction,
        appInfo: PushConfig.appInfo,
    );

    cPush.createNotificationChannel(channelId: "new_message", channelName: "消息推送", channelDescription: "推送新聊天消息");
    cPush.createNotificationChannel(channelId: "high_system", channelName: "新消息提醒", channelDescription: "推送新聊天消息");
  }

  static requestPermission(){
    cPush.requireNotificationPermission();
  }

  static Future<String> getDeviceToken() async {
    return cPush.getDevicePushToken();
  }
}