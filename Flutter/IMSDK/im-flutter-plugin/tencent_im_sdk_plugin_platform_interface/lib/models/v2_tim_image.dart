/// V2TimImage
///
/// {@category Models}
///
class V2TimImage {
  // ignore: non_constant_identifier_names
  late String? uuid;
  late int? type;
  late int? size;
  late int? width;
  late int? height;
  late String? url;
  String? localUrl;

  V2TimImage({
    // ignore: non_constant_identifier_names
    this.uuid,
    required this.type,
    this.size,
    this.width,
    this.height,
    this.url,
    this.localUrl,
  });

  V2TimImage.fromJson(Map<String, dynamic> json) {
    uuid = json['UUID'] ?? json['uuid'];
    type = json['type'];
    size = json['size'];
    width = json['width'];
    height = json['height'];
    url = json['url'];
    localUrl = json['localUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['type'] = type;
    data['size'] = size;
    data['width'] = width;
    data['height'] = height;
    data['url'] = url;
    data['localUrl'] = localUrl;
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
