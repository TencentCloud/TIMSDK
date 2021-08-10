import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application.dart';

/// V2TimGroupApplicationResult
///
/// {@category Models}
///
class V2TimGroupApplicationResult {
  late int? unreadCount = 0;
  List<V2TimGroupApplication?>? groupApplicationList =
      List.empty(growable: true);

  V2TimGroupApplicationResult({
    this.unreadCount,
    this.groupApplicationList,
  });

  V2TimGroupApplicationResult.fromJson(Map<String, dynamic> json) {
    unreadCount = json['unreadCount'];
    if (json['groupApplicationList'] != null) {
      groupApplicationList = List.empty(growable: true);
      json['groupApplicationList'].forEach((v) {
        groupApplicationList!.add(new V2TimGroupApplication.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unreadCount'] = this.unreadCount;
    if (this.groupApplicationList != null) {
      data['groupApplicationList'] =
          this.groupApplicationList!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}
// {
//   "unreadCount":0,
//   "groupApplicationList":[]
// }
