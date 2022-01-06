import 'v2_tim_group_change_info.dart';
import 'v2_tim_group_member_change_info.dart';
import 'v2_tim_group_member_info.dart';

/// V2TimGroupTipsElem
///
/// {@category Models}
///
class V2TimGroupTipsElem {
  late String groupID;
  late int type;
  late V2TimGroupMemberInfo opMember;
  List<V2TimGroupMemberInfo?>? memberList = List.empty(growable: true);
  List<V2TimGroupChangeInfo?>? groupChangeInfoList = List.empty(growable: true);
  List<V2TimGroupMemberChangeInfo?>? memberChangeInfoList =
      List.empty(growable: true);
  late int? memberCount;

  V2TimGroupTipsElem({
    required this.groupID,
    required this.type,
    required this.opMember,
    this.memberList,
    this.groupChangeInfoList,
    this.memberChangeInfoList,
    this.memberCount,
  });

  V2TimGroupTipsElem.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    type = json['type'];
    opMember = V2TimGroupMemberInfo.fromJson(json['opMember']);
    if (json['memberList'] != null) {
      memberList = List.empty(growable: true);
      json['memberList'].forEach((v) {
        memberList!.add(V2TimGroupMemberInfo.fromJson(v));
      });
    }
    if (json['groupChangeInfoList'] != null) {
      groupChangeInfoList = List.empty(growable: true);
      json['groupChangeInfoList'].forEach((v) {
        groupChangeInfoList!.add(V2TimGroupChangeInfo.fromJson(v));
      });
    }
    if (json['memberChangeInfoList'] != null) {
      memberChangeInfoList = List.empty(growable: true);
      json['memberChangeInfoList'].forEach((v) {
        memberChangeInfoList!.add(V2TimGroupMemberChangeInfo.fromJson(v));
      });
    }
    memberCount = json['memberCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupID'] = groupID;
    data['type'] = type;
    data['opMember'] = opMember.toJson();
    if (memberList != null) {
      data['memberList'] = memberList!.map((v) => v!.toJson()).toList();
    }
    if (groupChangeInfoList != null) {
      data['groupChangeInfoList'] =
          groupChangeInfoList!.map((v) => v!.toJson()).toList();
    }
    if (memberChangeInfoList != null) {
      data['memberChangeInfoList'] =
          memberChangeInfoList!.map((v) => v!.toJson()).toList();
    }
    data['memberCount'] = memberCount;
    return data;
  }
}
// {
//   "groupID":"",
//   "type":0,
//   "opMember":{},
//   "memberList":[{}],
//   "groupChangeInfoList":[{}],
//   "memberChangeInfoList":[{}],
//   "memberCount":0
// }
