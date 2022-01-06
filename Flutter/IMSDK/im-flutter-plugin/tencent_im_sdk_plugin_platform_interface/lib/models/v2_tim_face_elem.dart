import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_elem.dart';

/// V2TimFaceElem
///
/// {@category Models}
///
class V2TimFaceElem extends V2TIMElem {
  late int? index;
  late String? data;

  V2TimFaceElem({
    this.index,
    this.data,
  });

  V2TimFaceElem.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    data = json['data'];
    if (json['nextElem'] != null) {
      nextElem = Map<String, dynamic>.from(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['index'] = index;
    data['data'] = this.data;
    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }
}
// {
//   "index":1,
//   "data":""
// }
