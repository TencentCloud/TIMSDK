// void 	onSyncServerStart ()

// void 	onSyncServerFinish ()

// void 	onSyncServerFailed ()

// void 	onNewConversation (List< V2TIMConversation > conversationList)

// ignore_for_file: file_names, prefer_function_declarations_over_variables

// void 	onConversationChanged (List< V2TIMConversation > conversationList)
//
//
import 'package:tencent_im_sdk_plugin_platform_interface/enum/callbacks.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation.dart';

class V2TimConversationListener {
  VoidCallback onSyncServerStart = () {};
  VoidCallback onSyncServerFinish = () {};
  VoidCallback onSyncServerFailed = () {};
  OnNewConversation onNewConversation = (
    List<V2TimConversation> conversationList,
  ) {};
  OnConversationChangedCallback onConversationChanged = (
    List<V2TimConversation> conversationList,
  ) {};
  OnTotalUnreadMessageCountChanged onTotalUnreadMessageCountChanged = (
    int totalUnreadCount,
  ) {};
  V2TimConversationListener({
    VoidCallback? onSyncServerStart,
    VoidCallback? onSyncServerFinish,
    VoidCallback? onSyncServerFailed,
    OnNewConversation? onNewConversation,
    OnConversationChangedCallback? onConversationChanged,
    OnTotalUnreadMessageCountChanged? onTotalUnreadMessageCountChanged,
  }) {
    if (onSyncServerStart != null) {
      this.onSyncServerStart = onSyncServerStart;
    }
    if (onSyncServerFinish != null) {
      this.onSyncServerFinish = onSyncServerFinish;
    }
    if (onSyncServerFailed != null) {
      this.onSyncServerFailed = onSyncServerFailed;
    }
    if (onNewConversation != null) {
      this.onNewConversation = onNewConversation;
    }
    if (onConversationChanged != null) {
      this.onConversationChanged = onConversationChanged;
    }
    if (onTotalUnreadMessageCountChanged != null) {
      this.onTotalUnreadMessageCountChanged = onTotalUnreadMessageCountChanged;
    }
  }
}
