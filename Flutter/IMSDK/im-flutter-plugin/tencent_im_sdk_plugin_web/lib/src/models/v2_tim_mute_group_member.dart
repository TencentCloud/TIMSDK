import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class MuteGroupMember {
  static Object formatParams(Map<String, dynamic> params) => mapToJSObj({
        'groupID': params['groupID'],
        'userID': params['userID'],
        'muteTime': params['seconds']
      });
}
