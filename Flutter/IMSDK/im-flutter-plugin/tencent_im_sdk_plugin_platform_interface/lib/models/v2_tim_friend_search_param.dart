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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['keywordList'] = this.keywordList;
    data['isSearchUserID'] = this.isSearchUserID;
    data['isSearchNickName'] = this.isSearchNickName;
    data['isSearchRemark'] = this.isSearchRemark;
    return data;
  }
}
