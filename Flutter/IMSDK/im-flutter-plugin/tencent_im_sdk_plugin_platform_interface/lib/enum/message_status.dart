/// 消息状态
///
/// {@category Enums}
///
class MessageStatus {
  ///消息发送中
  ///
  static const int V2TIM_MSG_STATUS_SENDING = 1;

  ///消息发送成功
  ///
  static const int V2TIM_MSG_STATUS_SEND_SUCC = 2;

  ///消息发送失败
  ///
  static const int V2TIM_MSG_STATUS_SEND_FAIL = 3;

  ///消息被删除
  ///
  static const int V2TIM_MSG_STATUS_HAS_DELETED = 4;

  ///被撤销的消息
  ///
  static const int V2TIM_MSG_STATUS_LOCAL_REVOKED = 6;
}
