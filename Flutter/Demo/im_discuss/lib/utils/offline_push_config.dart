import 'package:discuss/utils/toast.dart';
import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';

class OfflinePush {
  static final XgFlutterPlugin tpush = XgFlutterPlugin();
  static String deviceToken = "";
  static init() {
    tpush.setEnableDebug(
      !(const bool.fromEnvironment('ISPRODUCT_ENV', defaultValue: false)),
    );
    tpush.addEventHandler(
      onRegisteredDeviceToken: (String msg) async {
        deviceToken = msg;
      },
      onRegisteredDone: (String msg) async {},
      unRegistered: (String msg) async {},
      onReceiveNotificationResponse: (Map<String, dynamic> msg) async {},
      onReceiveMessage: (Map<String, dynamic> msg) async {},
      xgPushDidSetBadge: (String msg) async {},
      xgPushDidBindWithIdentifier: (String msg) async {},
      xgPushDidUnbindWithIdentifier: (String msg) async {},
      xgPushDidUpdatedBindedIdentifier: (String msg) async {},
      xgPushDidClearAllIdentifiers: (String msg) async {},
      xgPushClickAction: (Map<String, dynamic> msg) async {},
    );
    tpush.startXg("1600015942", "IRCJESPU71W3");
  }

  static Future<String> getDeviceToken() async {
    String token = "";
    try {
      token = await XgFlutterPlugin.xgApi.getOtherPushToken();
    } catch (err) {
      Utils.log("getDeviceToken err $err");
    }
    return token;
  }
}
