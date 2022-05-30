/// V2TimGroupSearchParam
///
/// {@category Models}
///
class V2TimGroupSearchParam {
  late List<String> keywordList;
  bool isSearchGroupID = true;
  bool isSearchGroupName = true;

  V2TimGroupSearchParam({
    required this.keywordList,
    this.isSearchGroupID = true,
    this.isSearchGroupName = true,
  });

  V2TimGroupSearchParam.fromJson(Map<String, dynamic> json) {
    keywordList = json['keywordList'];
    isSearchGroupID = json['isSearchGroupID'];
    isSearchGroupName = json['isSearchGroupName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['keywordList'] = keywordList;
    data['isSearchGroupID'] = isSearchGroupID;
    data['isSearchGroupName'] = isSearchGroupName;
    return data;
  }
}
