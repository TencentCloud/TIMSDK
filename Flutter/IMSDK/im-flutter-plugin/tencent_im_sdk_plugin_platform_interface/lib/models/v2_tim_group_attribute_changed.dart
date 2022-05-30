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
        ? <String, String>{}
        : Map<String, String>.from(json['groupAttributeMap']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupID'] = groupID;
    data['groupAttributeMap'] = groupAttributeMap;
    return data;
  }
}
// {
//   "groupID":"",
//   "groupAttributeMap":{}
// }
