import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class DeleteGroupAttributes {
  static formateParams(Map<String, dynamic> params) =>
      mapToJSObj({'groupID': params['groupID'], 'keyList': params['keys']});
}
