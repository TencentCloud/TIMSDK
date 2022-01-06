/// V2TimGroupChangeInfo
///
/// {@category Models}
///
class V2TimGroupChangeInfo {
  int? type;
  String? value;
  String? key;

  V2TimGroupChangeInfo({
    required this.type,
    this.value,
    this.key,
  });

  V2TimGroupChangeInfo.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
    key = json['key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['value'] = this.value;
    data['key'] = this.key;
    return data;
  }
}

// {
//   "type":0,
//   "value":"",
//   "key":""
// }
