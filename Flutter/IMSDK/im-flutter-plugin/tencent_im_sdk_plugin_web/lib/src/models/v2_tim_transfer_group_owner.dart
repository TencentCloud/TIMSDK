import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

final groupMemberRoleMapping = {"Owner": 400, "Admin": 300, "Member": 200};

class TransferGroupOwner {
  static Object formatParams(Map<String, dynamic> params) => mapToJSObj(
      {'groupID': params['groupID'], 'newOwnerID': params['userID']});
}
