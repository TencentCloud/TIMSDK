import 'v2_tim_image.dart';

/// V2TimImageElem
///
/// {@category Models}
///

class V2TimImageElem {
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
        imageList!.add(new V2TimImage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['path'] = this.path;
    if (this.imageList != null) {
      data['imageList'] = this.imageList!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}
// {
//   "path":"",
//   "imageList":[{}]
// }
