import 'v2_tim_group_member_full_info.dart';

/// V2TimGroupMemberInfoResult
///
/// {@category Models}
///

class V2TimGroupMemberInfoResult {
  late String? nextSeq;
  List<V2TimGroupMemberFullInfo?>? memberInfoList = List.empty(growable: true);

  V2TimGroupMemberInfoResult({
    this.nextSeq,
    this.memberInfoList,
  });

  V2TimGroupMemberInfoResult.fromJson(Map<String, dynamic> json) {
    nextSeq = json['nextSeq'];
    if (json['memberInfoList'] != null) {
      memberInfoList = List.empty(growable: true);
      json['memberInfoList'].forEach((v) {
        memberInfoList!.add(V2TimGroupMemberFullInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nextSeq'] = nextSeq;
    if (memberInfoList != null) {
      data['memberInfoList'] =
          memberInfoList!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}
// {
//   "nextSeq":0,
//   "memberInfoList":[{}]
// }
