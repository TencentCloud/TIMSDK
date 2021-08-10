class V2TimReceiveMessageOptInfo {
  late int? c2CReceiveMessageOpt;
  late String userID;
  V2TimReceiveMessageOptInfo({
    this.c2CReceiveMessageOpt,
    required this.userID,
  });
  V2TimReceiveMessageOptInfo.fromJson(Map<String, dynamic> jsonStr) {
    this.c2CReceiveMessageOpt = jsonStr['c2CReceiveMessageOpt'];
    this.userID = jsonStr['userID'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['c2CReceiveMessageOpt'] = this.c2CReceiveMessageOpt;
    data['userID'] = userID;
    return data;
  }
}
