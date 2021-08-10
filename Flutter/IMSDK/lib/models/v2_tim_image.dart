/// V2TimImage
///
/// {@category Models}
///
class V2TimImage {
  // ignore: non_constant_identifier_names
  late String? UUID;
  late int? type;
  late int? size;
  late int? width;
  late int? height;
  late String? url;

  V2TimImage({
    // ignore: non_constant_identifier_names
    this.UUID,
    required this.type,
    this.size,
    this.width,
    this.height,
    this.url,
  });

  V2TimImage.fromJson(Map<String, dynamic> json) {
    UUID = json['UUID'];
    type = json['type'];
    size = json['size'];
    width = json['width'];
    height = json['height'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UUID'] = this.UUID;
    data['type'] = this.type;
    data['size'] = this.size;
    data['width'] = this.width;
    data['height'] = this.height;
    data['url'] = this.url;
    return data;
  }
}

// {
//   "UUID":"",
//   "type":0,
//   "size":0,
//   "width":0,
//   "height":0,
//   "url":""
// }
