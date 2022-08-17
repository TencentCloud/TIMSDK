

 import 'package:tencent_im_sdk_plugin_platform_interface/utils/const.dart';

class Utils {
  ///@nodoc
  ///
  static List<int> getAbility(){
    String t = StackTrace.current.toString();
    List<int> ab = List.empty(growable: true);
    TencentIMSDKCONST.scenes.keys.forEach((element) {
      if(t.contains(element)){
        if(TencentIMSDKCONST.scenes.keys.contains(element)){
          ab.add(TencentIMSDKCONST.scenes[element]!);
        }
      }
    });
    return ab;
  }
}