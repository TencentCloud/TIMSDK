
/// V2TimConversationListFilter
///
/// {@category Models}
///
class V2TimConversationListFilter {
   int? conversationType;
   int? nextSeq ;
   int? count;
    int? markType;
  String? groupName;

  V2TimConversationListFilter({
    this.conversationType,
    this.nextSeq,
    this.markType,
    this.groupName,
    this.count,
  });

  V2TimConversationListFilter.fromJson(Map<String, dynamic> json) {
    conversationType = json['conversationType'];
    nextSeq = json['nextSeq'];
    markType = json['markType'];
    groupName = json['groupName'];
    count = json['count'];
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conversationType'] = conversationType;
    data['nextSeq'] = nextSeq;
    data['markType'] = markType;
    data['groupName'] = groupName;
    data['count'] = count;
    return data;
  }
}

