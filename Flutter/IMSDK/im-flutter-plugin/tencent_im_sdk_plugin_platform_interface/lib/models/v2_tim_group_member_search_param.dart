/// V2TimGroupMemberSearchParam
///
/// {@category Models}
///
class V2TimGroupMemberSearchParam {
  late List<String> keywordList;
  List<String>? groupIDList;
  bool isSearchMemberUserID = true;
  bool isSearchMemberNickName = true;
  bool isSearchMemberRemark = true;
  bool isSearchMemberNameCard = true;
  V2TimGroupMemberSearchParam({
    required this.keywordList,
    this.groupIDList,
    this.isSearchMemberUserID = true,
    this.isSearchMemberNickName = true,
    this.isSearchMemberRemark = true,
    this.isSearchMemberNameCard = true,
  });

  V2TimGroupMemberSearchParam.fromJson(Map<String, dynamic> json) {
    keywordList = json['keywordList'];
    groupIDList = json['groupIDList'];
    isSearchMemberUserID = json['isSearchMemberUserID'];
    isSearchMemberNickName = json['isSearchMemberNickName'];
    isSearchMemberRemark = json['isSearchMemberRemark'];
    isSearchMemberNameCard = json['isSearchMemberNameCard'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['keywordList'] = keywordList;
    data['groupIDList'] = groupIDList;
    data['isSearchMemberUserID'] = isSearchMemberUserID;
    data['isSearchMemberNickName'] = isSearchMemberNickName;
    data['isSearchMemberRemark'] = isSearchMemberRemark;
    data['isSearchMemberNameCard'] = isSearchMemberNameCard;
    return data;
  }
}
