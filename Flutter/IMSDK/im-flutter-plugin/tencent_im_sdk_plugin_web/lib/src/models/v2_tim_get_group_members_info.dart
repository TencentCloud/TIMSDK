import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class GetGroupMembersInfo {
  static Object formatParams(Map<String, dynamic> params) => mapToJSObj(
      {'groupID': params['groupID'], 'userIDList': params['memberList']});
}
