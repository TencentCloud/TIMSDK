import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/utils/toast.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_group.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:flutter/material.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';

class TestApi extends StatefulWidget {
  const TestApi({Key? key}) : super(key: key);

  @override
  _TestApiState createState() => _TestApiState();
}

class _TestApiState extends State<TestApi> {
  @override
  void initState() {
    super.initState();
    // initSDK();

    // tologin();
  }

  tologin() async {
    const userId = "lexuslin";
    const userSig = "";
    await TencentImSDKPlugin.v2TIMManager.login(
      userID: userId,
      userSig: userSig,
    );
    await TencentImSDKPlugin.v2TIMManager.getUsersInfo(userIDList: [userId]);
  }

  // getJoinedGroupList() async {
  //   V2TimValueCallback<List<V2TimGroupInfo>> res =
  //     await TencentImSDKPlugin.v2TIMManager.getGroupManager().getJoinedGroupList();
  //   Utils.log(res.toJson());
  // }
  unInitSDK() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.unInitSDK();
    Utils.log(res.toJson());
  }

  getVersion() async {
    V2TimValueCallback<String> res =
        await TencentImSDKPlugin.v2TIMManager.getVersion();
    Utils.log(res.toJson());
  }

  getServerTime() async {
    V2TimValueCallback<int> res =
        await TencentImSDKPlugin.v2TIMManager.getServerTime();
    Utils.log(res.toJson());
  }

  getLoginStatus() async {
    V2TimValueCallback<int> res =
        await TencentImSDKPlugin.v2TIMManager.getLoginStatus();
    Utils.log(res.toJson());
  }

  // todo
  removeSimpleMsgListener() async {
    // TencentImSDKPlugin.v2TIMManager.removeSimpleMsgListener();
  }

  dismissGroup() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .dismissGroup(groupID: "@TGS#2Z5J252GW");
    Utils.log(res.toJson());
  }

  // setGroupInfo() async {
  //   V2TimCallback res =
  //     await TencentImSDKPlugin.v2TIMManager.getGroupManager().setGroupInfo(
  //       groupID: "xxx",
  //       groupName: "xxxx"
  //     );
  //   Utils.log(res.toJson());
  // }

  // 0接收且推送，1不接收，2在线接收离线不推送
  setReceiveMessageOpt() async {
    // V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
    //     .getMessageManager()
    //     .(groupID: "@TGS#2DWCNB3GH", opt: 0);
    // Utils.log(res.toJson());
  }

  createGroup() async {
    V2TimValueCallback<String> res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .createGroup(groupID: "g1234", groupName: "g1234", groupType: "Public");
    Utils.log(res.toJson());
  }

  // 仅支持AVChatRoom
  initGroupAttributes() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .initGroupAttributes(
            groupID: "testavchatroom2", attributes: {"a": "1", "b": "2"});
    Utils.log(res.toJson());
  }

  setGroupAttributes() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupAttributes(
            groupID: "testavchatroom2", attributes: {"a": "1222", "b": "2333"});
    Utils.log(res.toJson());
  }

  deleteGroupAttributes() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .deleteGroupAttributes(groupID: "testavchatroom2", keys: ["b"]);
    Utils.log(res.toJson());
  }

  getGroupAttributes() async {
    V2TimValueCallback<Map<String, String>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getGroupManager()
        .getGroupAttributes(groupID: "testavchatroom2", keys: ["a", "b"]);
    Utils.log(res.toJson());
  }

  getGroupOnlineMemberCount() async {
    V2TimValueCallback<int> res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .getGroupOnlineMemberCount(groupID: "av111");
    Utils.log(res.toJson());
  }

  getGroupMembersInfo() async {
    V2TimValueCallback<List<V2TimGroupMemberFullInfo>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupMembersInfo(
                groupID: "@TGS#2DWCNB3GH", memberList: ["lexuslin3"]);
    Utils.log(res.toJson());
  }

  setGroupMemberInfo() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupMemberInfo(
            groupID: "@TGS#2DWCNB3GH", userID: "lexuslin3", nameCard: "aaaa");
    Utils.log(res.toJson());
  }

  muteGroupMember() async {
    V2TimCallback res =
        await TencentImSDKPlugin.v2TIMManager.getGroupManager().muteGroupMember(
              groupID: "@TGS#2DWCNB3GH",
              userID: "lexuslin3",
              seconds: 600,
            );
    Utils.log(res.toJson());
  }

  inviteUserToGroup() async {
    V2TimValueCallback<List<V2TimGroupMemberOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .inviteUserToGroup(
                groupID: "@TGS#1ZBXOB3G5", userList: ["lexuslin2"]);
    Utils.log(res.toJson());
  }

  kickGroupMember() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .kickGroupMember(
            groupID: "@TGS#1ZBXOB3G5",
            memberList: ["lexuslin3"],
            reason: "你不太行");
    Utils.log(res.toJson());
  }

  // 200成员，300管理员，400群主
  setGroupMemberRole() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupMemberRole(
          groupID: "@TGS#1ZBXOB3G5",
          userID: "lexuslin2",
          role: GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_ADMIN,
        );
    Utils.log(res.toJson());
  }

  transferGroupOwner() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .transferGroupOwner(groupID: "@TGS#1ZBXOB3G5", userID: "lexuslin3");
    Utils.log(res.toJson());
  }

  setGroupApplicationRead() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupApplicationRead();
    Utils.log(res.toJson());
  }

  checkFriend() async {
    // V2TimValueCallback<V2TimFriendCheckResult> res = await TencentImSDKPlugin
    //     .v2TIMManager
    //     .getFriendshipManager()
    //     .checkFriend(List.from(['lexuslin3']), 1);
    // Utils.log(res.toJson());
  }

  // type?
  deleteFriendApplication() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .deleteFriendApplication(
          userID: "lexuslin3",
          type: FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_BOTH,
        );
    Utils.log(res.toJson());
  }

  setFriendApplicationRead() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .setFriendApplicationRead();
    Utils.log(res.toJson());
  }

  createFriendGroup() async {
    V2TimValueCallback<List<V2TimFriendOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .createFriendGroup(groupName: "group3", userIDList: ["lexuslin3"]);
    Utils.log(res.toJson());
  }

  // ios方法名，getFriendGroupList
  getFriendGroups() async {
    V2TimValueCallback<List<V2TimFriendGroup>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getFriendshipManager()
        .getFriendGroups(groupNameList: null);
    Utils.log(res.toJson());
  }

  deleteFriendGroup() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .deleteFriendGroup(groupNameList: ["group2"]);
    Utils.log(res.toJson());
  }

  renameFriendGroup() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .renameFriendGroup(oldName: "group3", newName: "group3new222");
    Utils.log(res.toJson());
  }

  addFriendsToFriendGroup() async {
    V2TimValueCallback<List<V2TimFriendOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .addFriendsToFriendGroup(
                groupName: "group3new222", userIDList: ["lexuslin2"]);
    Utils.log(res.toJson());
  }

  deleteFriendsFromFriendGroup() async {
    V2TimValueCallback<List<V2TimFriendOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .deleteFriendsFromFriendGroup(
                groupName: "group3new222", userIDList: ["lexuslin3"]);
    Utils.log(res.toJson());
  }

  setConversationDraft() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .setConversationDraft(conversationID: "ccccc", draftText: "会话草稿1");
    Utils.log(res.toJson());
  }

  removeAdvancedMsgListener() async {
    TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .removeAdvancedMsgListener();
  }

  revokeMessage() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .revokeMessage(msgID: "144115225971632901-1607914832-2133922461");
    Utils.log(res.toJson());
  }

  deleteMessageFromLocalStorage() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .deleteMessageFromLocalStorage(
            msgID: "144115225971632901-1608635550-1824306931");
    Utils.log(res.toJson());
  }

  deleteMessages() async {
    List<String> list = List.empty(growable: true);
    list.add("144115225971632901-1607682284-904218793");
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .deleteMessages(msgIDs: list);
    Utils.log(res.toJson());
  }

  insertGroupMessageToLocalStorage() async {
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .insertGroupMessageToLocalStorage(
            groupID: "g1234", sender: "13675", data: "mmmmmm2");
    Utils.log(res.toJson());
  }

  insertC2CMessageToLocalStorage() async {
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .insertC2CMessageToLocalStorage(
          data: "111test",
          userID: "lexuslin",
          sender: "13675",
        );

    Utils.log(res.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        shadowColor: hexToColor("ececec"),
        elevation: 1,
        title: const Text(
          "测试页",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, i) => Column(
          children: [
            const Text("Manager"),
            ElevatedButton(
              onPressed: unInitSDK,
              child: const Text("unInitSDK"),
            ),
            ElevatedButton(
              onPressed: getVersion,
              child: const Text("getVersion"),
            ),
            ElevatedButton(
              onPressed: getServerTime,
              child: const Text("getServerTime"),
            ),
            ElevatedButton(
              onPressed: getLoginStatus,
              child: const Text("getLoginStatus"),
            ),
            ElevatedButton(
              onPressed: removeSimpleMsgListener,
              child: const Text("removeSimpleMsgListener"),
            ),
            ElevatedButton(
              onPressed: dismissGroup,
              child: const Text("dismissGroup"),
            ),
            const Text("Group"),
            // ElevatedButton(
            //   onPressed: setGroupInfo,
            //   child: Text("setGroupInfo"),
            // ),
            ElevatedButton(
              onPressed: setReceiveMessageOpt,
              child: const Text("setReceiveMessageOpt"),
            ),
            ElevatedButton(
              onPressed: createGroup,
              child: const Text("createGroup"),
            ),
            ElevatedButton(
              onPressed: initGroupAttributes,
              child: const Text("initGroupAttributes"),
            ),
            ElevatedButton(
              onPressed: setGroupAttributes,
              child: const Text("setGroupAttributes"),
            ),
            ElevatedButton(
              onPressed: deleteGroupAttributes,
              child: const Text("deleteGroupAttributes"),
            ),
            ElevatedButton(
              onPressed: getGroupAttributes,
              child: const Text("getGroupAttributes"),
            ),
            ElevatedButton(
              onPressed: getGroupOnlineMemberCount,
              child: const Text("getGroupOnlineMemberCount"),
            ),
            ElevatedButton(
              onPressed: getGroupMembersInfo,
              child: const Text("getGroupMembersInfo"),
            ),
            ElevatedButton(
              onPressed: setGroupMemberInfo,
              child: const Text("setGroupMemberInfo"),
            ),
            ElevatedButton(
              onPressed: muteGroupMember,
              child: const Text("muteGroupMember"),
            ),
            ElevatedButton(
              onPressed: inviteUserToGroup,
              child: const Text("inviteUserToGroup"),
            ),
            ElevatedButton(
              onPressed: kickGroupMember,
              child: const Text("kickGroupMember"),
            ),
            ElevatedButton(
              onPressed: setGroupMemberRole,
              child: const Text("setGroupMemberRole"),
            ),
            ElevatedButton(
              onPressed: transferGroupOwner,
              child: const Text("transferGroupOwner"),
            ),
            ElevatedButton(
              onPressed: setGroupApplicationRead,
              child: const Text("setGroupApplicationRead"),
            ),
            const Text("Friend"),
            ElevatedButton(
              onPressed: checkFriend,
              child: const Text("checkFriend"),
            ),
            ElevatedButton(
              onPressed: deleteFriendApplication,
              child: const Text("deleteFriendApplication"),
            ),
            ElevatedButton(
              onPressed: setFriendApplicationRead,
              child: const Text("setFriendApplicationRead"),
            ),
            ElevatedButton(
              onPressed: createFriendGroup,
              child: const Text("createFriendGroup"),
            ),
            ElevatedButton(
              onPressed: getFriendGroups,
              child: const Text("getFriendGroups"),
            ),
            ElevatedButton(
              onPressed: deleteFriendGroup,
              child: const Text("deleteFriendGroup"),
            ),
            ElevatedButton(
              onPressed: renameFriendGroup,
              child: const Text("renameFriendGroup"),
            ),
            ElevatedButton(
              onPressed: addFriendsToFriendGroup,
              child: const Text("addFriendsToFriendGroup"),
            ),
            ElevatedButton(
              onPressed: deleteFriendsFromFriendGroup,
              child: const Text("deleteFriendsFromFriendGroup"),
            ),
            const Text("Conversation"),
            ElevatedButton(
              onPressed: setConversationDraft,
              child: const Text("setConversationDraft"),
            ),
            const Text("Message"),
            ElevatedButton(
              onPressed: removeAdvancedMsgListener,
              child: const Text("removeAdvancedMsgListener"),
            ),
            ElevatedButton(
              onPressed: revokeMessage,
              child: const Text("revokeMessage"),
            ),
            ElevatedButton(
              onPressed: deleteMessageFromLocalStorage,
              child: const Text("deleteMessageFromLocalStorage"),
            ),
            ElevatedButton(
              onPressed: deleteMessages,
              child: const Text("deleteMessages"),
            ),
            ElevatedButton(
              onPressed: insertGroupMessageToLocalStorage,
              child: const Text("insertGroupMessageToLocalStorage"),
            ),
            ElevatedButton(
              onPressed: insertC2CMessageToLocalStorage,
              child: const Text("insertC2CMessageToLocalStorage"),
            )
          ],
        ),
      ),
    );
  }
}
