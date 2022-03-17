enum FriendApplicationTypeEnum {
  V2TIM_FRIEND_APPLICATION_NULL, // dart 不支持枚举初始值，所以这里加一个null
  // 别人发给我的加好友请求
  V2TIM_FRIEND_APPLICATION_COME_IN,
  //我发给别人的加好友请求
  V2TIM_FRIEND_APPLICATION_SEND_OUT,
  // 别人发给我的和我发给别人的加好友请求。仅在拉取时有效。
  V2TIM_FRIEND_APPLICATION_BOTH,
}
