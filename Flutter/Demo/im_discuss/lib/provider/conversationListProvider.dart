import 'dart:convert';

import 'package:discuss/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:flutter/foundation.dart';

class ConversationListProvider with ChangeNotifier {
  List<V2TimConversation> _conversationList = List.empty(growable: true);
  int _totalUnreadCount = 0;
  List<V2TimConversation> get conversationList => _conversationList;
  int get totalUnreadCount => _totalUnreadCount;

  static SharedPreferences? prefs;

  Future<SharedPreferences?> getPrefsInstance() async {
    ConversationListProvider.prefs ??= await SharedPreferences.getInstance();
    return ConversationListProvider.prefs;
  }

  // 会话的数据持久化
  savetosharePerferance() async {
    SharedPreferences? prefs = await getPrefsInstance();
    if (prefs != null) {
      prefs.setStringList(
        "latest_conversations",
        _conversationList.map((e) => jsonEncode(e.toJson())).toList(),
      );
    }
  }

  restoreConversation() async {
    SharedPreferences? prefs = await getPrefsInstance();
    if (prefs != null) {
      List<String>? data = prefs.getStringList("latest_conversations");
      if (data != null && data.isNotEmpty) {
        List<V2TimConversation> conList =
            data.map((e) => V2TimConversation.fromJson(jsonDecode(e))).toList();
        _conversationList = conList;
        notifyListeners();
      }
    }
  }

  updateTotalUnreadCount(int data) {
    _totalUnreadCount = data;
    notifyListeners();
  }

  replaceConversationList(List<V2TimConversation> data) {
    _conversationList = data;
    sort();
    notifyListeners();
    savetosharePerferance();
  }

  conversationItemChange(List<V2TimConversation> list) {
    for (int element = 0; element < list.length; element++) {
      int index = _conversationList.indexWhere(
          (item) => item.conversationID == list[element].conversationID);
      if (index > -1) {
        _conversationList.setAll(index, [list[element]]);
      } else {
        _conversationList.add(list[element]);
      }
    }
    sort();
    notifyListeners();
    savetosharePerferance();
  }

  addNewConversation(List<V2TimConversation> list) {
    _conversationList.addAll(list);
    sort();
    for (var item in _conversationList) {
      Utils.log(item.toJson());
    }
    notifyListeners();
    savetosharePerferance();
  }

  deleteConversation(List<V2TimConversation> list) {
    for (var element in list) {
      _conversationList
          .removeWhere((item) => element.conversationID == item.conversationID);
    }

    sort();
    notifyListeners();
    savetosharePerferance();
  }

  sort() {
    _conversationList.sort((a, b) => b.orderkey!.compareTo(a.orderkey!));
  }
}
