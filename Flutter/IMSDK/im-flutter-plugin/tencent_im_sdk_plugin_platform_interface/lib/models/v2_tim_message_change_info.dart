import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';

/// V2TimMessageChangeInfo
///
/// {@category Models}
///
class V2TimMessageChangeInfo {
  int? code;
  String? desc;
  V2TimMessage? message;

  V2TimMessageChangeInfo({
    this.code,
    this.desc,
    this.message,
  });

  V2TimMessageChangeInfo.fromJson(Map<String, dynamic> json) {
   code = json["code"];
   desc = json["desc"];
   if(json["message"]!=null){
     message = V2TimMessage.fromJson(json["message"]);
   }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["code"] = code;
    data["desc"] = desc;
    if(message!=null){
      data["message"] = message!.toJson();
    }
    return data;
  }
}