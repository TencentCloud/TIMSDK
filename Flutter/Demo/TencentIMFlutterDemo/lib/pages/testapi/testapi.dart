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
  @override
  _TestApiState createState() => _TestApiState();
}

class _TestApiState extends State<TestApi> {
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
  //   print(res.toJson());
  // }
  unInitSDK() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.unInitSDK();
    print(res.toJson());
  }

  getVersion() async {
    V2TimValueCallback<String> res =
        await TencentImSDKPlugin.v2TIMManager.getVersion();
    print(res.toJson());
  }

  getServerTime() async {
    V2TimValueCallback<int> res =
        await TencentImSDKPlugin.v2TIMManager.getServerTime();
    print(res.toJson());
  }

  getLoginStatus() async {
    V2TimValueCallback<int> res =
        await TencentImSDKPlugin.v2TIMManager.getLoginStatus();
    print(res.toJson());
  }

  // todo
  removeSimpleMsgListener() async {
    TencentImSDKPlugin.v2TIMManager.removeSimpleMsgListener();
  }

  dismissGroup() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .dismissGroup(groupID: "@TGS#2Z5J252GW");
    print(res.toJson());
  }

  // setGroupInfo() async {
  //   V2TimCallback res =
  //     await TencentImSDKPlugin.v2TIMManager.getGroupManager().setGroupInfo(
  //       groupID: "xxx",
  //       groupName: "xxxx"
  //     );
  //   print(res.toJson());
  // }

  // 0接收且推送，1不接收，2在线接收离线不推送
  setReceiveMessageOpt() async {
    // V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
    //     .getMessageManager()
    //     .(groupID: "@TGS#2DWCNB3GH", opt: 0);
    // print(res.toJson());
  }

  createGroup() async {
    V2TimValueCallback<String> res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .createGroup(groupID: "g1234", groupName: "g1234", groupType: "Public");
    print(res.toJson());
  }

  // 仅支持AVChatRoom
  initGroupAttributes() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .initGroupAttributes(
            groupID: "testavchatroom2", attributes: {"a": "1", "b": "2"});
    print(res.toJson());
  }

  setGroupAttributes() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupAttributes(
            groupID: "testavchatroom2", attributes: {"a": "1222", "b": "2333"});
    print(res.toJson());
  }

  deleteGroupAttributes() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .deleteGroupAttributes(groupID: "testavchatroom2", keys: ["b"]);
    print(res.toJson());
  }

  getGroupAttributes() async {
    V2TimValueCallback<Map<String, String>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getGroupManager()
        .getGroupAttributes(groupID: "testavchatroom2", keys: ["a", "b"]);
    print(res.toJson());
  }

  getGroupOnlineMemberCount() async {
    V2TimValueCallback<int> res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .getGroupOnlineMemberCount(groupID: "av111");
    print(res.toJson());
  }

  getGroupMembersInfo() async {
    V2TimValueCallback<List<V2TimGroupMemberFullInfo>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupMembersInfo(
                groupID: "@TGS#2DWCNB3GH", memberList: ["lexuslin3"]);
    print(res.toJson());
  }

  setGroupMemberInfo() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupMemberInfo(
            groupID: "@TGS#2DWCNB3GH", userID: "lexuslin3", nameCard: "aaaa");
    print(res.toJson());
  }

  muteGroupMember() async {
    V2TimCallback res =
        await TencentImSDKPlugin.v2TIMManager.getGroupManager().muteGroupMember(
              groupID: "@TGS#2DWCNB3GH",
              userID: "lexuslin3",
              seconds: 600,
            );
    print(res.toJson());
  }

  inviteUserToGroup() async {
    V2TimValueCallback<List<V2TimGroupMemberOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .inviteUserToGroup(
                groupID: "@TGS#1ZBXOB3G5", userList: ["lexuslin2"]);
    print(res.toJson());
  }

  kickGroupMember() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .kickGroupMember(
            groupID: "@TGS#1ZBXOB3G5",
            memberList: ["lexuslin3"],
            reason: "你不太行");
    print(res.toJson());
  }

  // 200成员，300管理员，400群主
  setGroupMemberRole() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupMemberRole(
            groupID: "@TGS#1ZBXOB3G5", userID: "lexuslin2", role: 300);
    print(res.toJson());
  }

  transferGroupOwner() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .transferGroupOwner(groupID: "@TGS#1ZBXOB3G5", userID: "lexuslin3");
    print(res.toJson());
  }

  setGroupApplicationRead() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupApplicationRead();
    print(res.toJson());
  }

  checkFriend() async {
    // V2TimValueCallback<V2TimFriendCheckResult> res = await TencentImSDKPlugin
    //     .v2TIMManager
    //     .getFriendshipManager()
    //     .checkFriend(List.from(['lexuslin3']), 1);
    // print(res.toJson());
  }

  // type?
  deleteFriendApplication() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .deleteFriendApplication(userID: "lexuslin3", type: 1);
    print(res.toJson());
  }

  setFriendApplicationRead() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .setFriendApplicationRead();
    print(res.toJson());
  }

  createFriendGroup() async {
    V2TimValueCallback<List<V2TimFriendOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .createFriendGroup(groupName: "group3", userIDList: ["lexuslin3"]);
    print(res.toJson());
  }

  // ios方法名，getFriendGroupList
  getFriendGroups() async {
    V2TimValueCallback<List<V2TimFriendGroup>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getFriendshipManager()
        .getFriendGroups(groupNameList: null);
    print(res.toJson());
  }

  deleteFriendGroup() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .deleteFriendGroup(groupNameList: ["group2"]);
    print(res.toJson());
  }

  renameFriendGroup() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .renameFriendGroup(oldName: "group3", newName: "group3new222");
    print(res.toJson());
  }

  addFriendsToFriendGroup() async {
    V2TimValueCallback<List<V2TimFriendOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .addFriendsToFriendGroup(
                groupName: "group3new222", userIDList: ["lexuslin2"]);
    print(res.toJson());
  }

  deleteFriendsFromFriendGroup() async {
    V2TimValueCallback<List<V2TimFriendOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .deleteFriendsFromFriendGroup(
                groupName: "group3new222", userIDList: ["lexuslin3"]);
    print(res.toJson());
  }

  setConversationDraft() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .setConversationDraft(conversationID: "ccccc", draftText: "会话草稿1");
    print(res.toJson());
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
    print(res.toJson());
  }

  deleteMessageFromLocalStorage() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .deleteMessageFromLocalStorage(
            msgID: "144115225971632901-1608635550-1824306931");
    print(res.toJson());
  }

  deleteMessages() async {
    List<String> list = List.empty(growable: true);
    list.add("144115225971632901-1607682284-904218793");
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .deleteMessages(msgIDs: list);
    print(res.toJson());
  }

  insertGroupMessageToLocalStorage() async {
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .insertGroupMessageToLocalStorage(
            groupID: "g1234", sender: "13675", data: "mmmmmm2");
    print(res.toJson());
  }

  insertC2CMessageToLocalStorage() async {
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .insertC2CMessageToLocalStorage(
          data: "111test",
          userID: "lexuslin",
          sender: "13675",
        );

    print(res.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("测试页"),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, i) => new Column(
            children: [
              Text("Manager"),
              ElevatedButton(
                onPressed: unInitSDK,
                child: Text("unInitSDK"),
              ),
              ElevatedButton(
                onPressed: getVersion,
                child: Text("getVersion"),
              ),
              ElevatedButton(
                onPressed: getServerTime,
                child: Text("getServerTime"),
              ),
              ElevatedButton(
                onPressed: getLoginStatus,
                child: Text("getLoginStatus"),
              ),
              ElevatedButton(
                onPressed: removeSimpleMsgListener,
                child: Text("removeSimpleMsgListener"),
              ),
              ElevatedButton(
                onPressed: dismissGroup,
                child: Text("dismissGroup"),
              ),
              Text("Group"),
              // ElevatedButton(
              //   onPressed: setGroupInfo,
              //   child: Text("setGroupInfo"),
              // ),
              ElevatedButton(
                onPressed: setReceiveMessageOpt,
                child: Text("setReceiveMessageOpt"),
              ),
              ElevatedButton(
                onPressed: createGroup,
                child: Text("createGroup"),
              ),
              ElevatedButton(
                onPressed: initGroupAttributes,
                child: Text("initGroupAttributes"),
              ),
              ElevatedButton(
                onPressed: setGroupAttributes,
                child: Text("setGroupAttributes"),
              ),
              ElevatedButton(
                onPressed: deleteGroupAttributes,
                child: Text("deleteGroupAttributes"),
              ),
              ElevatedButton(
                onPressed: getGroupAttributes,
                child: Text("getGroupAttributes"),
              ),
              ElevatedButton(
                onPressed: getGroupOnlineMemberCount,
                child: Text("getGroupOnlineMemberCount"),
              ),
              ElevatedButton(
                onPressed: getGroupMembersInfo,
                child: Text("getGroupMembersInfo"),
              ),
              ElevatedButton(
                onPressed: setGroupMemberInfo,
                child: Text("setGroupMemberInfo"),
              ),
              ElevatedButton(
                onPressed: muteGroupMember,
                child: Text("muteGroupMember"),
              ),
              ElevatedButton(
                onPressed: inviteUserToGroup,
                child: Text("inviteUserToGroup"),
              ),
              ElevatedButton(
                onPressed: kickGroupMember,
                child: Text("kickGroupMember"),
              ),
              ElevatedButton(
                onPressed: setGroupMemberRole,
                child: Text("setGroupMemberRole"),
              ),
              ElevatedButton(
                onPressed: transferGroupOwner,
                child: Text("transferGroupOwner"),
              ),
              ElevatedButton(
                onPressed: setGroupApplicationRead,
                child: Text("setGroupApplicationRead"),
              ),
              Text("Friend"),
              ElevatedButton(
                onPressed: checkFriend,
                child: Text("checkFriend"),
              ),
              ElevatedButton(
                onPressed: deleteFriendApplication,
                child: Text("deleteFriendApplication"),
              ),
              ElevatedButton(
                onPressed: setFriendApplicationRead,
                child: Text("setFriendApplicationRead"),
              ),
              ElevatedButton(
                onPressed: createFriendGroup,
                child: Text("createFriendGroup"),
              ),
              ElevatedButton(
                onPressed: getFriendGroups,
                child: Text("getFriendGroups"),
              ),
              ElevatedButton(
                onPressed: deleteFriendGroup,
                child: Text("deleteFriendGroup"),
              ),
              ElevatedButton(
                onPressed: renameFriendGroup,
                child: Text("renameFriendGroup"),
              ),
              ElevatedButton(
                onPressed: addFriendsToFriendGroup,
                child: Text("addFriendsToFriendGroup"),
              ),
              ElevatedButton(
                onPressed: deleteFriendsFromFriendGroup,
                child: Text("deleteFriendsFromFriendGroup"),
              ),
              Text("Conversation"),
              ElevatedButton(
                onPressed: setConversationDraft,
                child: Text("setConversationDraft"),
              ),
              Text("Message"),
              ElevatedButton(
                onPressed: removeAdvancedMsgListener,
                child: Text("removeAdvancedMsgListener"),
              ),
              ElevatedButton(
                onPressed: revokeMessage,
                child: Text("revokeMessage"),
              ),
              ElevatedButton(
                onPressed: deleteMessageFromLocalStorage,
                child: Text("deleteMessageFromLocalStorage"),
              ),
              ElevatedButton(
                onPressed: deleteMessages,
                child: Text("deleteMessages"),
              ),
              ElevatedButton(
                onPressed: insertGroupMessageToLocalStorage,
                child: Text("insertGroupMessageToLocalStorage"),
              ),
              ElevatedButton(
                onPressed: insertC2CMessageToLocalStorage,
                child: Text("insertC2CMessageToLocalStorage"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
