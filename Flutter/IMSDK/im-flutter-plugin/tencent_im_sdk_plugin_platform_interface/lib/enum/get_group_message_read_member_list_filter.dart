/// 获取群消息已读（未读）成员列表type
///
/// {@category Enums}
///
// ignore_for_file: constant_identifier_names

enum GetGroupMessageReadMemberListFilter {
  ///禁止加群
  ///
  V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ,

  ///需要管理员审批
  ///
  V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_UNREAD,
}
