import 'package:tencent_im_sdk_plugin/models/v2_tim_group_change_info.dart';

class V2TimGroupInfoChanged {
  late String groupID;
  late List<V2TimGroupChangeInfo?>? groupChangeInfoList;

  V2TimGroupInfoChanged({
    required this.groupID,
    this.groupChangeInfoList,
  });

  V2TimGroupInfoChanged.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    if (json['groupChangeInfo'] != null) {
      groupChangeInfoList = List.empty(growable: true);
      json['groupChangeInfo'].forEach((v) {
        groupChangeInfoList!.add(new V2TimGroupChangeInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupID'] = this.groupID;
    if (this.groupChangeInfoList != null) {
      data['groupChangeInfo'] =
          this.groupChangeInfoList!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}
// {
//   "groupID":"",
//   "groupChangeInfo":[{}]
// }
