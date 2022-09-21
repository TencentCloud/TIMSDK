import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

enum GroupReceptAllowType { work, public, meeting }

enum GroupReceiptAllowType { work, public, meeting }

enum UrlPreviewType { none, onlyHyperlink, previewCardAndHyperlink }

class TimeDividerConfig {
  /// Defines the interval of adding a time divider among the two messages.
  /// [Unit]: second.
  /// [Default]: 300.
  final int? timeInterval;

  /// Defines the parser of a specific timestamp,
  /// transform it into a semantic time description.
  final String Function(int timeStamp)? timestampParser;

  TimeDividerConfig({this.timeInterval, this.timestampParser});
}

class TIMUIKitChatConfig {
  /// Customize the time divider among the two messages.
  final TimeDividerConfig? timeDividerConfig;

  /// control if allowed to show reading status.
  /// [Default]: true.
  final bool isShowReadingStatus;

  /// Control if allowed to show reading status for group.
  /// [Default]: true.
  final bool isShowGroupReadingStatus;

  /// Control if allowed to report reading status for group.
  /// [Default]: true.
  final bool isReportGroupReadingStatus;

  /// Control if allowed to show the menu after long pressing message.
  /// [Default]: true.
  final bool isAllowLongPressMessage;

  /// Control if allowed to callback after clicking the avatar.
  /// [Default]: true.
  final bool isAllowClickAvatar;

  /// Control if allowed to show emoji face message panel.
  /// [Default]: true.
  final bool isAllowEmojiPanel;

  /// Control if allowed to show more plus panel.
  /// [Default]: true.
  final bool isAllowShowMorePanel;

  /// Control if allowed to send voice sound message.
  /// [Default]: true.
  final bool isAllowSoundMessage;

  /// Control if allowed to at when reply automatically.
  /// [Default]: true.
  final bool isAtWhenReply;

  /// The main switch of the group read receipt.
  final bool isShowGroupMessageReadReceipt;

  /// [Deprecated: ] Please use [groupReadReceiptPermissionList] instead.
  final List<GroupReceptAllowType>? groupReadReceiptPermisionList;

  /// Control which group can send message read receipt.
  final List<GroupReceiptAllowType>? groupReadReceiptPermissionList;

  /// Control if show self name in group chat.
  /// [Default]: false.
  final bool isShowSelfNameInGroup;

  /// Control if others name in group chat.
  /// [Default]: true.
  final bool isShowOthersNameInGroup;

  /// The title shows in push notification
  final String notificationTitle;

  /// The channel ID for OPPO in push notification.
  final String notificationOPPOChannelID;

  /// The notification sound in iOS devices.
  /// When `iOSSound` = `kIOSOfflinePushNoSound`, the sound will not play when message received. When `iOSSound` = `kIOSOfflinePushDefaultSound`, the system sound is played when message received. If you want to customize `iOSSound`, you need to link the voice file into the Xcode project, and then set the voice file name (with a suffix) to iOSSound.
  final String notificationIOSSound;

  /// The notification sound in Android devices.
  final String notificationAndroidSound;

  /// The body content shows in push notification.
  /// Returning `null` means using default body in this case.
  final String? Function(
      V2TimMessage message, String convID, ConvType convType)? notificationBody;

  /// External information (String) for notification message, recommend used for jumping to target conversation with JSON format,
  /// Returning `null` means using default ext in this case.
  final String? Function(
      V2TimMessage message, String convID, ConvType convType)? notificationExt;

  /// The type of URL preview level, none preview, only hyperlink in text, or shows a preview card for website.
  /// [Default]: UrlPreviewType.previewCardAndHyperlink.
  final UrlPreviewType urlPreviewType;

  /// Whether to display the sending status of c2c messages
  /// [Default]: true.
  final bool showC2cMessageEditStaus;

  /// Control if take emoji stickers as message reaction.
  /// [Default]: true.
  final bool isUseMessageReaction;

  /// Determine how long a message is allowed to be recalled after it is sent.
  /// You must modify the configuration on control dashboard synchronized at: https://console.cloud.tencent.com/im/login-message.
  /// [Unit]: second.
  /// [Default]: 120.
  final int upperRecallTime;

  /// The prefix of face sticker URI.
  final String Function(String data)? faceURIPrefix;

  /// The suffix of face sticker URI.
  final String Function(String data)? faceURISuffix;

  /// Control if text and replied messages can be show with markdown.
  /// [Default]: false.
  final bool isSupportMarkdownForTextMessage;

  /// The callback after user clicking the URL link in text messages.
  /// The default action is opening the link with the default browser of system.
  final void Function(String url)? onTapLink;

  const TIMUIKitChatConfig({
    this.onTapLink,
    this.timeDividerConfig,
    this.faceURIPrefix,
    this.faceURISuffix,
    this.isAtWhenReply = true,
    this.notificationAndroidSound = "",
    this.isSupportMarkdownForTextMessage = false,
    this.notificationExt,
    this.isUseMessageReaction = true,
    this.isShowSelfNameInGroup = false,
    @Deprecated("Please use [isShowGroupReadingStatus] instead")
        this.isShowGroupMessageReadReceipt = true,
    this.upperRecallTime = 120,
    this.isShowOthersNameInGroup = true,
    this.urlPreviewType = UrlPreviewType.onlyHyperlink,
    this.notificationBody,
    this.notificationOPPOChannelID = "",
    this.notificationTitle = "",
    this.notificationIOSSound = "",
    this.isAllowSoundMessage = true,
    @Deprecated("Please use [groupReadReceiptPermissionList] instead")
        this.groupReadReceiptPermisionList,
    this.groupReadReceiptPermissionList,
    this.isAllowEmojiPanel = true,
    this.isAllowShowMorePanel = true,
    this.isShowReadingStatus = true,
    this.isAllowLongPressMessage = true,
    this.isAllowClickAvatar = true,
    this.isShowGroupReadingStatus = true,
    this.isReportGroupReadingStatus = true,
    this.showC2cMessageEditStaus = true,
  });
}
