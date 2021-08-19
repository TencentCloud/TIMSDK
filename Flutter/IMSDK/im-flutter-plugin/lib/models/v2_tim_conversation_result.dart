import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';

/// V2TimConversationResult
///
/// {@category Models}
///
class V2TimConversationResult {
  late String? nextSeq;
  late bool? isFinished;
  List<V2TimConversation?>? conversationList = List.empty(growable: true);

  V2TimConversationResult({
    this.nextSeq,
    this.isFinished,
    this.conversationList,
  });

  V2TimConversationResult.fromJson(Map<String, dynamic> json) {
    nextSeq = json['nextSeq'];
    isFinished = json['isFinished'];
    if (json['conversationList'] != null) {
      conversationList = List.empty(growable: true);
      json['conversationList'].forEach((v) {
        conversationList!.add(new V2TimConversation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nextSeq'] = this.nextSeq;
    data['isFinished'] = this.isFinished;
    if (this.conversationList != null) {
      data['conversationList'] =
          this.conversationList!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}

// {
//   "nextSeq":0,
//   "isFinished":true,
//   "conversationList":[{}]
// }
