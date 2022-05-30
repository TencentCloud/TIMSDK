class V2TimReceiveMessageOptInfo {
  late int? c2CReceiveMessageOpt;
  late String userID;

  V2TimReceiveMessageOptInfo({
    this.c2CReceiveMessageOpt,
    required this.userID,
  });

  V2TimReceiveMessageOptInfo.fromJson(Map<String, dynamic> jsonStr) {
    c2CReceiveMessageOpt = jsonStr['c2CReceiveMessageOpt'];
    userID = jsonStr['userID'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['c2CReceiveMessageOpt'] = c2CReceiveMessageOpt;
    data['userID'] = userID;
    return data;
  }
}
