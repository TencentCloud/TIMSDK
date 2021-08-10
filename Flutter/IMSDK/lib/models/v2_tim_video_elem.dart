/// V2TimVideoElem
///
/// {@category Models}
///
class V2TimVideoElem {
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['videoPath'] = this.videoPath;
    data['UUID'] = this.UUID;
    data['videoSize'] = this.videoSize;
    data['duration'] = this.duration;
    data['snapshotPath'] = this.snapshotPath;
    data['snapshotUUID'] = this.snapshotUUID;
    data['snapshotSize'] = this.snapshotSize;
    data['snapshotWidth'] = this.snapshotWidth;
    data['snapshotHeight'] = this.snapshotHeight;
    data['videoUrl'] = this.videoUrl;
    data['snapshotUrl'] = this.snapshotUrl;
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
