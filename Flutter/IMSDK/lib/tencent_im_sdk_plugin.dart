import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:flutter/services.dart';

///TencentImSDKPlugin入口
///
class TencentImSDKPlugin {
  static const MethodChannel _channel =
      const MethodChannel('tencent_im_sdk_plugin');
  static V2TIMManager v2TIMManager = new V2TIMManager(_channel);
}
