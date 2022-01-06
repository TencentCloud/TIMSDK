import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class InviteUserToGroup {
  static Object formatParams(Map<String, dynamic> params) => mapToJSObj({
        'groupID': params['groupID'],
        'userIDList': params['userList'],
      });

  static formatResult(Map<String, dynamic> params) {
    final userList = params['successUserIDList'] as List;
    return userList.map((e) => {'memberID': e, 'result': 1}).toList();
  }
}
