import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

enum GroupReceptAllowType { work, public, meeting }

enum UrlPreviewType { none, onlyHyperlink, previewCardAndHyperlink }

class TIMUIKitChatConfig {
  /// control if allowed to show reading status.
  /// [Default]: true.
  final bool isShowReadingStatus;

  /// control if allowed to show reading status for group.
  /// [Default]: true.
  final bool isShowGroupReadingStatus;

  /// control if allowed to show the menu after long pressing message.
  /// [Default]: true.
  final bool isAllowLongPressMessage;

  /// control if allowed to callback after clicking the avatar.
  /// [Default]: true.
  final bool isAllowClickAvatar;

  /// control if allowed to show emoji face message panel.
  /// [Default]: true.
  final bool isAllowEmojiPanel;

  /// control if allowed to show more plus panel.
  /// [Default]: true.
  final bool isAllowShowMorePanel;

  /// control if allowed to send voice sound message.
  /// [Default]: true.
  final bool isAllowSoundMessage;

  /// control if allowed to at when reply automatically.
  /// [Default]: true.
  final bool isAtWhenReply;

  /// the main switch of the group read receipt
  final bool isShowGroupMessageReadReceipt;

  /// control which group can send message read receipt.
  final List<GroupReceptAllowType>? groupReadReceiptPermisionList;

  /// the title shows in push notification
  final String notificationTitle;

  /// the channel ID for OPPO in push notification.
  final String notificationOPPOChannelID;

  /// control if show self name in group chat.
  /// [Default]: false.
  final bool isShowSelfNameInGroup;

  /// control if others name in group chat.
  /// [Default]: true.
  final bool isShowOthersNameInGroup;

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

  /// The type of URL preview level, none preview, only hyperlink in text, or shows a preview card for website.
  /// [Default]: UrlPreviewType.previewCardAndHyperlink.
  final UrlPreviewType urlPreviewType;


  /// Whether to display the sending status of c2c messages
  /// [Default]: true.
  final bool showC2cMessageEditStaus;
  
  /// Control if take emoji stickers as message reaction.
  /// [Default]: true.
  final bool isUseMessageReaction;

  const TIMUIKitChatConfig(
      {this.isAtWhenReply = true,
      this.notificationExt,
      this.isUseMessageReaction = true,
      this.isShowSelfNameInGroup = false,
      this.isShowGroupMessageReadReceipt = true,
      this.isShowOthersNameInGroup = true,
      this.urlPreviewType = UrlPreviewType.previewCardAndHyperlink,
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
      this.isShowGroupReadingStatus = true,
      this.showC2cMessageEditStaus = true,
      });
}
