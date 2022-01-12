import 'package:discuss/utils/const.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

/*
  每个Map以userId为key，存储着不同的用户的List
*/
class HistoryMessageListProvider with ChangeNotifier {
  Map<String, List<V2TimMessage>> _messageMap = Map.from({});
  static SharedPreferences? prefs;

  Future<SharedPreferences?> getPrefsInstance() async {
    HistoryMessageListProvider.prefs ??= await SharedPreferences.getInstance();
    return HistoryMessageListProvider.prefs;
  }

  // 消息的数据持久化
  // savetosharePerferance() async {
  //   SharedPreferences? prefs = await getPrefsInstance();
  //   if (prefs != null) {

  //     prefs.setStringList(
  //       "latest_messages",
  //       _conversationList.map((e) => jsonEncode(e.toJson())).toList(),
  //     );
  //   }
  // }

  // restoreConversation() async {
  //   SharedPreferences? prefs = await getPrefsInstance();
  //   if (prefs != null) {
  //     List<String>? data = prefs.getStringList("latest_conversations");
  //     if (data!.isNotEmpty) {
  //       List<V2TimConversation> conList =
  //           data.map((e) => V2TimConversation.fromJson(jsonDecode(e))).toList();
  //       _conversationList = conList;
  //       notifyListeners();
  //     }
  //   }
  // }
  updateMessage(String id, String messageId, V2TimMessage message) {
    List<V2TimMessage> list = _messageMap[id] ?? [];
    int index = list.indexWhere((element) => element.msgID! == messageId);
    if (index > -1) {
      list[index] = message;
    }
    _messageMap[id] = list;
    notifyListeners();
  }

  /*
    updateCreateMessage 以id为key查找更新historyMessageList
  */
  updateCreateMessage(
      String userId, String messageId, String mockId, V2TimMessage message,
      {bool isOnProgress = false}) {
    List<V2TimMessage> list = _messageMap[userId] ?? [];

    int index = list.indexWhere((element) {
      // 防止以前消息中的id为null
      if (element.id == null) return false;
      return element.id == mockId;
    });
    /* 复原userID，主要目的是为了onProgress后及时更新msgID，在发送advacnMsg时退出后第二次进页面及时
    取到msgid，对之前的addmsg进行更新*/
    message.msgID = messageId;

    if (index > -1) {
      list[index] = message;
    }
    _messageMap[userId] = list;
    notifyListeners();
  }

  List<V2TimMessage> getMessageList(id) {
    List<V2TimMessage> list = _messageMap[id] ?? [];
    V2TimMessage? endMsg;
    if (list.isNotEmpty &&
        list[list.length - 1].elemType == Const.V2TIM_ELEM_TYPE_END) {
      endMsg = list.removeLast();
    }
    // 1. 按时序排序
    list.sort((a, b) {
      if (a.timestamp! == b.timestamp!) {
        return int.parse(a.seq!).compareTo(int.parse(b.seq!));
      }
      return a.timestamp!.compareTo(b.timestamp!);
    });
    // 2. 加入时间戳消息
    List<V2TimMessage> listWithTimestamp = [];
    for (var item in list) {
      if (listWithTimestamp.isEmpty ||
          item.timestamp! - listWithTimestamp[0].timestamp! > 300) {
        listWithTimestamp.insert(
            0,
            V2TimMessage(
              userID: '',
              isSelf: false,
              elemType: Const.V2TIM_ELEM_TYPE_TIME,
              msgID: '${item.timestamp}',
              timestamp: item.timestamp,
            ));
      }
      listWithTimestamp.insert(0, item);
    }
    if (endMsg != null) {
      listWithTimestamp.insert(0, endMsg);
    }
    return listWithTimestamp;
  }

  setMessageMap(Map<String, List<V2TimMessage>> data) {
    _messageMap = data;
    notifyListeners();
  }

  setMessageList(String id, List<V2TimMessage> messageList) {
    _messageMap[id] = messageList;
    notifyListeners();
  }

  /*
    注意高级消息在add 到update阶段，msgID都为createMessage到msgID
  */
  addMessage(String userID, List<V2TimMessage> messageList,
      {bool needCheck = false}) {
    if (messageList.isEmpty) return;

    List<V2TimMessage> notInList = [];
    if (_messageMap[userID] == null) {
      _messageMap[userID] = [];
    }
    // 没有新消息，加一条前端模拟消息，表示消息到底
    if (messageList.isEmpty) {
      notInList.add(V2TimMessage(elemType: Const.V2TIM_ELEM_TYPE_END));
    }
    int i = -1;

    for (V2TimMessage item in messageList) {
      // 根据msgId找到之前老消息的位置所在
      int index = _messageMap[userID]!.indexWhere(
        (element) => item.msgID == element.msgID,
      );
      // 降级处理
      if (index == -1) {
        index = _messageMap[userID]!.indexWhere(
          (element) => item.id == element.id,
        );
      }
      // 找到所在位置后
      if (index > -1) {
        _messageMap[userID]![index] = item;
        i = index;
        Utils.log("index $index change ${item.toJson()}");
      } else {
        notInList.add(item);
      }
    }
    if (notInList.isNotEmpty) {
      _messageMap[userID]?.addAll(notInList);
    }
    if (i > -1) {
      Utils.log("最终数据${_messageMap[userID]![i].toJson()}");
    }
    notifyListeners();
  }

  deleteMessage(String id, List<String> messageId) {
    for (String item in messageId) {
      _messageMap[id]!.removeWhere((element) => element.msgID == item);
    }
    notifyListeners();
  }

  updateMessageStatus(String id, V2TimMessage message) {
    int index = _messageMap[id]!
        .indexWhere((element) => message.msgID == element.msgID);
    if (index > -1) {
      _messageMap[id]![index] = message;
    } else {
      _messageMap[id]!.add(message);
    }
    notifyListeners();
  }

  setAllMessageAsRead(String id) {
    List<V2TimMessage> list = _messageMap[id]!;
    if (list.isNotEmpty) {
      for (V2TimMessage element in list) {
        element.isPeerRead = true;
      }
      notifyListeners();
    }
  }
}
