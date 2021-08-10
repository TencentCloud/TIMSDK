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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupID'] = this.groupID;
    return data;
  }
}

// {
//   "groupID":""
// }
