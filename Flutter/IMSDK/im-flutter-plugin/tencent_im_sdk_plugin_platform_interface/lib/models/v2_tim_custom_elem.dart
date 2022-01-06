import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_elem.dart';

/// V2TimCustomElem
///
/// {@category Models}
///
class V2TimCustomElem extends V2TIMElem {
  late String? data;
  late String? desc;
  late String? extension;

  V2TimCustomElem({
    this.data,
    this.desc,
    this.extension,
  });

  V2TimCustomElem.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    desc = json['desc'];
    extension = json['extension'];
    if (json['nextElem'] != null) {
      nextElem = Map<String, dynamic>.from(json['nextElem']);
    }
    ;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    data['desc'] = desc;
    data['extension'] = extension;
    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }
}
// {
//   "data":"",
//   "desc":"",
//   "extension":""
// }
