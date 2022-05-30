import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info.dart';

class V2TimGroupMessageReadMemberList {
  late int nextSeq;
  late bool isFinished;
  late List<V2TimGroupMemberInfo> memberInfoList;

  V2TimGroupMessageReadMemberList({
    required this.nextSeq,
    required this.isFinished,
    required this.memberInfoList,
  });

  V2TimGroupMessageReadMemberList.fromJson(Map<String, dynamic> json) {
    nextSeq = json['nextSeq'];
    isFinished = json['isFinished'];
    if (json['memberInfoList'] != null) {
      memberInfoList = List.empty(growable: true);
      json['memberInfoList'].forEach((v) {
        memberInfoList.add(V2TimGroupMemberInfo.fromJson(v));
      });
    } else {
      memberInfoList = List.empty(growable: true);
    }
  }

  Map<dynamic, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nextSeq'] = nextSeq;
    data['isFinished'] = isFinished;
    data['memberInfoList'] = memberInfoList.isNotEmpty ? memberInfoList.map((v) => v.toJson()).toList() : [];
    return data;
  }
}
