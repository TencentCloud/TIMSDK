class MessageRepliedData {
  late String messageAbstract;
  late String messageSender;
  late String messageID;

  MessageRepliedData.fromJson(Map messageReply) {
    messageAbstract = messageReply["messageAbstract"];
    messageSender = messageReply["messageSender"] ?? "";
    messageID = messageReply["messageID"];
  }
}

class CloudCustomData {
  Map<String, dynamic>? messageReply;
  Map<String, dynamic>? messageReaction = {};

  CloudCustomData.fromJson(Map jsonMap) {
    messageReply = jsonMap["messageReply"];
    messageReaction = jsonMap["messageReaction"] ?? {};
  }

  Map<String, Map?> toMap() {
    final Map<String, Map?> data = {};
    if (messageReply != null) {
      data['messageReply'] = messageReply;
    }
    data['messageReaction'] = messageReaction ?? {};
    return data;
  }

  CloudCustomData();
}
