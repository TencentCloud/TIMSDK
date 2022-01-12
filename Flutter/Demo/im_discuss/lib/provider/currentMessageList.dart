import 'package:discuss/utils/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class CurrentMessageListModel with ChangeNotifier, DiagnosticableTreeMixin {
  Map<String, List<V2TimMessage>> _messageMap = {};

  get messageMap => _messageMap;

  clear() {
    _messageMap = {};
    notifyListeners();
  }

  updateC2CMessageByUserId(String userid) {
    String key = "c2c_$userid";
    if (_messageMap.containsKey(key)) {
      List<V2TimMessage>? msgList = _messageMap[key];
      for (var element in msgList!) {
        element.isPeerRead = true;
      }
      _messageMap[key] = msgList;
      notifyListeners();
    } else {
      Utils.log("会话列表不存在这个userid key");
    }
  }

  addMessage(String key, List<V2TimMessage> value) {
    if (_messageMap.containsKey(key)) {
      _messageMap[key]!.addAll(value);
    } else {
      List<V2TimMessage> messageList = List.empty(growable: true);
      messageList.addAll(value);
      _messageMap[key] = messageList;
    }
    //去重
    Map<String, V2TimMessage> rebuildMap = <String, V2TimMessage>{};
    for (var element in _messageMap[key]!) {
      rebuildMap[element.msgID!] = element;
    }
    _messageMap[key] = rebuildMap.values.toList();
    rebuildMap.clear();
    _messageMap[key]!
        .sort((left, right) => left.timestamp!.compareTo(right.timestamp!));
    notifyListeners();
  }

  addOneMessageIfNotExits(String key, V2TimMessage message) {
    if (_messageMap.containsKey(key)) {
      bool hasMessage =
          _messageMap[key]!.any((element) => element.msgID == message.msgID);
      if (hasMessage) {
        int idx = _messageMap[key]!
            .indexWhere((element) => element.msgID == message.msgID);
        _messageMap[key]![idx] = message;
      } else {
        _messageMap[key]!.add(message);
      }
    } else {
      List<V2TimMessage> messageList = List.empty(growable: true);
      messageList.add(message);
      _messageMap[key] = messageList;
    }
    _messageMap[key]!
        .sort((left, right) => left.timestamp!.compareTo(right.timestamp!));
    notifyListeners();
    return _messageMap;
  }

  deleteMessage(String key) {
    _messageMap.remove(key);
    notifyListeners();
  }

  deleteMessageByMsgId(String userId, List<String> msgId) {
    Utils.log("$userId $msgId");
    List<V2TimMessage>? messages = _messageMap[userId];
    List<V2TimMessage> resList = List.empty(growable: true);
    if (messages!.isNotEmpty) {
      for (var e in messages) {
        if (!msgId.contains(e.msgID)) {
          resList.add(e);
        }
      }
    }
    _messageMap[userId] = resList;
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('messageMap', messageMap));
  }
}
