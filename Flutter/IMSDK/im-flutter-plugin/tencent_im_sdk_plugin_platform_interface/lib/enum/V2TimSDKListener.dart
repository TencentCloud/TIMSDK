// ignore_for_file: prefer_function_declarations_over_variables, file_names

import 'package:tencent_im_sdk_plugin_platform_interface/enum/callbacks.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_status.dart';


class V2TimSDKListener {
  VoidCallback onConnecting = () {};
  VoidCallback onConnectSuccess = () {};
  ErrorCallback onConnectFailed = (int code, String error) {};
  VoidCallback onKickedOffline = () {};
  VoidCallback onUserSigExpired = () {};
  V2TimUserFullInfoCallback onSelfInfoUpdated = (
    V2TimUserFullInfo info,
  ) {};
  OnUserStatusChanged onUserStatusChanged = (List<V2TimUserStatus> userStatusList){};

  V2TimSDKListener({
    ErrorCallback? onConnectFailed,
    VoidCallback? onConnectSuccess,
    VoidCallback? onConnecting,
    VoidCallback? onKickedOffline,
    V2TimUserFullInfoCallback? onSelfInfoUpdated,
    VoidCallback? onUserSigExpired,
    OnUserStatusChanged? onUserStatusChanged,
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
    if(onUserStatusChanged!=null){
      this.onUserStatusChanged = onUserStatusChanged;
    }
  }
}
