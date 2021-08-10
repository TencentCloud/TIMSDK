// void 	onSyncServerStart ()

// void 	onSyncServerFinish ()

// void 	onSyncServerFailed ()

// void 	onNewConversation (List< V2TIMConversation > conversationList)

// void 	onConversationChanged (List< V2TIMConversation > conversationList)
//
//
import 'package:tencent_im_sdk_plugin/enum/callbacks.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';

class V2TimConversationListener {
  VoidCallback onSyncServerStart = () {};
  VoidCallback onSyncServerFinish = () {};
  VoidCallback onSyncServerFailed = () {};
  OnNewConversationCallback onNewConversation = (
    List<V2TimConversation> conversationList,
  ) {};
  OnConversationChangedCallback onConversationChanged = (
    List<V2TimConversation> conversationList,
  ) {};
  V2TimConversationListener({
    VoidCallback? onSyncServerStart,
    VoidCallback? onSyncServerFinish,
    VoidCallback? onSyncServerFailed,
    OnNewConversationCallback? onNewConversation,
    OnConversationChangedCallback? onConversationChanged,
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
  }
}
