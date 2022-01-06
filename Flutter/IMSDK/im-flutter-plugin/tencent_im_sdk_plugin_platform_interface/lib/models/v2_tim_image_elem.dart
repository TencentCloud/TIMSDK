import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_elem.dart';

import 'v2_tim_image.dart';

/// V2TimImageElem
///
/// {@category Models}
///

class V2TimImageElem extends V2TIMElem {
  late String? path;
  List<V2TimImage?>? imageList = List.empty(growable: true);

  V2TimImageElem({
    this.path,
    this.imageList,
  });

  V2TimImageElem.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    if (json['imageList'] != null) {
      imageList = List.empty(growable: true);
      json['imageList'].forEach((v) {
        imageList!.add(V2TimImage.fromJson(v));
      });
    }
    if (json['nextElem'] != null) {
      nextElem = Map<String, dynamic>.from(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    if (imageList != null) {
      data['imageList'] = imageList!.map((v) => v!.toJson()).toList();
    }
    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }
}
// {
//   "path":"",
//   "imageList":[{}]
// }
