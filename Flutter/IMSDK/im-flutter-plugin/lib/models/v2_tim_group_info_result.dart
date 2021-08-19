import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';

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
    groupInfo = new V2TimGroupInfo.fromJson(json['groupInfo']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['resultCode'] = this.resultCode;
    data['resultMessage'] = this.resultMessage;
    data['groupInfo'] = this.groupInfo?.toJson();
    return data;
  }
}

// {
//   "resultCode":0,
//   "resultMessage":"",
//   "groupInfo":{}
// }
