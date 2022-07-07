import 'package:flutter/cupertino.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

enum GroupProfileWidgetEnum {
  /// The detail card for group.
  detailCard,

  /// The tile shows the members in the group.
  memberListTile,

  /// The entrance to the page editing the group notice.
  groupNotice,

  /// The entrance to the page managing the group.
  /// Works only for group owner and group admin.
  groupManage,

  /// The entrance to the search page with conversation ID.
  searchMessage,

  /// The divider between sets of profile widget.
  operationDivider,

  /// Shows the group type,
  /// includes "work group", "public group", "meeting group" and "AVChatRoom".
  groupTypeBar,

  /// Shows and modify the mode or options users add the group.
  /// Includes "disallow group joining", "automatic approval" and "admin approval".
  groupJoiningModeBar,

  /// Shows and modify the nickname for user in a specific group,
  /// only shows and used in this group, as the name card here.
  nameCardBar,

  /// The switch of if mute the message notification from a specific group
  muteGroupMessageBar,

  /// The switch of if pin this group to the top in conversation list.
  pinedConversationBar,

  /// The button area, includes
  /// "clear chat history", "transfer group owner", "disband group" and "quit group"
  /// as default.
  buttonArea,

  /// Custom area, you may define anything you want here.
  customBuilderOne,

  /// Custom area, you may define anything you want here.
  customBuilderTwo,

  /// Custom area, you may define anything you want here.
  customBuilderThree,

  /// Custom area, you may define anything you want here.
  customBuilderFour,

  /// Custom area, you may define anything you want here.
  customBuilderFive
}

class GroupProfileWidgetBuilder {
  /// The detail card for group.
  Widget Function(V2TimGroupInfo groupInfo,
      Function(String updateGroupName)? updateGroupName)? detailCard;

  /// The tile shows the members in the group.
  Widget Function(List<V2TimGroupMemberFullInfo?> memberList)? memberListTile;

  /// The entrance to the page editing the group notice.
  Widget Function(String currentNotice, Function() toDefaultNoticeEditPage,
      Function(String newNotice) setGroupNotice)? groupNotice;

  /// The entrance to the page managing the group.
  /// Works only for group owner and group admin.
  Widget Function(Function() toDefaultGroupManagementPage)? groupManage;

  /// The entrance to the search page with conversation ID.
  Widget Function()? searchMessage;

  /// The divider between sets of profile widget.
  Widget Function()? operationDivider;

  /// Shows the group type,
  /// includes "work group", "public group", "meeting group" and "AVChatRoom".
  Widget Function(String groupType)? groupTypeBar;

  /// Shows and modify the mode or options users add the group.
  /// Includes "0: disallow group joining", "1: admin approval" and "2: automatic approval".
  Widget Function(int groupAddOptType, Function(int addOpt) handleActionTap)?
      groupJoiningModeBar;

  /// Shows and modify the nickname for user in a specific group,
  /// only shows and used in this group, as the name card here.
  Widget Function(String nameCard, Function(String newName) setNameCard)?
      nameCardBar;

  /// The switch of if mute the message notification from a specific group.
  Widget Function(bool isMute, Function(bool isMute) setMute)?
      muteGroupMessageBar;

  /// The switch of if pin this group to the top in conversation list.
  Widget Function(bool isPined, Function(bool isMute) pinedConversation)?
      pinedConversationBar;

  /// The button area, includes
  /// "clear chat history", "transfer group owner", "disband group" and "quit group"
  /// as default.
  Widget Function(V2TimGroupInfo groupInfo,
      List<V2TimGroupMemberFullInfo?> groupMemberList)? buttonArea;

  /// Custom area, you may define anything you want here.
  Widget Function(V2TimGroupInfo groupInfo,
      List<V2TimGroupMemberFullInfo?> groupMemberList)? customBuilderOne;

  /// Custom area, you may define anything you want here.
  Widget Function(V2TimGroupInfo groupInfo,
      List<V2TimGroupMemberFullInfo?> groupMemberList)? customBuilderTwo;

  /// Custom area, you may define anything you want here.
  Widget Function(V2TimGroupInfo groupInfo,
      List<V2TimGroupMemberFullInfo?> groupMemberList)? customBuilderThree;

  /// Custom area, you may define anything you want here.
  Widget Function(V2TimGroupInfo groupInfo,
      List<V2TimGroupMemberFullInfo?> groupMemberList)? customBuilderFour;

  /// Custom area, you may define anything you want here.
  Widget Function(V2TimGroupInfo groupInfo,
      List<V2TimGroupMemberFullInfo?> groupMemberList)? customBuilderFive;

  GroupProfileWidgetBuilder(
      {this.detailCard,
      this.memberListTile,
      this.groupNotice,
      this.groupManage,
      this.searchMessage,
      this.operationDivider,
      this.groupTypeBar,
      this.groupJoiningModeBar,
      this.nameCardBar,
      this.muteGroupMessageBar,
      this.pinedConversationBar,
      this.buttonArea,
      this.customBuilderOne,
      this.customBuilderTwo,
      this.customBuilderThree,
      this.customBuilderFour,
      this.customBuilderFive});
}
