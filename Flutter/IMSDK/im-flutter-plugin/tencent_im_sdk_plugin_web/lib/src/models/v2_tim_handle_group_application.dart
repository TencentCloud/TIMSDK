import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class HandleGroupApplication {
  static formateParams(Map<String, dynamic> params, String type) => mapToJSObj({
        'handleAction': type,
        'handleMessage': params['reason'],
        'message': parse(params['webMessageInstance'])
      });
}
