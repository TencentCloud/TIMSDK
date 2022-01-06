import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_elem.dart';

/// V2TimFileElem
///
/// {@category Models}
///
class V2TimFileElem extends V2TIMElem {
  late String? path;
  late String? fileName;
  // ignore: non_constant_identifier_names
  late String? UUID;
  late String? url;
  late int? fileSize;

  V2TimFileElem({
    this.path,
    this.fileName,
    // ignore: non_constant_identifier_names
    this.UUID,
    this.url,
    this.fileSize,
  });

  V2TimFileElem.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    fileName = json['fileName'];
    UUID = json['UUID'];
    url = json['url'];
    fileSize = json['fileSize'];
    if (json['nextElem'] != null) {
      nextElem = Map<String, dynamic>.from(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['fileName'] = fileName;
    data['UUID'] = UUID;
    data['url'] = url;
    data['fileSize'] = fileSize;
    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }
}
// {
//   "path":"",
//   "fileName":"",
//   "UUID":"",
//   "url":"",
//   "fileSize": 0
// }
