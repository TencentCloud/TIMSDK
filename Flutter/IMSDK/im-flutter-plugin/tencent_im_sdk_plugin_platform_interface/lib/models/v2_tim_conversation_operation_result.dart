
/// V2TimConversationOperationResult
///
/// {@category Models}
///
class V2TimConversationOperationResult {
   String? conversationID;
   int? resultCode ;
  String? resultInfo;

  V2TimConversationOperationResult({
    this.conversationID,
    this.resultCode,
    this.resultInfo,
  });

  V2TimConversationOperationResult.fromJson(Map<String, dynamic> json) {
    conversationID = json['conversationID'];
    resultCode = json['resultCode'];
    resultInfo = json['resultInfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conversationID'] = conversationID;
    data['resultCode'] = resultCode;
    data['resultInfo'] = resultInfo;
    
    return data;
  }
}

