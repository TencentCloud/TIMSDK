/// V2TimGroupAttributeChanged
///
/// {@category Models}
///
class V2TimGroupAttributeChanged {
  late String groupID;
  late Map<String, String> groupAttributeMap;

  V2TimGroupAttributeChanged({
    required this.groupID,
    required this.groupAttributeMap,
  });

  V2TimGroupAttributeChanged.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    groupAttributeMap = json['groupAttributeMap'] == null
        ? new Map<String, String>()
        : Map<String, String>.from(json['groupAttributeMap']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupID'] = this.groupID;
    data['groupAttributeMap'] = this.groupAttributeMap;
    return data;
  }
}
// {
//   "groupID":"",
//   "groupAttributeMap":{}
// }
