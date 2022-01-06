import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

// 需要传递object时可以直接使用这种形式创建 对应博客：https://stackoverflow.com/questions/33394867/passing-dart-objects-to-js-functions-in-js-interop
// @anonymous
// @JS()
// class PinConversationParams {
//   external String get conversationID;
//   external set conversationID(String value);

//   external int get count;
//   external set count(int value);
// }

class PinConversation {
  late String conversationID;
  late int isPinned;

  PinConversation(
    this.conversationID,
    this.isPinned,
  );

  static formateParams(Map<String, dynamic> data) {
    Map<String, dynamic> params = new Map<String, dynamic>();
    params["conversationID"] = data["conversationID"];
    params["isPinned"] = data["isPinned"];

    return mapToJSObj(params);
  }

  static formateResult() {}
}
