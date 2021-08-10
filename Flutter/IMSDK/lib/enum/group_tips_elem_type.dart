/// 群通知消息类型
///
/// {@category Enums}
///
class GroupTipsElemType {
  ///非法
  ///
  static const int GROUP_TIPS_TYPE_INVALID = 0;

  ///主动入群（memberList 加入群组，非 Work 群有效）
  ///
  static const int V2TIM_GROUP_TIPS_TYPE_JOIN = 1;

  ///被邀请入群（opMember 邀请 memberList 入群，Work 群有效）
  ///
  static const int V2TIM_GROUP_TIPS_TYPE_INVITE = 2;

  ///退出群组
  ///
  static const int V2TIM_GROUP_TIPS_TYPE_QUIT = 3;

  ///踢出群 (opMember 把 memberList 踢出群组)
  ///
  static const int V2TIM_GROUP_TIPS_TYPE_KICKED = 4;

  ///设置管理员 (opMember 把 memberList 设置为管理员)
  ///
  static const int V2TIM_GROUP_TIPS_TYPE_SET_ADMIN = 5;

  ///取消管理员 (opMember 取消 memberList 管理员身份)
  ///
  static const int V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN = 6;

  ///群资料变更 (opMember 修改群资料：groupName & introduction & notification & faceUrl & owner & custom)
  ///
  static const int V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE = 7;

  ///群成员资料变更 (opMember 修改群成员资料：muteTime)
  ///
  static const int V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE = 8;
}
