import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_elem.dart';

/// V2TimVideoElem
///
/// {@category Models}
///
class V2TimVideoElem extends V2TIMElem {
  late String? videoPath;
  // ignore: non_constant_identifier_names
  late String? UUID;
  late int? videoSize;
  late int? duration;
  late String? snapshotPath;
  late String? snapshotUUID;
  late int? snapshotSize;
  late int? snapshotWidth;
  late int? snapshotHeight;
  late String? videoUrl;
  late String? snapshotUrl;

  V2TimVideoElem({
    this.videoPath,
    // ignore: non_constant_identifier_names
    this.UUID,
    this.videoSize,
    this.duration,
    this.snapshotPath,
    this.snapshotUUID,
    this.snapshotSize,
    this.snapshotWidth,
    this.snapshotHeight,
    this.videoUrl,
    this.snapshotUrl,
  });

  V2TimVideoElem.fromJson(Map<String, dynamic> json) {
    videoPath = json['videoPath'];
    UUID = json['UUID'];
    videoSize = json['videoSize'];
    duration = json['duration'];
    snapshotPath = json['snapshotPath'];
    snapshotUUID = json['snapshotUUID'];
    snapshotSize = json['snapshotSize'];
    snapshotWidth = json['snapshotWidth'];
    snapshotHeight = json['snapshotHeight'];
    videoUrl = json['videoUrl'];
    snapshotUrl = json['snapshotUrl'];
    if (json['nextElem'] != null) {
      nextElem = Map<String, dynamic>.from(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['videoPath'] = videoPath;
    data['UUID'] = UUID;
    data['videoSize'] = videoSize;
    data['duration'] = duration;
    data['snapshotPath'] = snapshotPath;
    data['snapshotUUID'] = snapshotUUID;
    data['snapshotSize'] = snapshotSize;
    data['snapshotWidth'] = snapshotWidth;
    data['snapshotHeight'] = snapshotHeight;
    data['videoUrl'] = videoUrl;
    data['snapshotUrl'] = snapshotUrl;
    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }
}

// {
//   "videoPath":"",
//   "UUID":"",
//   "videoSize":0,
//   "duration":0,
//   "snapshotPath":"",
//   "snapshotUUID":"",
//   "snapshotSize":0,
//   "snapshotWidth":0,
//   "snapshotHeight":0,
//   "videoUrl":"",
//   "snapshotUrl":""
// }
