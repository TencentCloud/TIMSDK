/// V2TimReceiveRestCustomData
///
/// {@category Models}
///
class V2TimReceiveRestCustomData {
  late String groupID;
  late String customData;

  V2TimReceiveRestCustomData({
    required this.groupID,
    required this.customData,
  });

  V2TimReceiveRestCustomData.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    customData = json['customData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupID'] = this.groupID;
    data['customData'] = this.customData;
    return data;
  }
}

// {
//   "groupID":"",
//   "customData":""
// }
