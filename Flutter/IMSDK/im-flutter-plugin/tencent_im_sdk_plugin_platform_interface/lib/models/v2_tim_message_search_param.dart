/// V2TimMessageSearchParam
///
/// {@category Models}
///
class V2TimMessageSearchParam {
  String? conversationID;
  late List<String> keywordList;
  late int type;
  List<String>? userIDList = [];
  List<int>? messageTypeList = [];
  int? searchTimePosition;
  int? searchTimePeriod;
  int? pageSize = 100;
  int? pageIndex = 0;
  V2TimMessageSearchParam({
    required this.type,
    required this.keywordList,
    this.conversationID,
    this.userIDList,
    this.messageTypeList,
    this.searchTimePosition,
    this.searchTimePeriod,
    this.pageSize,
    this.pageIndex,
  });

  V2TimMessageSearchParam.fromJson(Map<String, dynamic> json) {
    conversationID = json['conversationID'];
    keywordList = json['keywordList'] == null
        ? List.empty(growable: true)
        : json['keywordList'].cast<String>();
    type = json['type'];
    userIDList = json['userIDList'] == null
        ? List.empty(growable: true)
        : json['userIDList'].cast<String>();
    messageTypeList = json['messageTypeList'] == null
        ? List.empty(growable: true)
        : json['messageTypeList'].cast<int>();
    searchTimePosition = json['searchTimePosition'];
    searchTimePeriod = json['searchTimePeriod'];
    pageSize = json['pageSize'];
    pageIndex = json['pageIndex'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conversationID'] = conversationID;
    data['keywordList'] = keywordList;
    data['type'] = type;
    data['userIDList'] =
        userIDList ?? List.empty(growable: true);
    data['messageTypeList'] = messageTypeList ?? List.empty(growable: true);
    data['searchTimePosition'] = searchTimePosition;
    data['searchTimePeriod'] = searchTimePeriod;
    data['pageSize'] = pageSize;
    data['pageIndex'] = pageIndex;
    return data;
  }
}
