// ignore_for_file: constant_identifier_names
import '../i18n/i18n_utils.dart';

class Const {
  // 时间戳消息 前端模拟
  static const int V2TIM_ELEM_TYPE_TIME = 11;
  static const int REQUEST_ERROR_CODE = -9;
  static const int SERVER_ERROR_CODE = -99;
  // 消息滚动的底部 前端模拟
  static const int V2TIM_ELEM_TYPE_REFRESH = -999;
  // 房间消息的底部 （之后没有数据） 前端模拟
  static const int V2TIM_ELEM_TYPE_END = -9999;
  static List weekdayMap = [
    '',
    imt("星期一"),
    imt("星期二"),
    imt("星期三"),
    imt("星期四"),
    imt("星期五"),
    imt("星期六"),
    imt("星期七")
  ];

  static const DAY_SEC = 86400;
  static const HOUR_SEC = 3600;
  static const MIN_SEC = 60;

  static const SEC_SERIES = [HOUR_SEC, MIN_SEC];

  static const V2_TIM_IMAGE_TYPES = {
    'ORIGINAL': 0,
    'BIG': 1,
    'SMALL': 2,
  };
}
