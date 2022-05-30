import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_elem.dart';

/// V2TimSoundElem
///
/// {@category Models}
///
class V2TimSoundElem extends V2TIMElem {
  late String? path;
  // ignore: non_constant_identifier_names
  late String? UUID;
  late int? dataSize;
  late int? duration;
  late String? url;
  String? localUrl;

  V2TimSoundElem({
    this.path,
    // ignore: non_constant_identifier_names
    this.UUID,
    this.dataSize,
    this.duration,
    this.url,
    this.localUrl,
  });

  V2TimSoundElem.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    UUID = json['UUID'];
    dataSize = json['dataSize'];
    duration = json['duration'];
    localUrl = json['localUrl'];
    url = json['url'];
    if (json['nextElem'] != null) {
      nextElem = Map<String, dynamic>.from(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['UUID'] = UUID;
    data['dataSize'] = dataSize;
    data['duration'] = duration;
    data['localUrl'] = localUrl;
    data['url'] = url;
    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }
}
// {
//   "path":"",
//   "UUID":"",
//   "dataSize":0,
//   "duration":0,
//   "url":""
// }
