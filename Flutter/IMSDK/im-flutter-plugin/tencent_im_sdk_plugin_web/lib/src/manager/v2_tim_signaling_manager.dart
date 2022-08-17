import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_signaling_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';
import 'package:uuid/uuid.dart';

class V2TIMSignalingManager {

  ///@nodoc
  Map<String, V2TimSignalingListener> signalingListenerList = {};

  ///添加信令监听
  ///
  Future<void> addSignalingListener({
    required V2TimSignalingListener listener,
  }) {
    final String listenerUuid = const Uuid().v4();
    signalingListenerList[listenerUuid] = listener;
    return Future.value();
  }

  ///移除信令监听
  ///
  Future<void> removeSignalingListener({
    V2TimSignalingListener? listener,
  }) {
    var listenerUuid = "";
    if (listener != null) {
      listenerUuid = signalingListenerList.keys.firstWhere(
          (k) => signalingListenerList[k] == listener,
          orElse: () => "");
      signalingListenerList.remove(listenerUuid);
    } else {
      signalingListenerList.clear();
    }
    return Future.value();
  }

  _sendCustomMessage(){

  }
  _timeout(){

  }
  Future<V2TimValueCallback<String>> invite({
    required String invitee,
    required String data,
    int timeout = 30,
    bool onlineUserOnly = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    // send custom message and handle timeout.
    
    return V2TimValueCallback<String>.fromJson({}
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
      {},
    );
  }

  Future<V2TimCallback> cancel({
    required String inviteID,
    String? data,
  }) async {
    return V2TimCallback.fromJson(
      {}
    );
  }

  Future<V2TimCallback> accept({
    required String inviteID,
    String? data,
  }) async {
    return V2TimCallback.fromJson(
      {}
    );
  }

  Future<V2TimCallback> reject({
    required String inviteID,
    String? data,
  }) async {
    return V2TimCallback.fromJson(
      {}
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
    return V2TimValueCallback<V2TimSignalingInfo>.fromJson(
     {}
    );
  }

  Future<V2TimCallback> addInvitedSignaling({
    required V2TimSignalingInfo info,
  }) async {
    return V2TimCallback.fromJson(
      {}
    );
  }
}