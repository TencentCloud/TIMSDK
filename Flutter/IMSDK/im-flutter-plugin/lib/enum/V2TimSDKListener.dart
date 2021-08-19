import 'package:tencent_im_sdk_plugin/enum/callbacks.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

class V2TimSDKListener {
  VoidCallback onConnecting = () {};
  VoidCallback onConnectSuccess = () {};
  ErrorCallback onConnectFailed = (int code, String error) {};
  VoidCallback onKickedOffline = () {};
  VoidCallback onUserSigExpired = () {};
  V2TimUserFullInfoCallback onSelfInfoUpdated = (
    V2TimUserFullInfo info,
  ) {};

  V2TimSDKListener({
    ErrorCallback? onConnectFailed,
    VoidCallback? onConnectSuccess,
    VoidCallback? onConnecting,
    VoidCallback? onKickedOffline,
    V2TimUserFullInfoCallback? onSelfInfoUpdated,
    VoidCallback? onUserSigExpired,
  }) {
    if (onConnectFailed != null) {
      this.onConnectFailed = onConnectFailed;
    }
    if (onConnectSuccess != null) {
      this.onConnectSuccess = onConnectSuccess;
    }
    if (onConnecting != null) {
      this.onConnecting = onConnecting;
    }
    if (onKickedOffline != null) {
      this.onKickedOffline = onKickedOffline;
    }
    if (onSelfInfoUpdated != null) {
      this.onSelfInfoUpdated = onSelfInfoUpdated;
    }
    if (onUserSigExpired != null) {
      this.onUserSigExpired = onUserSigExpired;
    }
  }
}
