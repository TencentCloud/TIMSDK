/// 好友类型
///
/// {@category Enums}
///
// ignore_for_file: constant_identifier_names

class FriendType {
  /// 单向好友
  ///
  static const V2TIM_FRIEND_TYPE_SINGLE = 1;

  /// 互为好友
  ///
  static const V2TIM_FRIEND_TYPE_BOTH = 2;
}

class FriendApplicationType {
  // 同意添加单向好友
  static const V2TIM_FRIEND_ACCEPT_AGREE = 0;
  // 同意并添加为双向好友
  static const V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD = 1;

  // 拒绝好友时使用
  // 别人发给我的加好友请求
  static const V2TIM_FRIEND_APPLICATION_COME_IN = 1;
  //我发给别人的加好友请求
  static const V2TIM_FRIEND_APPLICATION_SEND_OUT = 2;
  // 别人发给我的和我发给别人的加好友请求。仅在拉取时有效。
  static const V2TIM_FRIEND_APPLICATION_BOTH = 3;
}
