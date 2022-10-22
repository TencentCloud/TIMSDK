## 0.1.8

* Optimize: File batch downloading queue, allow click multiple file messages once.
* Optimize: Group list widgets can be updated automatically.
* Optimize: Camera capture supports relatively lower performance devices, adjust resolution automatically. 
* Optimize: Supports customize the color and text style of the app bar, especially on TIMUIKitChat widget.
* Fix: Friend remark or nickname can not show on group tips.
* Fix: Crash on video playing.
* Fix: Several bugs.

## 0.1.7

* Add: Big and RAW images supports, especially for those captured from latest version of iOS and iPhone 14 Pro series, compress and format before sending automatically.
* Optimize: Performance and stability, especially for history message list and launching.
* Optimize: Makes initializing the `TIMUIKitChat` an idempotent operation.
* Optimize: Load latest messages when scrolling back to bottom.
* Optimize: Supports Flutter both 2.x and 3.x series.
* Fix: The issue of select photos permission.
* Fix: Several bugs.

## 0.1.5

* Add: Web supports. Now, you could implement TUIKit on iOS/Android/Web platforms.
* Add: Disk storage checking after log in, and controls in `config` of `init`.
* Add: `timeDividerConfig`, `notificationAndroidSound`, `isSupportMarkdownForTextMessage` and `onTapLink` to `TIMUIKitChatConfig`.
* Remove: The default Emoji list, due to the copyright issues. You can provided your own sticker list to panel by [tim_ui_kit_sticker_plugin](https://pub.dev/packages/tim_ui_kit_sticker_plugin).
* Optimize: You could now choose to disable Markdown parsing for text messages.
* Optimize: You could now choose to disable the shows for @ message in conversation list.
* Optimize: You could now return `null` for `notificationExt`/`notificationBody` in `TIMUIKitChatConfig` and `messageRowBuilder` in `MessageItemBuilder`, to use default value up to your needs in the specific case, means you can control whether or not using customized setting based on the provided situation, without the necessary to re-define the same logic as the TUIKit in your code.
* Optimize: Supports multiple lines for text messages.
* Optimize: Rebuild and improve the experience of `TIMUIKitChat`. While, `TIMUIKitChatController` needs to be specified to `controller` here, like how we shows in [Demo](https://github.com/TencentCloud/TIMSDK/blob/master/Flutter/Demo/im-flutter-uikit/lib/src/chat.dart).
* Fix: Several bugs.

## 0.1.3

* Add: User inputting status.
* Add: Message reactions, with sticker.
* Add: User online status.

## 0.1.2

* Upgrade: flutter_record_plugin_plus to 0.0.4.

## 0.1.1

* Add: Lifecycle hooks for the main widgets, referring to the parameter description for details.
* Add: Mute status display for group chat on the chat page.
* Add: URL enrichment for text messages.
* Add: Callback for global information (Flutter Error, Tips for Reminds, API Error) and you can display toast up to your needs.
* Optimize: Image preview displaying.
* Rebuild: TUIKitGroupProfile and TUIKitProfile, simplified usage.

## 0.1.0-bugfix

* Upgrade: Tencent IM SDK.

## 0.1.0

* Add: Atomization widgets for TIMUIKitChat.
* Add: Updating the UI when the message has been modified.
* Add: The application page for joining the group.
* Add: `updateMessage` API, users can refresh the view after modifying the local message.
* Add: Support for Traditional Chinese.
* Add: Customization for conversation list item.

## 0.0.9

* Add: Offline push along with [tim_ui_kit_push_plugin](https://pub.dev/packages/tim_ui_kit_push_plugin).
* Adapt: Flutter 3.0.0.
* Optimize: Local preview of multimedia files.

## 0.0.8

* Add: Group read receipt module.
* Add: Little tongue on the message list.
* Add: Examples.
* Fix: Several bugs.

## 0.0.7

* Fix: Several bugs.

## 0.0.6

* Add: New `sendMessage` method to the controller `TIMUIKitChatController` for TIMUIKitChat.
* Add: Configuration for TIMUIKitChat, which can control the functions for TIMUIKitChat components.
* Support: Customized for more panel customized ability to TIMUIKitChat.
* Optimize: User authorization standardized.

## 0.0.5

* Add: Several new customized configs, includes, appBarConfig, morePanelConfig, and removed appBarActions config.
* Optimize: Image preview displaying.
* Upgrade: Tencent IM SDK.
* Fix: The issue of conversation item duplication for TIMUIKitConversation.

## 0.0.4

* Optimize: TIMUIKitChat, especially for media files selector.
* Optimize: Previewing of image messages, video messages.
* Optimize: Theme color.
* Optimize: UI for search components.
* Upgrade: Tencent IM SDK.

## 0.0.3

* Add: TIMUIKitSearch and TIMUIKitSearchMsgDetail, supports searching both in conversation and globally.
* Add: TIMUIKitAddFriend.
* Add: TIMUIKitAddGroup.
* Add: Theme style configuration.
* Optimize: Internationalization.

## 0.0.2

* Optimize: TIMUIKitChat.
* Fix: Bugs on Internationalization.

## 0.0.1

The first released of TUIKit for Flutter of Tencent Cloud IM, the component of the first phase includes:

* TIMUIKitCore: The main entrance of the whole TUIKit.
* TIMUIKitConversation: Conversation list.
* TIMUIKitChat: Chat and historical message list.
* TIMUIKitProfile: User detail profile and relationship management.
* TIMUIKitGroupProfile: Group details and management.
* TIMUIKitGroup: Joined group list.
* TIMUIKitBlackList: Blocklist.
* TIMUIKitContact: Contacts list.
* TIMUIKitNewContact: New contact application list.