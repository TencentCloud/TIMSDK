/// V2TimFriendSearchParam
///
/// {@category Models}
///
class V2TimFriendSearchParam {
  late List<String> keywordList;
  bool isSearchUserID = true;
  bool isSearchNickName = true;
  bool isSearchRemark = true;

  V2TimFriendSearchParam({
    required this.keywordList,
    this.isSearchUserID = true,
    this.isSearchNickName = true,
    this.isSearchRemark = true,
  });

  V2TimFriendSearchParam.fromJson(Map<String, dynamic> json) {
    keywordList = json['keywordList'];
    isSearchUserID = json['isSearchUserID'];
    isSearchNickName = json['isSearchNickName'];
    isSearchRemark = json['isSearchRemark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['keywordList'] = keywordList;
    data['isSearchUserID'] = isSearchUserID;
    data['isSearchNickName'] = isSearchNickName;
    data['isSearchRemark'] = isSearchRemark;
    return data;
  }
}
