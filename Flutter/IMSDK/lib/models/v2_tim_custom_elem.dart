/// V2TimCustomElem
///
/// {@category Models}
///
class V2TimCustomElem {
  late String? data;
  late String? desc;
  late String? extension;

  V2TimCustomElem({
    this.data,
    this.desc,
    this.extension,
  });

  V2TimCustomElem.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    desc = json['desc'];
    extension = json['extension'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = this.data;
    data['desc'] = this.desc;
    data['extension'] = this.extension;
    return data;
  }
}
// {
//   "data":"",
//   "desc":"",
//   "extension":""
// }
