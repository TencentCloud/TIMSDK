/// V2TimFriendGroup
///
/// {@category Models}
///
class V2TimFriendGroup {
  late String? name;
  late int? friendCount;
  late List<String>? friendIDList;

  V2TimFriendGroup({
    this.name,
    this.friendCount,
    this.friendIDList,
  });

  V2TimFriendGroup.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    friendCount = json['friendCount'];
    friendIDList = json['friendIDList'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['friendCount'] = this.friendCount;
    data['friendIDList'] = this.friendIDList;
    return data;
  }
}
// {
//   "name":"",
//   "friendCount":0,
//   "friendIDList":[""]
// }
