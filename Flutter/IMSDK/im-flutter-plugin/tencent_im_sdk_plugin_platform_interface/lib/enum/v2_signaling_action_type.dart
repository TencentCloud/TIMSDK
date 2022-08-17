/// 信令类型
///
/// {@category Enums}
///
// ignore_for_file: constant_identifier_names
/// 
class V2SignalingActionType {
  /// 邀请方发起邀请
  static const int SIGNALING_ACTION_TYPE_INVITE = 1;

  /// 邀请方取消邀请
  static const int SIGNALING_ACTION_TYPE_CANCEL_INVITE = 2;

  /// 被邀请方接受邀请
  static const int SIGNALING_ACTION_TYPE_ACCEPT_INVITE = 3;

  /// 被邀请方拒绝邀请
  static const int SIGNALING_ACTION_TYPE_REJECT_INVITE = 4;

  /// 邀请超时
  static const int SIGNALING_ACTION_TYPE_INVITE_TIMEOUT = 5;
}
