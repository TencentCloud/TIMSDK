/// V2TimTextElem
///
/// {@category Models}
///
class V2TimTextElem {
  late String? text;

  V2TimTextElem({
    this.text,
  });

  V2TimTextElem.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    return data;
  }
}

// {
//   "text":""
// }
