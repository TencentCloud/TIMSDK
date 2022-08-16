import 'package:flutter/cupertino.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

enum ProfileWidgetEnum {
  /// THe card shows the user info of a specific user.
  userInfoCard,

  /// The switch of if add another user to block list.
  /// This will not shows when friendship relation not exist as default.
  addToBlockListBar,

  /// The switch of if pin the one-to-one conversation to the top of the conversation list.
  /// This will not shows when friendship relation not exist as default.
  pinConversationBar,

  /// The switch of if mute the message notification from a specific user.
  /// This will not shows when friendship relation not exist as default.
  messageMute,

  /// The entrance to search page, please set the `onTap` callback yourself, to the search page with conversation ID.
  /// You can develop it with `TIMUIKitProfileWidget.searchBar`.
  searchBar,

  /// The bar shows the portrait.
  portraitBar,

  /// The bar shows the nickname of a specific user.
  nicknameBar,

  /// The bar shows the user account of a specific user.
  userAccountBar,

  /// The bar shows the signature of a specific user.
  signatureBar,

  /// The bar shows the gender of a specific user.
  /// 1 represent male, 2 represent female.
  genderBar,

  /// The bar shows the birthday of a specific user.
  /// Int like "19981112", means November 12, 1998.
  birthdayBar,

  /// The area shows the buttons,
  /// contains "Send message", "Voice/Video Call", "Delete friend" when has the friend relationship,
  /// while contains "Add friend" when no relationship exists, as default.
  addAndDeleteArea,

  /// The divider between sets of profile widget
  operationDivider,

  /// The setting of remark for a specific user.
  /// This will not shows when friendship relation not exist as default.
  remarkBar,

  /// Custom area, you may define send message, make calling, search or anything you want here.
  customBuilderOne,

  /// Custom area, you may define send message, make calling, search or anything you want here.
  customBuilderTwo,

  /// Custom area, you may define send message, make calling, search or anything you want here.
  customBuilderThree,

  /// Custom area, you may define send message, make calling, search or anything you want here.
  customBuilderFour,

  /// Custom area, you may define send message, make calling, search or anything you want here.
  customBuilderFive
}

typedef ProfileWidgetItemContent = Widget? Function(
  bool isShowJump,
  VoidCallback clearJump,
);

class ProfileWidgetBuilder {
  /// The divider between sets of profile widget
  Widget Function()? operationDivider;

  /// The setting of remark for a specific user
  Widget Function(String remark, Function()? handleTap)? remarkBar;

  /// The switch of if add another user to block list.
  /// This will not shows when friendship relation not exist as default.
  Widget Function(bool isAsBlocked, Function(bool value)? onChange)?
      addToBlockListBar;

  /// The switch of if pin the one-to-one conversation to the top of the conversation list.
  /// This will not shows when friendship relation not exist as default.
  Widget Function(bool isPinned, Function(bool value)? onChange)?
      pinConversationBar;

  /// The switch of if mute the message notification from a specific user.
  /// This will not shows when friendship relation not exist as default.
  Widget Function(bool isMute, Function(bool value)? onChange)? messageMute;

  /// Override the default operation item style for un-customized profile widget.
  Widget Function({
    required String operationName,
    required String type,
    bool? operationValue,
    String? operationText,
    void Function(bool newValue)? onSwitchChange,
  })? operationItem;

  /// The entrance to search page, please set the `onTap` callback yourself, to the search page with conversation ID.
  /// You can develop it with `TIMUIKitProfileWidget.searchBar`.
  Widget Function(V2TimConversation conversation)? searchBar;

  /// The bar shows the portrait.
  Widget Function(V2TimUserFullInfo? userInfo)? portraitBar;

  /// The bar shows the nickname of a specific user.
  Widget Function(String nickName)? nicknameBar;

  /// The bar shows the user account of a specific user.
  Widget Function(String userAccount)? userAccountBar;

  /// The bar shows the signature of a specific user.
  Widget Function(String signature)? signatureBar;

  /// The bar shows the gender of a specific user.
  /// 1 represent male, 2 represent female.
  Widget Function(int gender)? genderBar;

  /// The bar shows the birthday of a specific user.
  /// Int like "19981111", means November 11, 1998.
  Widget Function(int? birthday)? birthdayBar;

  /// THe card shows the user info of a specific user.
  Widget Function(V2TimUserFullInfo? userInfo)? userInfoCard;

  /// The area shows the buttons,
  /// contains "Send message", "Voice/Video Call", "Delete friend" when has the friend relationship,
  /// while contains "Add friend" when no relationship exists, as default.
  Widget Function(V2TimFriendInfo friendInfo, V2TimConversation conversation,
      int friendType, bool isDisturb)? addAndDeleteArea;

  /// Custom area, you may define send message, make calling, search or anything you want here.
  Widget Function(bool isFriend, V2TimFriendInfo friendInfo,
      V2TimConversation conversation)? customBuilderOne;

  /// Custom area, you may define send message, make calling, search or anything you want here.
  Widget Function(bool isFriend, V2TimFriendInfo friendInfo,
      V2TimConversation conversation)? customBuilderTwo;

  /// Custom area, you may define send message, make calling, search or anything you want here.
  Widget Function(bool isFriend, V2TimFriendInfo friendInfo,
      V2TimConversation conversation)? customBuilderThree;

  /// Custom area, you may define send message, make calling, search or anything you want here.
  Widget Function(bool isFriend, V2TimFriendInfo friendInfo,
      V2TimConversation conversation)? customBuilderFour;

  /// Custom area, you may define send message, make calling, search or anything you want here.
  Widget Function(bool isFriend, V2TimFriendInfo friendInfo,
      V2TimConversation conversation)? customBuilderFive;

  ProfileWidgetBuilder(
      {this.operationDivider,
      this.remarkBar,
      this.addToBlockListBar,
      this.pinConversationBar,
      this.messageMute,
      this.operationItem,
      this.searchBar,
      this.portraitBar,
      this.nicknameBar,
      this.userAccountBar,
      this.signatureBar,
      this.genderBar,
      this.birthdayBar,
      this.userInfoCard,
      this.addAndDeleteArea,
      this.customBuilderOne,
      this.customBuilderTwo,
      this.customBuilderThree,
      this.customBuilderFive,
      this.customBuilderFour});
}
