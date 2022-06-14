import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_application.dart';

/// V2TimFriendApplicationResult
///
/// {@category Models}
///
class V2TimFriendApplicationResult {
  late int? unreadCount;
  late List<V2TimFriendApplication?>? friendApplicationList =
      List.empty(growable: true);

  V2TimFriendApplicationResult({
    this.unreadCount,
    this.friendApplicationList,
  });

  V2TimFriendApplicationResult.fromJson(Map<String, dynamic> json) {
    unreadCount = json['unreadCount'];
    if (json['friendApplicationList'] != null) {
      json['friendApplicationList'].forEach((v) {
        friendApplicationList!.add(V2TimFriendApplication.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unreadCount'] = unreadCount;
    data['friendApplicationList'] =
        friendApplicationList!.map((v) => v!.toJson()).toList();
    return data;
  }
}
// {
//   "unreadCount":0,
//   "friendApplicationList":{},
// }
