import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class CurrentMessageListModel with ChangeNotifier, DiagnosticableTreeMixin {
  Map<String, List<V2TimMessage>> _messageMap = new Map();

  get messageMap => _messageMap;

  clear() {
    _messageMap = new Map();
    notifyListeners();
  }

  updateC2CMessageByUserId(String userid) {
    String key = "c2c_$userid";
    if (_messageMap.containsKey(key)) {
      List<V2TimMessage>? msgList = _messageMap[key];
      msgList!.forEach((element) {
        element.isPeerRead = true;
      });
      _messageMap[key] = msgList;
      notifyListeners();
    } else {
      print("会话列表不存在这个userid key");
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
    Map<String, V2TimMessage> rebuildMap = new Map<String, V2TimMessage>();
    _messageMap[key]!.forEach((element) {
      rebuildMap[element.msgID!] = element;
    });
    _messageMap[key] = rebuildMap.values.toList();
    rebuildMap.clear();
    _messageMap[key]!
        .sort((left, right) => left.timestamp!.compareTo(right.timestamp!));
    notifyListeners();
  }

  addOneMessageIfNotExits(String key, V2TimMessage message) {
    print("======1111111>>$key ${message.status} ${message.progress}");
    print(key);
    print(_messageMap.keys);
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
    print("======1111111>>2222$key ${message.status} ${message.progress}");
    notifyListeners();
    return _messageMap;
  }

  deleteMessage(String key) {
    _messageMap.remove(key);
    notifyListeners();
  }

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('messageMap', messageMap));
  }
}
