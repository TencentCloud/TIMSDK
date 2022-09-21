import 'dart:js';
import 'package:js/js_util.dart';

class TUIKitWebSupport {
  static void addSetterToWindow() {}
  static void addIdentifierToWindow() {
    // var object = newObject();
    // setProperty(object, "platform", "flutter_uikit");
    context['tencent_cloud_im_csig_flutter_for_web_25F_cy'] =
        "flutter_web_uikit";
  }
}
