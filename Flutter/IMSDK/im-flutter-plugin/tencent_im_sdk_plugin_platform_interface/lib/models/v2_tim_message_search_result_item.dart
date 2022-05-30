import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';

/// V2TimMessageSearchResultItem
///
/// {@category Models}
///
class V2TimMessageSearchResultItem {
  String? conversationID;
  int? messageCount;
  List<V2TimMessage>? messageList;

  V2TimMessageSearchResultItem({
    this.conversationID,
    this.messageCount,
    this.messageList,
  });

  V2TimMessageSearchResultItem.fromJson(Map<String, dynamic> json) {
    conversationID = json['conversationID'];
    messageCount = json['messageCount'];
    if (json['messageList'] != null) {
      messageList = List.empty(growable: true);
      json['messageList'].forEach((v) {
        messageList!.add(V2TimMessage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conversationID'] = conversationID;
    data['messageCount'] = messageCount;
    if (messageList != null) {
      data['messageList'] = messageList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// {
//   "userID":"",
//   "timestamp":0
// }
