import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_info.dart';

/// V2TimFriendInfoResult
///
/// {@category Models}
///

class V2TimFriendInfoResult {
  late int resultCode;
  late String? resultInfo;
  late int? relation;
  V2TimFriendInfo? friendInfo;

  V2TimFriendInfoResult({
    required this.resultCode,
    this.resultInfo,
    this.relation,
    this.friendInfo,
  });

  V2TimFriendInfoResult.fromJson(Map<String, dynamic> json) {
    resultCode = json['resultCode'];
    resultInfo = json['resultInfo'];
    relation = json['relation'];
    friendInfo = json['friendInfo'] != null
        ? V2TimFriendInfo.fromJson(json['friendInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resultCode'] = resultCode;
    data['resultInfo'] = resultInfo;
    data['relation'] = relation;
    if (friendInfo != null) {
      data['friendInfo'] = friendInfo!.toJson();
    }
    return data;
  }
}

// {
//   "resultCode":0,
//   "resultInfo":"",
//   "relation":0,
//   "friendInfo":"_$V2TimFriendInfo"
// }
