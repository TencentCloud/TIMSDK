import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/conversation_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/conversation/conversation_services.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';

List<T> removeDuplicates<T>(
    List<T> list, bool Function(T first, T second) isEqual) {
  List<T> output = [];
  for (var i = 0; i < list.length; i++) {
    bool found = false;
    for (var j = 0; j < output.length; j++) {
      if (isEqual(list[i], output[j])) {
        found = true;
      }
    }
    if (!found) {
      output.add(list[i]);
    }
  }

  return output;
}

class TUIConversationViewModel extends ChangeNotifier {
  final ConversationService _conversationService =
      serviceLocator<ConversationService>();
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  final TUIChatViewModel _chatViewModel = serviceLocator<TUIChatViewModel>();
  final MessageService _messageService = serviceLocator<MessageService>();
  V2TimConversationListener? _conversationListener;
  List<V2TimConversation?> _conversationList = [];
  static V2TimConversation? _selectedConversation;
  bool _haveMoreData = true;
  String _nextSeq = "0";
  ConversationLifeCycle? _lifeCycle;

  List<V2TimConversation?> get conversationList {
    _conversationList.sort((a, b) => b!.orderkey!.compareTo(a!.orderkey!));
    return _conversationList;
  }

  bool get haveMoreData {
    return _haveMoreData;
  }

  set lifeCycle(ConversationLifeCycle? value) {
    _lifeCycle = value;
  }

  set conversationList(List<V2TimConversation?> conversationList) {
    _conversationList = conversationList;
    notifyListeners();
  }

  V2TimConversation? get selectedConversation {
    return _selectedConversation;
  }

  static V2TimConversation? of() {
    return _selectedConversation;
  }

  void loadData({required int count}) async {
    _haveMoreData = true;
    final conversationResult = await _conversationService.getConversationList(
        nextSeq: _nextSeq, count: count);
    _nextSeq = conversationResult!.nextSeq ?? "";
    final conversationList = conversationResult.conversationList;
    if (conversationList != null) {
      if (conversationList.isEmpty || conversationList.length < count) {
        _haveMoreData = false;
      }
      final List<V2TimConversation?> combinedConversationList = [
        ..._conversationList,
        ...conversationList
      ];
      final List<V2TimConversation?> finalConversationList = await _lifeCycle
              ?.conversationListWillMount(combinedConversationList) ??
          combinedConversationList;
      _conversationList = removeDuplicates<V2TimConversation?>(
          finalConversationList,
          (item1, item2) => item1?.conversationID == item2?.conversationID);
      notifyListeners();
    }
  }

  void setSelectedConversation(V2TimConversation conversation) {
    _selectedConversation = conversation;
  }

  pinConversation({
    required String conversationID,
    required bool isPinned,
  }) {
    return _conversationService.pinConversation(
        conversationID: conversationID, isPinned: isPinned);
  }

  clearHistoryMessage({required String convID, required int convType}) async {
    if (_lifeCycle?.shouldClearHistoricalMessageForConversation != null &&
        await _lifeCycle!.shouldClearHistoricalMessageForConversation(convID) ==
            false) {
      return null;
    }
    if (convType == 1) {
      _messageService.clearC2CHistoryMessage(userID: convID);
    } else {
      _messageService.clearGroupHistoryMessage(groupID: convID);
    }
  }

  searchFriends(String searchKey) async {
    final res = await _friendshipServices.searchFriends(
        searchParam: V2TimFriendSearchParam(keywordList: [searchKey]));
    return res;
  }

  Future<V2TimCallback?> deleteConversation(
      {required String conversationID}) async {
    if (_lifeCycle?.shouldDeleteConversation != null &&
        await _lifeCycle!.shouldDeleteConversation(conversationID) == false) {
      return null;
    }
    final res = await _conversationService.deleteConversation(
        conversationID: conversationID);
    if (res.code == 0) {
      _conversationList
          .removeWhere((element) => element?.conversationID == conversationID);
      notifyListeners();
    }
    return res;
  }

  _onConversationListChanged(List<V2TimConversation> list) {
    for (int element = 0; element < list.length; element++) {
      int index = _conversationList.indexWhere(
          (item) => item!.conversationID == list[element].conversationID);
      if (index > -1) {
        _conversationList.setAll(index, [list[element]]);
      } else {
        _conversationList.add(list[element]);
      }
      // ignore: todo
    } // TODO

    notifyListeners();
  }

  _addNewConversation(List<V2TimConversation> list) {
    _conversationList.addAll(list);
    _conversationList = removeDuplicates<V2TimConversation?>(_conversationList,
        (item1, item2) => item1?.conversationID == item2?.conversationID);
    notifyListeners();
  }

  setConversationListener({V2TimConversationListener? listener}) {
    _conversationListener = V2TimConversationListener(
      onConversationChanged: (conversationList) {
        _onConversationListChanged(conversationList);
        if (listener != null) {
          listener.onConversationChanged(conversationList);
        }
      },
      onNewConversation: (conversationList) {
        _addNewConversation(conversationList);
        if (listener != null) {
          listener.onNewConversation(conversationList);
        }
      },
      onSyncServerFailed: () {
        if (listener != null) {
          listener.onSyncServerFailed();
        }
      },
      onSyncServerFinish: () {
        if (listener != null) {
          listener.onSyncServerFinish();
        }
      },
      onSyncServerStart: () {
        if (listener != null) {
          listener.onSyncServerStart();
        }
      },
      onTotalUnreadMessageCountChanged: (totalunread) {
        if (listener != null) {
          listener.onTotalUnreadMessageCountChanged(totalunread);
        }
        _chatViewModel.totalUnReadCount = totalunread;
      },
    );

    if (_conversationListener != null) {
      _conversationService.setConversationListener(
          listener: _conversationListener!);
    }
  }

  removeConversationListener() {
    _conversationService.removeConversationListener(
        listener: _conversationListener);
  }

  setConversationDraft(
      {required String conversationID, String? draftText}) async {
    return _conversationService.setConversationDraft(
        conversationID: conversationID, draftText: draftText);
  }

  clear() {
    _conversationList = [];
    _selectedConversation = null;
    _nextSeq = "0";
    _haveMoreData = true;
  }
}
