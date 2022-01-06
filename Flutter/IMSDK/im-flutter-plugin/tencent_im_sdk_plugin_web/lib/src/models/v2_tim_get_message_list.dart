import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

// 需要传递object时可以直接使用这种形式创建 对应博客：https://stackoverflow.com/questions/33394867/passing-dart-objects-to-js-functions-in-js-interop
@anonymous
@JS()
class GetMessageListParams {
  external String get conversationID;
  external set conversationID(String value);

  external int get count;
  external set count(int value);
}

class GetMessageList {
  late String conversationID;
  late int count;

  static formateParams(Map<String, dynamic> data) {
    Map<String, dynamic> params = Map<String, dynamic>();
    final groupID = data['groupID'] ?? '';
    final userID = data['userID'] ?? '';
    final convType = groupID != '' ? 'GROUP' : 'C2C';
    final sendToUserID = convType == 'GROUP' ? groupID : userID;
    final haveTwoValues = groupID != '' && userID != '';
    if (haveTwoValues) {
      return null;
    }

    params["conversationID"] = convType + sendToUserID;
    params["count"] = data["count"];
    params["nextReqMessageID"] = data["lastMsgID"];

    return mapToJSObj(params);
  }
}
