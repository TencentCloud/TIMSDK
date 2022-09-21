import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit_push_plugin/tim_ui_kit_push_plugin.dart';
import 'package:timuikit/utils/push/push_constant.dart';

class ChannelPush {
  static final TimUiKitPushPlugin cPush = TimUiKitPushPlugin(
    isUseGoogleFCM: false,
  );

  static init(PushClickAction pushClickAction) async {
    await cPush.init(
      pushClickAction: pushClickAction,
      appInfo: PushConfig.appInfo,
    );

    cPush.createNotificationChannel(
        channelId: "new_message",
        channelName: "消息推送",
        channelDescription: "推送新聊天消息");
    cPush.createNotificationChannel(
        channelId: "high_system",
        channelName: "新消息提醒",
        channelDescription: "推送新聊天消息");
    return;
  }

  static requestPermission() {
    cPush.requireNotificationPermission();
  }

  static Future<String> getDeviceToken() async {
    return cPush.getDevicePushToken();
  }

  static setBadgeNum(int badgeNum) {
    return cPush.setBadgeNum(badgeNum);
  }

  static clearAllNotification() {
    return cPush.clearAllNotification();
  }

  static Future<bool> uploadToken(PushAppInfo appInfo) async {
    return cPush.uploadToken(appInfo);
  }

  static displayNotification(String title, String body, [String? ext]) {
    cPush.displayNotification(
        channelID: "new_message",
        channelName: "消息推送",
        title: title,
        body: body,
        ext: ext);
  }

  static displayDefaultNotificationForMessage(V2TimMessage message) {
    cPush.displayDefaultNotificationForMessage(
        message: message, channelID: "new_message", channelName: "消息推送");
  }
}
