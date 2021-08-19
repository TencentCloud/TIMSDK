/// 获取历史消息类型
///
/// {@category Enums}
///
class HistoryMessageGetType {
  ///获取云端更老的消息
  ///
  static const V2TIM_GET_CLOUD_OLDER_MSG = 1;

  ///获取云端更新的消息
  ///
  static const V2TIM_GET_CLOUD_NEWER_MSG = 2;

  ///获取本地更老的消息
  ///
  static const V2TIM_GET_LOCAL_OLDER_MSG = 3;

  ///获取本地更新的消息
  ///
  static const V2TIM_GET_LOCAL_NEWER_MSG = 4;
}
