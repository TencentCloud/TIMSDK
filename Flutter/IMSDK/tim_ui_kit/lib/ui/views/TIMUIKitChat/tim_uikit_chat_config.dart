import '../../../business_logic/view_models/tui_chat_view_model.dart';
import '../../../tim_ui_kit.dart';

enum GroupReceptAllowType { work, public, meeting }

class TIMUIKitChatConfig {
  /// control if allowed to show reading status
  final bool isShowReadingStatus;

  /// control if allowed to show reading status for group
  final bool isShowGroupReadingStatus;

  /// control if allowed to show the menu after long pressing message
  final bool isAllowLongPressMessage;

  /// control if allowed to callback after clicking the avatar
  final bool isAllowClickAvatar;

  /// control if allowed to show emoji face message panel
  final bool isAllowEmojiPanel;

  /// control if allowed to show more plus panel
  final bool isAllowShowMorePanel;

  /// control if allowed to send voice sound message
  final bool isAllowSoundMessage;

  /// control if allowed to at when reply automatically
  final bool isAtWhenReply;

  /// control which group can send message read receipt.
  final List<GroupReceptAllowType>? groupReadReceiptPermisionList;

  /// the title shows in push notification
  final String notificationTitle;

  /// the channel ID for OPPO in push notification
  final String notificationOPPOChannelID;

  /// the notification sound in iOS devices
  /// When `iOSSound` = `kIOSOfflinePushNoSound`, the sound will not play when message received. When `iOSSound` = `kIOSOfflinePushDefaultSound`, the system sound is played when message received. If you want to customize `iOSSound`, you need to link the voice file into the Xcode project, and then set the voice file name (with a suffix) to iOSSound.
  final String notificationIOSSound;

  /// the body content shows in push notification
  final String Function(V2TimMessage message, String convID, ConvType convType)?
      notificationBody;

  /// external information (String) for notification message, recommend used for jumping to target conversation,
  /// default is the conversation ID if do not provide
  final String Function(V2TimMessage message, String convID, ConvType convType)?
      notificationExt;

  const TIMUIKitChatConfig(
      {this.isAtWhenReply = true,
      this.notificationExt,
      this.notificationBody,
      this.notificationOPPOChannelID = "",
      this.notificationTitle = "",
      this.notificationIOSSound = "",
      this.isAllowSoundMessage = true,
      this.groupReadReceiptPermisionList,
      this.isAllowEmojiPanel = true,
      this.isAllowShowMorePanel = true,
      this.isShowReadingStatus = true,
      this.isAllowLongPressMessage = true,
      this.isAllowClickAvatar = true,
      this.isShowGroupReadingStatus = true});
}
