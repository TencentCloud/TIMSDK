import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';

/// 提供了信令操作相关接口
///
///[addSignalingListener]添加信令监听
///
///[removeSignalingListener]移除信令监听
///
///[invite]邀请某个人
///
///[inviteInGroup]邀请群内的某些人
///
///[cancel]邀请方取消邀请
///
///[accept]接收方接收邀请
///
///[reject]接收方拒绝邀请
///
/// {@category Manager}
///
class V2TIMSignalingManager {
  ///@nodoc
  late MethodChannel _channel;

  ///@nodoc
  V2TIMSignalingManager(channel) {
    _channel = channel;
  }

  ///@nodoc
  V2TimSignalingListener signalingListener = new V2TimSignalingListener();

  ///添加信令监听
  ///
  void addSignalingListener({
    required V2TimSignalingListener listener,
  }) {
    this.signalingListener = listener;
    _channel.invokeMethod("addSignalingListener", buildParam({}));
  }

  ///移除信令监听
  ///
  void removeSignalingListener({
    required Function listener,
  }) {
    _channel.invokeMethod("removeSignalingListener", buildParam({}));
  }

  Future<V2TimValueCallback<String>> invite({
    required String invitee,
    required String data,
    int timeout = 30,
    bool onlineUserOnly = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "invite",
          buildParam(
            {
              "invitee": invitee,
              "data": data,
              "timeout": timeout,
              "onlineUserOnly": onlineUserOnly,
              "offlinePushInfo": offlinePushInfo?.toJson()
            },
          ),
        ),
      ),
    );
  }

  Future<V2TimValueCallback<String>> inviteInGroup({
    required String groupID,
    required List<String> inviteeList,
    required String data,
    int timeout = 30,
    bool onlineUserOnly = false,
  }) async {
    return V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "inviteInGroup",
          buildParam(
            {
              "groupID": groupID,
              "inviteeList": inviteeList,
              "data": data,
              "timeout": timeout,
              "onlineUserOnly": onlineUserOnly,
            },
          ),
        ),
      ),
    );
  }

  Future<V2TimCallback> cancel({
    required String inviteID,
    String? data,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "cancel",
          buildParam(
            {
              "inviteID": inviteID,
              "data": data,
            },
          ),
        ),
      ),
    );
  }

  Future<V2TimCallback> accept({
    required String inviteID,
    String? data,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "accept",
          buildParam(
            {
              "inviteID": inviteID,
              "data": data,
            },
          ),
        ),
      ),
    );
  }

  Future<V2TimCallback> reject({
    required String inviteID,
    String? data,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "reject",
          buildParam(
            {
              "inviteID": inviteID,
              "data": data,
            },
          ),
        ),
      ),
    );
  }

  ///@nodoc
  Map buildParam(Map param) {
    param["TIMManagerName"] = "signalingManager";
    return param;
  }

  ///@nodoc
  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
}
