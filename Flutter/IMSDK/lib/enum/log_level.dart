/// 日志等级
///
/// {@category Enums}
///
class LogLevel {
  ///不输出任何 sdk log
  ///
  static const int V2TIM_LOG_NONE = 0;

  ///输出 DEBUG，INFO，WARNING，ERROR 级别的 log
  static const int V2TIM_LOG_DEBUG = 3;

  ///输出 INFO，WARNING，ERROR 级别的 log
  ///
  static const int V2TIM_LOG_INFO = 4;

  ///输出 WARNING，ERROR 级别的 log
  ///
  static const int V2TIM_LOG_WARN = 5;

  ///输出 ERROR 级别的 log
  static const int V2TIM_LOG_ERROR = 6;
}
