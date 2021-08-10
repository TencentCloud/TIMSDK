import 'v2_tim_user_full_info.dart';

/// V2TimFriendInfo
///
/// {@category Models}
///
class V2TimFriendInfo {
  late String userID;
  late String? friendRemark;
  List<String>? friendGroups = List.empty(growable: true);
  Map<String, String>? friendCustomInfo;
  V2TimUserFullInfo? userProfile;

  V2TimFriendInfo({
    required this.userID,
    this.friendRemark,
    this.friendGroups,
    this.friendCustomInfo,
    this.userProfile,
  });

  V2TimFriendInfo.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    friendRemark = json['friendRemark'];
    friendGroups = json['friendGroups'].cast<String>();
    friendCustomInfo = json['friendCustomInfo'] == null
        ? new Map<String, String>()
        : Map<String, String>.from(json['friendCustomInfo']);
    userProfile = json['userProfile'] != null
        ? new V2TimUserFullInfo.fromJson(json['userProfile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['friendRemark'] = this.friendRemark;
    data['friendGroups'] = this.friendGroups;
    data['friendCustomInfo'] = this.friendCustomInfo;
    if (this.userProfile != null) {
      data['userProfile'] = this.userProfile!.toJson();
    }
    return data;
  }
}
// {
//   "userID":"",
//   "friendRemark":"",
//   "friendGroups":[""],
//   "friendCustomInfo":{},
//   "userProfile":{}
// }
