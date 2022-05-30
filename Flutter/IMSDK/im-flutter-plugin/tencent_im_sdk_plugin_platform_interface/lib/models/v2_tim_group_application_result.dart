import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_application.dart';

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
        groupApplicationList!.add(V2TimGroupApplication.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unreadCount'] = unreadCount;
    if (groupApplicationList != null) {
      data['groupApplicationList'] =
          groupApplicationList!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}
// {
//   "unreadCount":0,
//   "groupApplicationList":[]
// }
