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
        memberInfoList!.add(new V2TimGroupMemberFullInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nextSeq'] = this.nextSeq;
    if (this.memberInfoList != null) {
      data['memberInfoList'] =
          this.memberInfoList!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}
// {
//   "nextSeq":0,
//   "memberInfoList":[{}]
// }
