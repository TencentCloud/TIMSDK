import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info.dart';

/// V2TimGroupInfoResult
///
/// {@category Models}
///

class V2TimGroupInfoResult {
  late int? resultCode;
  late String? resultMessage;
  late V2TimGroupInfo? groupInfo;

  V2TimGroupInfoResult({
    this.resultCode,
    this.resultMessage,
    this.groupInfo,
  });

  V2TimGroupInfoResult.fromJson(Map<String, dynamic> json) {
    resultCode = json['resultCode'];
    resultMessage = json['resultMessage'];
    groupInfo = V2TimGroupInfo.fromJson(json['groupInfo']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resultCode'] = resultCode;
    data['resultMessage'] = resultMessage;
    data['groupInfo'] = groupInfo?.toJson();
    return data;
  }
}

// {
//   "resultCode":0,
//   "resultMessage":"",
//   "groupInfo":{}
// }
