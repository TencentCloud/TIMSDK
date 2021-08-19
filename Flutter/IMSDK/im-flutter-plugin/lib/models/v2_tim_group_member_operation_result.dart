/// V2TimGroupMemberOperationResult
///
/// {@category Models}
///
class V2TimGroupMemberOperationResult {
  late String? memberID;
  late int? result;

  V2TimGroupMemberOperationResult({
    this.memberID,
    this.result,
  });

  V2TimGroupMemberOperationResult.fromJson(Map<String, dynamic> json) {
    memberID = json['memberID'];
    result = json['result'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['memberID'] = this.memberID;
    data['result'] = this.result;
    return data;
  }
}

// {
//   "memberID":"",
//   "result":0,
// }
