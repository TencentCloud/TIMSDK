import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class SetGroupAttributes {
  static foramteParams(Map<String, dynamic> params) => mapToJSObj({
        'groupID': params['groupID'],
        'groupAttributes': mapToJSObj(params['attributes'])
      });
}
