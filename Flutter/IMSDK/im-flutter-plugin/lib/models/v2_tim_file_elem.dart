/// V2TimFileElem
///
/// {@category Models}
///
class V2TimFileElem {
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['path'] = this.path;
    data['fileName'] = this.fileName;
    data['UUID'] = this.UUID;
    data['url'] = this.url;
    data['fileSize'] = this.fileSize;
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
