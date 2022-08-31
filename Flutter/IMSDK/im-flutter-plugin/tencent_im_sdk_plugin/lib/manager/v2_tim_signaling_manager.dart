// ignore_for_file: unused_field

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_signaling_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/im_flutter_plugin_platform_interface.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/utils/utils.dart';
import 'package:uuid/uuid.dart';

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
  Map<String, V2TimSignalingListener> signalingListenerList = {};

  ///添加信令监听
  ///
  Future<void> addSignalingListener({
    required V2TimSignalingListener listener,
  }) {
    final String listenerUuid = Uuid().v4();
    this.signalingListenerList[listenerUuid] = listener;
    return ImFlutterPlatform.instance.addSignalingListener(
      listenerUuid: listenerUuid,
      listener: listener,
    );
  }

  ///移除信令监听
  ///
  Future<void> removeSignalingListener({
    V2TimSignalingListener? listener,
  }) {
    var listenerUuid = "";
    if (listener != null) {
      listenerUuid = this.signalingListenerList.keys.firstWhere(
          (k) => this.signalingListenerList[k] == listener,
          orElse: () => "");
      this.signalingListenerList.remove(listenerUuid);
    } else {
      this.signalingListenerList.clear();
    }
    return ImFlutterPlatform.instance
        .removeSignalingListener(listenerUuid: listenerUuid);
  }

  Future<V2TimValueCallback<String>> invite({
    required String invitee,
    required String data,
    int timeout = 30,
    bool onlineUserOnly = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return ImFlutterPlatform.instance.invite(
        invitee: invitee,
        data: data,
        timeout: timeout,
        onlineUserOnly: onlineUserOnly,
        offlinePushInfo: offlinePushInfo);
  }

  Future<V2TimValueCallback<String>> inviteInGroup({
    required String groupID,
    required List<String> inviteeList,
    required String data,
    int timeout = 30,
    bool onlineUserOnly = false,
  }) async {
    return ImFlutterPlatform.instance.inviteInGroup(
        groupID: groupID,
        inviteeList: inviteeList,
        data: data,
        timeout: timeout,
        onlineUserOnly: onlineUserOnly);
  }

  Future<V2TimCallback> cancel({
    required String inviteID,
    String? data,
  }) async {
    return ImFlutterPlatform.instance.cancel(
      inviteID: inviteID,
      data: data,
    );
  }

  Future<V2TimCallback> accept({
    required String inviteID,
    String? data,
  }) async {
    return ImFlutterPlatform.instance.accept(
      inviteID: inviteID,
      data: data,
    );
  }

  Future<V2TimCallback> reject({
    required String inviteID,
    String? data,
  }) async {
    return ImFlutterPlatform.instance.reject(
      inviteID: inviteID,
      data: data,
    );
  }

  /// 获取信令信息
  ///
  /// 如果 invite 设置 onlineUserOnly 为 false，每次信令操作（包括 invite、cancel、accept、reject、timeout）都会产生一条自定义消息， 该消息会通过 V2TIMAdvancedMsgListener -> onRecvNewMessage 抛给用户，用户也可以通过历史消息拉取，如果需要根据信令信息做自定义化文本展示，可以调用下面接口获取信令信息。
  ///
  /// 参数
  /// msg	消息对象
  ///
  /// 返回
  /// V2TIMSignalingInfo 信令信息，如果为 null，则 msg 不是一条信令消息。
  ///
  Future<V2TimValueCallback<V2TimSignalingInfo>> getSignalingInfo({
    required String msgID,
  }) async {
    return ImFlutterPlatform.instance.getSignalingInfo(
      msgID: msgID,
    );
  }

  Future<V2TimCallback> addInvitedSignaling({
    required V2TimSignalingInfo info,
  }) async {
    return ImFlutterPlatform.instance.addInvitedSignaling(
      info: info,
    );
  }

  ///@nodoc
  Map buildParam(Map param) {
    param["TIMManagerName"] = "signalingManager";
    try {
      param["ability"] = Utils.getAbility();
    } catch (err) {}
    return param;
  }

  ///@nodoc
  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
}
