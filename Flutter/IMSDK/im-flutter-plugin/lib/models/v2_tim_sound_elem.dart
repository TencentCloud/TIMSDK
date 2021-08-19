/// V2TimSoundElem
///
/// {@category Models}
///
class V2TimSoundElem {
  late String? path;
  // ignore: non_constant_identifier_names
  late String? UUID;
  late int? dataSize;
  late int? duration;
  late String? url;

  V2TimSoundElem({
    this.path,
    // ignore: non_constant_identifier_names
    this.UUID,
    this.dataSize,
    this.duration,
    this.url,
  });

  V2TimSoundElem.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    UUID = json['UUID'];
    dataSize = json['dataSize'];
    duration = json['duration'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['path'] = this.path;
    data['UUID'] = this.UUID;
    data['dataSize'] = this.dataSize;
    data['duration'] = this.duration;
    data['url'] = this.url;
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
