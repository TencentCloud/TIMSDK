import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_elem.dart';

class V2TimMergerElem extends V2TIMElem {
  late bool? isLayersOverLimit;
  late String? title;
  List<String>? abstractList = List.empty(growable: true);

  V2TimMergerElem({
    this.isLayersOverLimit,
    this.title,
    this.abstractList,
  });

  V2TimMergerElem.fromJson(Map<String, dynamic> json) {
    isLayersOverLimit = json['isLayersOverLimit'];
    title = json['title'];
    abstractList = json['abstractList'].cast<String>();
    if (json['nextElem'] != null) {
      nextElem = Map<String, dynamic>.from(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isLayersOverLimit'] = isLayersOverLimit;
    data['title'] = title;
    data['abstractList'] = abstractList;
    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }
}

// {
//   "isLayersOverLimit":true,
//   "title":"",
//   "abstractList":[""],
// }
