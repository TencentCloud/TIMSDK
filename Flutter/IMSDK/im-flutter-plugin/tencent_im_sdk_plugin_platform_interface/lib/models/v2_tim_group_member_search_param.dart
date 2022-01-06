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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['keywordList'] = this.keywordList;
    data['groupIDList'] = this.groupIDList;
    data['isSearchMemberUserID'] = this.isSearchMemberUserID;
    data['isSearchMemberNickName'] = this.isSearchMemberNickName;
    data['isSearchMemberRemark'] = this.isSearchMemberRemark;
    data['isSearchMemberNameCard'] = this.isSearchMemberNameCard;
    return data;
  }
}
