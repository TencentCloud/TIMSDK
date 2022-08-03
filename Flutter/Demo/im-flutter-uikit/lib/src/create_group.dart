import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/chat.dart';
import 'package:timuikit/src/provider/theme.dart';

enum GroupTypeForUIKit { single, work, chat, meeting, public }

class CreateGroup extends StatefulWidget {
  final GroupTypeForUIKit convType;
  const CreateGroup({Key? key, required this.convType}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateGroup();
}

class _CreateGroup extends State<CreateGroup> {
  final V2TIMManager _sdkInstance = TIMUIKitCore.getSDKInstance();
  List<V2TimFriendInfo> friendList = [];
  List<V2TimFriendInfo> selectedFriendList = [];

  _getConversationList() async {
    final res = await _sdkInstance.getFriendshipManager().getFriendList();
    if (res.code == 0) {
      friendList = res.data!;
      setState(() {});
    }
  }

  _createSingleConversation() async {
    final userID = selectedFriendList.first.userID;
    final conversationID = "c2c_$userID";
    final res = await _sdkInstance
        .getConversationManager()
        .getConversation(conversationID: conversationID);

    if (res.code == 0) {
      final conversation = res.data;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(selectedConversation: conversation!)));
    }
  }

  _getShowName(V2TimFriendInfo item) {
    final friendRemark = item.friendRemark ?? "";
    final nickName = item.userProfile?.nickName ?? "";
    final userID = item.userID;
    final showName = nickName != "" ? nickName : userID;
    return friendRemark != "" ? friendRemark : showName;
  }

  bool _isValidGroupName(String groupName){
    final List<int> bytes = utf8.encode(groupName);
    return !(bytes.length > 30);
  }

  String _generateGroupName(){
    String groupName = selectedFriendList.map((e) => _getShowName(e)).join(", ");
    if(_isValidGroupName(groupName)){
      return groupName;
    }

    final option1 = selectedFriendList.length;
    groupName = _getShowName(selectedFriendList[0]) +
        imt_para(" 等{{option1}}人", " 等$option1人")(option1: option1);
    if(_isValidGroupName(groupName)){
      return groupName;
    }

    final option2 = selectedFriendList.length + 1;
    groupName = _getShowName(selectedFriendList[0]) +
        imt_para("{{option2}}人群", "$option2人群")(option2: option2);
    if(_isValidGroupName(groupName)){
      return groupName;
    }

    return imt("新群聊");
  }

  _createGroup(String groupType) async {
    String groupName = _generateGroupName();
    final groupMember = selectedFriendList.map((e) {
      final role = e.userProfile!.role!;
      GroupMemberRoleTypeEnum roleEnum =
          GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_UNDEFINED;
      switch (role) {
        case GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN:
          roleEnum = GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_ADMIN;
          break;
        case GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER:
          roleEnum = GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_MEMBER;
          break;
        case GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER:
          roleEnum = GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_OWNER;
          break;
        case GroupMemberRoleType.V2TIM_GROUP_MEMBER_UNDEFINED:
          roleEnum = GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_UNDEFINED;
          break;
      }

      return V2TimGroupMember(role: roleEnum, userID: e.userID);
    }).toList();
    final res = await _sdkInstance.getGroupManager().createGroup(
        groupType: groupType,
        groupName: groupName,
        memberList: groupType != GroupType.AVChatRoom ? groupMember : null);
    if (res.code == 0) {
      final groupID = res.data;
      final conversationID = "group_$groupID";
      final convRes = await _sdkInstance
          .getConversationManager()
          .getConversation(conversationID: conversationID);
      if (convRes.code == 0) {
        final conversation = convRes.data;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Chat(selectedConversation: conversation!)));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getConversationList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
      appBar: AppBar(
          title: Text(
            imt("选择联系人"),
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          shadowColor: theme.weakDividerColor,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                theme.primaryColor ?? CommonColor.primaryColor
              ]),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (selectedFriendList.isNotEmpty) {
                  switch (widget.convType) {
                    case GroupTypeForUIKit.single:
                      _createSingleConversation();
                      break;
                    case GroupTypeForUIKit.chat:
                      _createGroup(GroupType.AVChatRoom);
                      break;
                    case GroupTypeForUIKit.meeting:
                      _createGroup(GroupType.Meeting);
                      break;
                    case GroupTypeForUIKit.work:
                      _createGroup(GroupType.Work);
                      break;
                    case GroupTypeForUIKit.public:
                      _createGroup(GroupType.Public);
                      break;
                  }
                }
              },
              child: Text(
                imt("确定"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          ],
          iconTheme: const IconThemeData(
            color: Colors.white,
          )),
      body: ContactList(
        contactList: friendList,
        isCanSelectMemberItem: true,
        maxSelectNum: widget.convType == GroupTypeForUIKit.single ? 1 : null,
        onSelectedMemberItemChange: (selectedMember) {
          selectedFriendList = selectedMember;
          setState(() {});
        },
      ),
    );
  }
}
