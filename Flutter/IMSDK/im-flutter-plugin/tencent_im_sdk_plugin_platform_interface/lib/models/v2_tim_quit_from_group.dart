/// V2TimQuitFromGroup
///
/// {@category Models}
///
class V2TimQuitFromGroup {
  late String groupID;

  V2TimQuitFromGroup({
    required this.groupID,
  });

  V2TimQuitFromGroup.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupID'] = this.groupID;
    return data;
  }
}

// {
//   "groupID":""
// }
