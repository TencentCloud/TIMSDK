/// V2TimOfflinePushInfo
///
/// {@category Models}
///
class V2TimOfflinePushInfo {
  late String? title;
  late String? desc;
  late bool? disablePush;

  V2TimOfflinePushInfo({
    this.title,
    this.desc,
    this.disablePush,
  });

  V2TimOfflinePushInfo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    desc = json['desc'];
    disablePush = json['disablePush'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['desc'] = this.desc;
    data['disablePush'] = this.disablePush;
    return data;
  }
}

// {
//   "title":"",
//   "desc":"",
//   "disablePush":true
// }
