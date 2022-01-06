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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['conversationID'] = this.conversationID;
    data['keywordList'] = this.keywordList;
    data['type'] = this.type;
    data['userIDList'] =
        this.userIDList == null ? List.empty(growable: true) : this.userIDList;
    data['messageTypeList'] = this.messageTypeList == null
        ? List.empty(growable: true)
        : this.messageTypeList;
    data['searchTimePosition'] = this.searchTimePosition;
    data['searchTimePeriod'] = this.searchTimePeriod;
    data['pageSize'] = this.pageSize;
    data['pageIndex'] = this.pageIndex;
    return data;
  }
}
