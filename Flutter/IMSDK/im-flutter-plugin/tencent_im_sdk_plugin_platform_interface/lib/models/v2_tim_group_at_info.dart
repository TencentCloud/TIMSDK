/// V2TimGroupAtInfo
///
/// {@category Models}
///
class V2TimGroupAtInfo {
  late String seq;
  late int atType;

  V2TimGroupAtInfo({
    required this.seq,
    required this.atType,
  });

  V2TimGroupAtInfo.fromJson(Map<String, dynamic> json) {
    seq = json['seq'];
    atType = json['atType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seq'] = seq;
    data['atType'] = atType;
    return data;
  }
}

// {
//   "seq":0,
//   "atType":0
// }
