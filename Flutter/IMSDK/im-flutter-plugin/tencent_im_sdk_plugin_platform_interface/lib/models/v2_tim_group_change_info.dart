/// V2TimGroupChangeInfo
///
/// {@category Models}
///
class V2TimGroupChangeInfo {
  int? type;
  String? value;
  String? key;
  bool? boolValue;

  V2TimGroupChangeInfo({
    required this.type,
    this.value,
    this.key,
    this.boolValue,
  });

  V2TimGroupChangeInfo.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
    key = json['key'];
    boolValue = json['boolValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['value'] = value;
    data['key'] = key;
    data['boolValue'] = boolValue;
    return data;
  }
}

// {
//   "type":0,
//   "value":"",
//   "key":""
// }
