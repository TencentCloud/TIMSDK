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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupID'] = groupID;
    return data;
  }
}

// {
//   "groupID":""
// }
