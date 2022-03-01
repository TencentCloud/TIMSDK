import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/conversation/conversation_services.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TUIConversationViewModel extends ChangeNotifier {
  final ConversationService _conversationService =
      serviceLocator<ConversationService>();
  final TUIChatViewModel _chatViewModel = serviceLocator<TUIChatViewModel>();

  final MessageService _messageService = serviceLocator<MessageService>();

  List<V2TimConversation?> _conversationList = [];
  static V2TimConversation? _selectedConversation;
  String _nextSeq = "0";

  List<V2TimConversation?> get conversationList {
    _conversationList.sort((a, b) => b!.orderkey!.compareTo(a!.orderkey!));
    return _conversationList;
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
    final conversationResult = await _conversationService.getConversationList(
        nextSeq: _nextSeq, count: count);
    _nextSeq = conversationResult!.nextSeq ?? "";
    final conversationList = conversationResult.conversationList;
    if (conversationList != null) {
      _conversationList = [..._conversationList, ...conversationList];
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

  clearHistoryMessage({required String convID, required int convType}) {
    if (convType == 1) {
      _messageService.clearC2CHistoryMessage(userID: convID);
    } else {
      _messageService.clearGroupHistoryMessage(groupID: convID);
    }
  }

  deleteConversation({required String conversationID}) {
    _conversationService.deleteConversation(conversationID: conversationID);
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
    }

    notifyListeners();
  }

  _addNewConversation(List<V2TimConversation> list) {
    _conversationList.addAll(list);
    notifyListeners();
  }

  setConversationListener({V2TimConversationListener? listener}) {
    final convListener =
        V2TimConversationListener(onConversationChanged: (conversationList) {
      _onConversationListChanged(conversationList);
      if (listener != null) {
        listener.onConversationChanged(conversationList);
      }
    }, onNewConversation: (conversationList) {
      _addNewConversation(conversationList);
      if (listener != null) {
        listener.onNewConversation(conversationList);
      }
    }, onSyncServerFailed: () {
      if (listener != null) {
        listener.onSyncServerFailed();
      }
    }, onSyncServerFinish: () {
      if (listener != null) {
        listener.onSyncServerFinish();
      }
    }, onSyncServerStart: () {
      if (listener != null) {
        listener.onSyncServerStart();
      }
    }, onTotalUnreadMessageCountChanged: (totalunread) {
      if (listener != null) {
        listener.onTotalUnreadMessageCountChanged(totalunread);
      }
      _chatViewModel.totalUnReadCount = totalunread;
    });

    _conversationService.setConversationListener(listener: convListener);
  }

  clear() {
    _conversationList = [];
    _selectedConversation = null;
    _nextSeq = "0";
  }
}
