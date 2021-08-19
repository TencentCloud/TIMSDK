/// V2TimFaceElem
///
/// {@category Models}
///
class V2TimFaceElem {
  late int? index;
  late String? data;

  V2TimFaceElem({
    this.index,
    this.data,
  });

  V2TimFaceElem.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['index'] = this.index;
    data['data'] = this.data;
    return data;
  }
}
// {
//   "index":1,
//   "data":""
// }
