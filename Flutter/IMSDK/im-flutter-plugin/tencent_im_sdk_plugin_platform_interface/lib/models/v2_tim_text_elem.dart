import 'dart:convert';

import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_elem.dart';

/// V2TimTextElem
///
/// {@category Models}
///
class V2TimTextElem extends V2TIMElem {
  late String? text;

  V2TimTextElem({
    this.text,
  });

  V2TimTextElem.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    if (json['nextElem'] != null) {
      nextElem = Map<String, dynamic>.from(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }

  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
}

// {
//   "text":""
// }
