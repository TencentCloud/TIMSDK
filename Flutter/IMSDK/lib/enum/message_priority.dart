/// 消息优先级
///
/// {@category Enums}
///
class MessagePriority {
  ///默认为普通优先级
  ///
  static const int V2TIM_PRIORITY_DEFAULT = 0;

  ///高优先级，一般用于礼物等重要消息
  ///
  static const int V2TIM_PRIORITY_HIGH = 1;

  ///普通优先级，一般用于普通消息
  ///
  static const int V2TIM_PRIORITY_NORMAL = 2;

  ///低优先级，一般用于点赞消息
  ///
  static const int V2TIM_PRIORITY_LOW = 3;
}
