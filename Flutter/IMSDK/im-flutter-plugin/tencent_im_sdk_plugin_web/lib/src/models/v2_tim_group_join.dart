import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class V2TimGroupJoin {
  static Object formatParams(Map<String, dynamic> params) {
    final fomatedParams = <String, dynamic>{
      "groupID": params["groupID"],
      "applyMessage": params["message"] ?? "",
      "type": params["groupType"] ?? "",
    };
    return mapToJSObj(fomatedParams);
  }
}
