/// V2TimUserStatus
///
/// {@category Models}
///
class V2TimUserStatus {
  String? userID;
  int? statusType;
  String? customStatus;

  V2TimUserStatus({
    this.userID,
    this.statusType,
    this.customStatus,
  });

  V2TimUserStatus.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    statusType = json['statusType'];
    customStatus = json['customStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userID;
    data['statusType'] = statusType;
    data['customStatus'] = customStatus;
    return data;
  }
}

// {
//   "userId":"",
//   "role":""
// }
