import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';

/// 提供离线推送相关的接口
///
/// [setOfflinePushConfig]设置离线推送配置信息
///
/// [doBackground]APP 检测到应用退后台时可以调用此接口，可以用作桌面应用角标的初始化未读数量
///
/// [doForeground]APP 检测到应用进前台时可以调用此接口
///
/// {@category Manager}
///
class V2TIMOfflinePushManager {
  ///@nodoc
  late MethodChannel _channel;

  ///@nodoc
  V2TIMOfflinePushManager(channel) {
    _channel = channel;
  }

  ///   设置离线推送配置信息
  ///
  /// 参数
  ///
  /// ```
  /// config	离线推送配置
  /// callback	回调
  /// isTPNSToken 是否使用tpnstoken
  /// ```
  ///
  Future<V2TimCallback> setOfflinePushConfig({
    required double businessID,
    required String token,
    bool isTPNSToken = false,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          Platform.isIOS ? "setAPNS" : "setOfflinePushConfig",
          buildParam(
            {
              "businessID": businessID,
              "token": token,
              "isTPNSToken": isTPNSToken,
            },
          ),
        ),
      ),
    );
  }

  /// APP 检测到应用退后台时可以调用此接口，可以用作桌面应用角标的初始化未读数量。
  ///
  /// ```
  /// 从5.0.1（native）版本开始，如果配置了离线推送，会收到厂商的离线推送通道下发的通知栏消息。
  /// ```
  ///
  /// 参数
  ///
  /// ```
  /// unreadCount	未读数量
  /// callback	回调
  /// ```
  Future<V2TimCallback> doBackground({
    required int unreadCount,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "doBackground",
          buildParam(
            {
              "unreadCount": unreadCount,
            },
          ),
        ),
      ),
    );
  }

  /// APP 检测到应用进前台时可以调用此接口
  ///
  /// ```
  /// 从5.0.1（native）版本开始，对应 doBackground，会停止厂商的离线推送。但如果应用被 kill，仍然可以正常接收离线推送。
  /// ```
  ///
  /// 参数
  ///
  /// ```
  /// callback	回调
  /// ```
  Future<V2TimCallback> doForeground() async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "doForeground",
          buildParam(
            {},
          ),
        ),
      ),
    );
  }

  ///@nodoc
  Map buildParam(Map param) {
    param["TIMManagerName"] = "offlinePushManager";
    return param;
  }

  ///@nodoc
  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
}
