/// V2TimGroupCreated
///
/// {@category Models}
///
class V2TimGroupCreated {
  late String groupID;

  V2TimGroupCreated({
    required this.groupID,
  });

  V2TimGroupCreated.fromJson(Map<String, dynamic> json) {
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
