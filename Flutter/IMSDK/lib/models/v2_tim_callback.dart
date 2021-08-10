/// V2TimCallback
///
/// {@category Models}
///
class V2TimCallback {
  late int code;
  late String desc;

  V2TimCallback({
    required this.code,
    required this.desc,
  });

  V2TimCallback.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    desc = json['desc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['desc'] = this.desc;
    return data;
  }
}
// {
//   code:0,
//   desc:''
// }
