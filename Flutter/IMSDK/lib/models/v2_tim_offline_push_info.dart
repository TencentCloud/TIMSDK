/// V2TimOfflinePushInfo
///
/// {@category Models}
///
class V2TimOfflinePushInfo {
  late String? title;
  late String? desc;
  late bool? isDisablePush;

  V2TimOfflinePushInfo({
    this.title,
    this.desc,
    this.isDisablePush,
  });

  V2TimOfflinePushInfo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    desc = json['desc'];
    isDisablePush = json['isDisablePush'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['desc'] = this.desc;
    data['isDisablePush'] = this.isDisablePush;
    return data;
  }
}

// {
//   "title":"",
//   "desc":"",
//   "isDisablePush":true
// }
