class V2TimMergerElem {
  late bool? isLayersOverLimit;
  late String? title;
  List<String>? abstractList = List.empty(growable: true);

  V2TimMergerElem({
    this.isLayersOverLimit,
    this.title,
    this.abstractList,
  });

  V2TimMergerElem.fromJson(Map<String, dynamic> json) {
    isLayersOverLimit = json['isLayersOverLimit'];
    title = json['title'];
    abstractList = json['abstractList'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isLayersOverLimit'] = this.isLayersOverLimit;
    data['title'] = this.title;
    data['abstractList'] = this.abstractList;
    return data;
  }
}

// {
//   "isLayersOverLimit":true,
//   "title":"",
//   "abstractList":[""],
// }
