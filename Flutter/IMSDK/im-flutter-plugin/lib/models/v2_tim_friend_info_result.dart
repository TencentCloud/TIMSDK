import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';

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
        ? new V2TimFriendInfo.fromJson(json['friendInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['resultCode'] = this.resultCode;
    data['resultInfo'] = this.resultInfo;
    data['relation'] = this.relation;
    if (this.friendInfo != null) {
      data['friendInfo'] = this.friendInfo!.toJson();
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
