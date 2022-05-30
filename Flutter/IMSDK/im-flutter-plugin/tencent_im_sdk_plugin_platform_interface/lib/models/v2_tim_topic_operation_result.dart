/// V2TimTopicInfo
///
/// {@category Models}
///
class V2TimTopicOperationResult {
  int? errorCode;
  String? errorMessage;
  String? topicID;
  V2TimTopicOperationResult({
    this.errorCode,
    this.errorMessage,
    this.topicID,
  });

V2TimTopicOperationResult.fromJson(Map<String, dynamic> json) {
  errorCode = json['errorCode'];
  errorMessage = json['errorMessage'];
  topicID = json['topicID'];
}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['topicID'] = topicID;
    return data;
  }
}