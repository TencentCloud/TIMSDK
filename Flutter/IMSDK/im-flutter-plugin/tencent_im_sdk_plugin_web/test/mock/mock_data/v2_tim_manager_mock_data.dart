// ignore_for_file: unused_import

/* 不能直接使用native中定义的那些数据类型,web SDK返回的消息是有很大区别的 */
import '../utils.dart';

class V2TimManagerMockData {
  // login
  static const Map<String, String> loginMockParams = {
    "userID": "hexingcheng",
    "userSig": "he sir always 996"
  };

  static const Map<String, dynamic> loginMockRsultSuccMap = {
    "code": 0,
    "desc": "login success"
  };

  static const Map<String, dynamic> loginMockRsultFailMap = {
    "code": 0,
    "desc": "login failed"
  };
}
