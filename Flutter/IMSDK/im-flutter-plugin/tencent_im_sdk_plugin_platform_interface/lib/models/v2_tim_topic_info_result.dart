
import 'package:tencent_im_sdk_plugin_platform_interface/models/V2_tim_topic_info.dart';

/// V2TIMTopicInfoResult
///
/// {@category Models}
///
class V2TimTopicInfoResult {
  int? errorCode;
  String? errorMessage;
  V2TimTopicInfo? topicInfo;


  V2TimTopicInfoResult({
    this.errorCode,
    this.errorMessage,
    this.topicInfo,
  });

  V2TimTopicInfoResult.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    if(json['topicInfo']!=null){
      topicInfo = V2TimTopicInfo.fromJson(json['topicInfo']);
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["topicInfo"] = topicInfo?.toJson();
    return data;
  }
}