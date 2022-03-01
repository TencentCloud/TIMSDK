import 'package:im_api_example/im/addEventListener.dart';
import 'package:im_api_example/im/addFriend.dart';
import 'package:im_api_example/im/addFriendsToFriendGroup.dart';
import 'package:im_api_example/im/addInvitedSignaling.dart';
import 'package:im_api_example/im/addToBlackList.dart';
import 'package:im_api_example/im/agreeFriendApplication.dart';
import 'package:im_api_example/im/checkFriend.dart';
import 'package:im_api_example/im/createFriendGroup.dart';
import 'package:im_api_example/im/createGroup.dart';
import 'package:im_api_example/im/createGroup_v2.dart';
import 'package:im_api_example/im/deleteConversation.dart';
import 'package:im_api_example/im/deleteFriendGroup.dart';
import 'package:im_api_example/im/deleteFriendsFromFriendGroup.dart';
import 'package:im_api_example/im/deleteFromBlackList.dart';
import 'package:im_api_example/im/deleteFromFriendList.dart';
import 'package:im_api_example/im/deleteMessageFromLocalStorage.dart';
import 'package:im_api_example/im/deleteMessages.dart';
import 'package:im_api_example/im/dismissGroup.dart';
import 'package:im_api_example/im/getBlackList.dart';
import 'package:im_api_example/im/getC2CHistoryMessageList.dart';
import 'package:im_api_example/im/getConversation.dart';
import 'package:im_api_example/im/getConversationList.dart';
import 'package:im_api_example/im/getConversationListByConversaionIds.dart';
import 'package:im_api_example/im/getFriendApplicationList.dart';
import 'package:im_api_example/im/getFriendGroups.dart';
import 'package:im_api_example/im/getFriendList.dart';
import 'package:im_api_example/im/getFriendsInfo.dart';
import 'package:im_api_example/im/getGroupHistoryMessageList.dart';
import 'package:im_api_example/im/getGroupMemberList.dart';
import 'package:im_api_example/im/getGroupMembersInfo.dart';
import 'package:im_api_example/im/getGroupOnlineMemberCount.dart';
import 'package:im_api_example/im/getGroupsInfo.dart';
import 'package:im_api_example/im/getHistoryMessageList.dart';
import 'package:im_api_example/im/getHistoryMessageListWithoutFormat.dart';
import 'package:im_api_example/im/getJoinedGroupList.dart';
import 'package:im_api_example/im/getLoginStatus.dart';
import 'package:im_api_example/im/getLoginUser.dart';
import 'package:im_api_example/im/getServerTime.dart';
import 'package:im_api_example/im/getSignalingInfo.dart';
import 'package:im_api_example/im/getTotalUnreadMessageCount.dart';
import 'package:im_api_example/im/getUsersInfo.dart';
import 'package:im_api_example/im/getVersion.dart';
import 'package:im_api_example/im/initSDK.dart';
import 'package:im_api_example/im/insertC2CMessageToLocalStorage.dart';
import 'package:im_api_example/im/insertGroupMessageToLocalStorage.dart';
import 'package:im_api_example/im/invite.dart';
import 'package:im_api_example/im/inviteInGroup.dart';
import 'package:im_api_example/im/inviteUserToGroup.dart';
import 'package:im_api_example/im/joinGroup.dart';
import 'package:im_api_example/im/kickGroupMember.dart';
import 'package:im_api_example/im/login.dart';
import 'package:im_api_example/im/logout.dart';
import 'package:im_api_example/im/markC2CMessageAsRead.dart';
import 'package:im_api_example/im/markGroupMessageAsRead.dart';
import 'package:im_api_example/im/MarkAllMessageAsRead.dart';
import 'package:im_api_example/im/muteGroupMember.dart';
import 'package:im_api_example/im/pinConversation.dart';
import 'package:im_api_example/im/quitGroup.dart';
import 'package:im_api_example/im/reSendMessage.dart';
import 'package:im_api_example/im/refuseFriendApplication.dart';
import 'package:im_api_example/im/renameFriendGroup.dart';
import 'package:im_api_example/im/revokeMessage.dart';
import 'package:im_api_example/im/sendC2CCustomMessage.dart';
import 'package:im_api_example/im/sendC2CTextMessage.dart';
import 'package:im_api_example/im/sendCustomMessage.dart';
import 'package:im_api_example/im/sendFaceMessage.dart';
import 'package:im_api_example/im/sendFileMessage.dart';
import 'package:im_api_example/im/sendForwardMessage.dart';
import 'package:im_api_example/im/sendGroupCustomMessage.dart';
import 'package:im_api_example/im/sendGroupTextMessage.dart';
import 'package:im_api_example/im/sendImageMessage.dart';
import 'package:im_api_example/im/sendLocationMessage.dart';
import 'package:im_api_example/im/sendMergerMessage.dart';
import 'package:im_api_example/im/sendSoundMessage.dart';
import 'package:im_api_example/im/sendTextAtMessage.dart';
import 'package:im_api_example/im/sendTextMessage.dart';
import 'package:im_api_example/im/sendVideoMessage.dart';
import 'package:im_api_example/im/setCloudCustomData.dart';
import 'package:im_api_example/im/setConversationDraft.dart';
import 'package:im_api_example/im/setFriendInfo.dart';
import 'package:im_api_example/im/setGroupInfo.dart';
import 'package:im_api_example/im/setGroupMemberInfo.dart';
import 'package:im_api_example/im/setGroupMemberRole.dart';
import 'package:im_api_example/im/setLocalCustomData.dart';
import 'package:im_api_example/im/setLocalCustomInt.dart';
import 'package:im_api_example/im/setOfflinePushConfig.dart';
import 'package:im_api_example/im/setSelfInfo.dart';
import 'package:im_api_example/im/transferGroupOwner.dart';
import 'package:im_api_example/im/callExperimentalAPI.dart';
import 'package:im_api_example/im/clearC2CHistoryMessage.dart';
import 'package:im_api_example/im/clearGroupHistoryMessage.dart';
import 'package:im_api_example/im/searchLocalMessages.dart';
import 'package:im_api_example/im/findMessages.dart';
import 'package:im_api_example/im/searchGroups.dart';
import 'package:im_api_example/im/searchGroupMembers.dart';
import 'package:im_api_example/im/searchFriends.dart';
import 'package:im_api_example/im/getC2CReceiveMessageOpt.dart';
import 'package:im_api_example/i18n/i18n_utils.dart';

class Config {
  static const String appName = "API Example For Flutter";
  static const int sdkappid = 0;

  // 【重要】 生产环境userSig请放在服务端生产。
  static const String key = "";
  static const String XG_ACCESS_ID = "A7CH63Q4QBZB"; // 腾讯云TPNS控制台注册所得ACCESS_ID
  static const String XG_ACCESS_KEY =
      "3ba86c2eaa4f99152c271b1f6eda3021"; // 腾讯云TPNS控制台注册所得ACCESS_KEY
  static String testString = "hola-boe.bytedance.net";

  static final List<Map<String, dynamic>> apiData = [
    {
      "apiManager": "V2TimManager",
      "managerName": imt("基础模块"),
      "apis": [
        {
          "apiName": "initSDK",
          "apiNameCN": imt("初始化SDK"),
          "apiDesc": imt("sdk 初始化"),
          "detailRoute": InitSDK(),
          "codeFile": "lib/im/initSDK.dart",
        },
        {
          "apiName": "addEventListener",
          "apiNameCN": imt("添加事件监听"),
          "apiDesc": imt("事件监听应先于登录方法前添加，以防漏消息"),
          "detailRoute": AddEventListener(),
          "codeFile": "lib/im/addEventListener.dart",
        },
        {
          "apiName": "getServerTime",
          "apiNameCN": imt("获取服务端时间"),
          "apiDesc": imt("sdk 获取服务端时间"),
          "detailRoute": GetServerTime(),
          "codeFile": "lib/im/getServerTime.dart",
        },
        {
          "apiName": "login",
          "apiNameCN": imt("登录"),
          "apiDesc": imt("sdk 登录接口，先初始化"),
          "detailRoute": Login(),
          "codeFile": "lib/im/login.dart",
        },
        {
          "apiName": "logout",
          "apiNameCN": imt("登出"),
          "apiDesc": imt("sdk 登录接口，先初始化"),
          "detailRoute": Logout(),
          "codeFile": "lib/im/logout.dart",
        },
        {
          "apiName": "sendC2CTextMessage",
          "apiNameCN": imt("发送C2C文本消息（3.6版本已弃用）"),
          "apiDesc": imt("发送C2C文本消息（3.6版本已弃用）"),
          "detailRoute": SendC2CTextMessage(),
          "codeFile": "lib/im/sendC2CTextMessage.dart",
        },
        {
          "apiName": "sendC2CCustomMessage",
          "apiNameCN": imt("发送C2C自定义消息（3.6版本已弃用）"),
          "apiDesc": imt("发送C2C自定义消息（3.6版本已弃用）"),
          "detailRoute": SendC2CCustomMessage(),
          "codeFile": "lib/im/sendC2CCustomMessage.dart",
        },
        {
          "apiName": "sendGroupTextMessage",
          "apiNameCN": imt("发送Group文本消息（3.6版本已弃用）"),
          "apiDesc": imt("发送Group文本消息（3.6版本已弃用）"),
          "detailRoute": SendGroupTextMessage(),
          "codeFile": "lib/im/sendGroupTextMessage.dart",
        },
        {
          "apiName": "sendGroupCustomMessage",
          "apiNameCN": imt("发送Group自定义消息（3.6版本已弃用）"),
          "apiDesc": imt("发送Group自定义消息（3.6版本已弃用）"),
          "detailRoute": SendGroupCustomMessage(),
          "codeFile": "lib/im/sendGroupCustomMessage.dart",
        },
        {
          "apiName": "getVersion",
          "apiNameCN": imt("获取 SDK 版本"),
          "apiDesc": imt("获取 SDK 版本"),
          "detailRoute": GetVersion(),
          "codeFile": "lib/im/getVersion.dart",
        },
        {
          "apiName": "getLoginUser",
          "apiNameCN": imt("获取当前登录用户"),
          "apiDesc": imt("获取当前登录用户"),
          "detailRoute": GetLoginUser(),
          "codeFile": "lib/im/getLoginUser.dart",
        },
        {
          "apiName": "getLoginStatus",
          "apiNameCN": imt("获取当前登录状态"),
          "apiDesc": imt("获取当前登录状态"),
          "detailRoute": GetLoginStatus(),
          "codeFile": "lib/im/getLoginStatus.dart",
        },
        {
          "apiName": "getUsersInfo",
          "apiNameCN": imt("获取用户信息"),
          "apiDesc": imt("获取用户信息"),
          "detailRoute": GetUserInfo(),
          "codeFile": "lib/im/getUsersInfo.dart",
        },
        {
          "apiName": "createGroup",
          "apiNameCN": imt("创建群聊"),
          "apiDesc": imt("创建群聊"),
          "detailRoute": CreateGroup(),
          "codeFile": "lib/im/createGroup.dart",
        },
        {
          "apiName": "joinGroup",
          "apiNameCN": imt("加入群聊"),
          "apiDesc": imt("加入群聊"),
          "detailRoute": JoinGroup(),
          "codeFile": "lib/im/joinGroup.dart",
        },
        {
          "apiName": "quitGroup",
          "apiNameCN": imt("退出群聊"),
          "apiDesc": imt("退出群聊"),
          "detailRoute": QuitGroup(),
          "codeFile": "lib/im/quitGroup.dart",
        },
        {
          "apiName": "dismissGroup",
          "apiNameCN": imt("解散群聊"),
          "apiDesc": imt("解散群聊"),
          "detailRoute": DismissGroup(),
          "codeFile": "lib/im/dismissGroup.dart",
        },
        {
          "apiName": "setSelfInfo",
          "apiNameCN": imt("设置个人信息"),
          "apiDesc": imt("设置个人信息"),
          "detailRoute": SetSelfInfo(),
          "codeFile": "lib/im/setSelfInfo.dart",
        },
        {
          "apiName": "callExperimentalAPI",
          "apiNameCN": imt("试验性接口"),
          "apiDesc": imt("试验性接口"),
          "detailRoute": CallExperimentalAPI(),
          "codeFile": "lib/im/callExperimentalAPIState.dart",
        },
      ]
    },
    {
      "apiManager": "V2TimMessageManager",
      "managerName": imt("会话模块"),
      "apis": [
        {
          "apiName": "getConversationList",
          "apiNameCN": imt("获取会话列表"),
          "apiDesc": imt("获取会话列表"),
          "detailRoute": GetConversationList(),
          "codeFile": "lib/im/getConversationList.dart",
        },
        {
          "apiName": "getConversationListByConversaionIds",
          "apiNameCN": imt("获取会话列表"),
          "apiDesc": imt("获取会话列表"),
          "detailRoute": GetConversationByIDs(),
          "codeFile": "lib/im/getConversationListByConversaionIds.dart",
        },
        {
          "apiName": "getConversation",
          "apiNameCN": imt("获取会话详情"),
          "apiDesc": imt("获取会话详情"),
          "detailRoute": GetConversation(),
          "codeFile": "lib/im/getConversation.dart",
        },
        {
          "apiName": "deleteConversation",
          "apiNameCN": imt("删除会话"),
          "apiDesc": imt("删除会话"),
          "detailRoute": DeleteConversation(),
          "codeFile": "lib/im/deleteConversation.dart",
        },
        {
          "apiName": "setConversationDraft",
          "apiNameCN": imt("设置会话为草稿"),
          "apiDesc": imt("设置会话为草稿"),
          "detailRoute": SetConversationDraft(),
          "codeFile": "lib/im/setConversationDraft.dart",
        },
        {
          "apiName": "pinConversation",
          "apiNameCN": imt("会话置顶"),
          "apiDesc": imt("会话置顶"),
          "detailRoute": PinConversation(),
          "codeFile": "lib/im/pinConversation.dart",
        },
        {
          "apiName": "getTotalUnreadMessageCount",
          "apiNameCN": imt("获取会话未读总数"),
          "apiDesc": imt("获取会话未读总数"),
          "detailRoute": GetTotalUnreadMessageCount(),
          "codeFile": "lib/im/getTotalUnreadMessageCount.dart",
        },
      ]
    },
    {
      "apiManager": "V2TimMessageManager",
      "managerName": imt("消息模块"),
      "apis": [
        {
          "apiName": "sendTextMessage",
          "apiNameCN": imt("发送文本消息"),
          "apiDesc": imt("发送文本消息"),
          "detailRoute": SendTextMessage(),
          "codeFile": "lib/im/sendTextMessage.dart",
        },
        {
          "apiName": "sendCustomMessage",
          "apiNameCN": imt("发送自定义消息"),
          "apiDesc": imt("发送自定义消息"),
          "detailRoute": SendCustomMessage(),
          "codeFile": "lib/im/sendCustomMessage.dart",
        },
        {
          "apiName": "sendImageMessage",
          "apiNameCN": imt("发送图片消息"),
          "apiDesc": imt("发送图片消息"),
          "detailRoute": SendImageMessage(),
          "codeFile": "lib/im/sendImageMessage.dart",
        },
        {
          "apiName": "sendVideoMessage",
          "apiNameCN": imt("发送视频消息"),
          "apiDesc": imt("发送视频消息"),
          "detailRoute": SendVideoMessage(),
          "codeFile": "lib/im/sendVideoMessage.dart",
        },
        {
          "apiName": "sendFileMessage",
          "apiNameCN": imt("发送文件消息"),
          "apiDesc": imt("发送文件消息"),
          "detailRoute": SendFileMessage(),
          "codeFile": "lib/im/sendFileMessage.dart",
        },
        {
          "apiName": "sendSoundMessage",
          "apiNameCN": imt("发送录音消息"),
          "apiDesc": imt("发送录音消息"),
          "detailRoute": SendSoundMessage(),
          "codeFile": "lib/im/sendSoundMessage.dart",
        },
        {
          "apiName": "sendTextAtMessage",
          "apiNameCN": imt("发送文本At消息"),
          "apiDesc": imt("发送文本At消息"),
          "detailRoute": SendTextAtMessage(),
          "codeFile": "lib/im/sendTextAtMessage.dart",
        },
        {
          "apiName": "sendLocationMessage",
          "apiNameCN": imt("发送地理位置消息"),
          "apiDesc": imt("发送地理位置消息"),
          "detailRoute": SendLocationMessage(),
          "codeFile": "lib/im/sendLocationMessage.dart",
        },
        {
          "apiName": "sendFaceMessage",
          "apiNameCN": imt("发送表情消息"),
          "apiDesc": imt("发送表情消息"),
          "detailRoute": SendFaceMessage(),
          "codeFile": "lib/im/sendFaceMessage.dart",
        },
        {
          "apiName": "sendMergerMessage",
          "apiNameCN": imt("发送合并消息"),
          "apiDesc": imt("发送合并消息"),
          "detailRoute": SendMergerMessage(),
          "codeFile": "lib/im/sendMergerMessage.dart",
        },
        {
          "apiName": "sendForwardMessage",
          "apiNameCN": imt("发送转发消息"),
          "apiDesc": imt("发送转发消息"),
          "detailRoute": SendForwardMessage(),
          "codeFile": "lib/im/sendForwardMessage.dart",
        },
        {
          "apiName": "reSendMessage",
          "apiNameCN": imt("重发消息"),
          "apiDesc": imt("重发消息"),
          "detailRoute": ReSendMessage(),
          "codeFile": "lib/im/reSendMessage.dart",
        },
        {
          "apiName": "setLocalCustomData",
          "apiNameCN": imt("修改本地消息（String）"),
          "apiDesc": imt("修改本地消息（String）"),
          "detailRoute": SetLocalCustomData(),
          "codeFile": "lib/im/setLocalCustomData.dart",
        },
        {
          "apiName": "setLocalCustomInt",
          "apiNameCN": imt("修改本地消息（Int）"),
          "apiDesc": imt("修改本地消息（Int）"),
          "detailRoute": SetLocalCustomInt(),
          "codeFile": "lib/im/setLocalCustomInt.dart",
        },
        {
          "apiName": "setCloudCustomData",
          "apiNameCN": imt("修改云端消息（String-已弃用）"),
          "apiDesc": imt("修改云端消息（String-已弃用）"),
          "detailRoute": SetCloudCustomData(),
          "codeFile": "lib/im/setCloudCustomData.dart",
        },
        {
          "apiName": "getC2CHistoryMessageList",
          "apiNameCN": imt("获取C2C历史消息"),
          "apiDesc": imt("获取C2C历史消息"),
          "detailRoute": GetC2CHistoryMessageList(),
          "codeFile": "lib/im/getC2CHistoryMessageList.dart",
        },
        {
          "apiName": "getGroupHistoryMessageList",
          "apiNameCN": imt("获取Group历史消息"),
          "apiDesc": imt("获取Group历史消息"),
          "detailRoute": GetGroupHistoryMessageList(),
          "codeFile": "lib/im/getGroupHistoryMessageList.dart",
        },
        {
          "apiName": "getHistoryMessageList",
          "apiNameCN": imt("获取历史消息高级接口"),
          "apiDesc": imt("获取历史消息高级接口"),
          "detailRoute": GetHistoryMessageList(),
          "codeFile": "lib/im/getHistoryMessageList.dart",
        },
        {
          "apiName": "getHistoryMessageListWithoutFormat",
          "apiNameCN": imt("获取历史消息高级接口（不格式化）"),
          "apiDesc": imt("获取历史消息高级接口"),
          "detailRoute": GetHistoryMessageListWithoutFormat(),
          "codeFile": "lib/im/getHistoryMessageListWithoutFormat.dart",
        },
        {
          "apiName": "revokeMessage",
          "apiNameCN": imt("撤回消息"),
          "apiDesc": imt("撤回消息"),
          "detailRoute": RevokeMessage(),
          "codeFile": "lib/im/revokeMessage.dart",
        },
        {
          "apiName": "markC2CMessageAsRead",
          "apiNameCN": imt("标记C2C会话已读"),
          "apiDesc": imt("标记C2C会话已读"),
          "detailRoute": MarkC2CMessageAsRead(),
          "codeFile": "lib/im/markC2CMessageAsRead.dart",
        },
        {
          "apiName": "markGroupMessageAsRead",
          "apiNameCN": imt("标记Group会话已读"),
          "apiDesc": imt("标记Group会话已读"),
          "detailRoute": MarkGroupMessageAsRead(),
          "codeFile": "lib/im/markGroupMessageAsRead.dart",
        },
        {
          "apiName": "MarkAllMessageAsRead",
          "apiNameCN": imt("标记所有消息为已读"),
          "apiDesc": imt("标记所有消息为已读"),
          "detailRoute": MarkAllMessageAsRead(),
          "codeFile": "lib/im/MarkAllMessageAsRead.dart",
        },
        {
          "apiName": "deleteMessageFromLocalStorage",
          "apiNameCN": imt("删除本地消息"),
          "apiDesc": imt("删除本地消息"),
          "detailRoute": DeleteMessageFromLocalStorage(),
          "codeFile": "lib/im/deleteMessageFromLocalStorage.dart",
        },
        {
          "apiName": "deleteMessages",
          "apiNameCN": imt("删除消息"),
          "apiDesc": imt("删除消息"),
          "detailRoute": DeleteMessages(),
          "codeFile": "lib/im/deleteMessages.dart",
        },
        {
          "apiName": "insertGroupMessageToLocalStorage",
          "apiNameCN": imt("向group中插入一条本地消息"),
          "apiDesc": imt("向group中插入一条本地消息"),
          "detailRoute": InsertGroupMessageToLocalStorage(),
          "codeFile": "lib/im/insertGroupMessageToLocalStorage.dart",
        },
        {
          "apiName": "insertC2CMessageToLocalStorage",
          "apiNameCN": imt("向c2c会话中插入一条本地消息"),
          "apiDesc": imt("向c2c会话中插入一条本地消息"),
          "detailRoute": InsertC2CMessageToLocalStorage(),
          "codeFile": "lib/im/insertC2CMessageToLocalStorage.dart",
        },
        {
          "apiName": "clearC2CHistoryMessage",
          "apiNameCN": imt("清空单聊本地及云端的消息"),
          "apiDesc": imt("清空单聊本地及云端的消息"),
          "detailRoute": ClearC2CHistoryMessage(),
          "codeFile": "lib/im/clearC2CHistoryMessage.dart",
        },
        {
          "apiName": "getC2CReceiveMessageOpt",
          "apiNameCN": imt("获取用户消息接收选项"),
          "apiDesc": imt("获取用户消息接收选项"),
          "detailRoute": GetC2CReceiveMessageOpt(),
          "codeFile": "lib/im/getC2CReceiveMessageOpt.dart",
        },
        {
          "apiName": "clearGroupHistoryMessage",
          "apiNameCN": imt("清空群组单聊本地及云端的消息"),
          "apiDesc": imt("清空群组单聊本地及云端的消息"),
          "detailRoute": ClearGroupHistoryMessage(),
          "codeFile": "lib/im/clearGroupHistoryMessage.dart",
        },
        {
          "apiName": "searchLocalMessages",
          "apiNameCN": imt("搜索本地消息"),
          "apiDesc": imt("搜索本地消息"),
          "detailRoute": SearchLocalMessages(),
          "codeFile": "lib/im/searchLocalMessages.dart",
        },
        {
          "apiName": "findMessages",
          "apiNameCN": imt("查询指定会话中的本地消息"),
          "apiDesc": imt("查询指定会话中的本地消息"),
          "detailRoute": FindMessages(),
          "codeFile": "lib/im/findMessages.dart",
        },
      ]
    },
    {
      "apiManager": "V2TimMessageManager",
      "managerName": imt("好友关系链模块"),
      "apis": [
        {
          "apiName": "getFriendList",
          "apiNameCN": imt("获取好友列表"),
          "apiDesc": imt("获取好友列表"),
          "detailRoute": GetFriendList(),
          "codeFile": "lib/im/getFriendList.dart",
        },
        {
          "apiName": "getFriendsInfo",
          "apiNameCN": imt("获取好友信息"),
          "apiDesc": imt("获取好友信息"),
          "detailRoute": GetFriendsInfo(),
          "codeFile": "lib/im/getFriendsInfo.dart",
        },
        {
          "apiName": "addFriend",
          "apiNameCN": imt("添加好友"),
          "apiDesc": imt("添加好友"),
          "detailRoute": AddFriend(),
          "codeFile": "lib/im/addFriend.dart",
        },
        {
          "apiName": "setFriendInfo",
          "apiNameCN": imt("设置好友信息"),
          "apiDesc": imt("设置好友信息"),
          "detailRoute": SetFriendInfo(),
          "codeFile": "lib/im/setFriendInfo.dart",
        },
        {
          "apiName": "deleteFromFriendList",
          "apiNameCN": imt("删除好友"),
          "apiDesc": imt("删除好友"),
          "detailRoute": DeleteFromFriendList(),
          "codeFile": "lib/im/deleteFromFriendList.dart",
        },
        {
          "apiName": "checkFriend",
          "apiNameCN": imt("检测好友"),
          "apiDesc": imt("检测好友"),
          "detailRoute": CheckFriend(),
          "codeFile": "lib/im/checkFriend.dart",
        },
        {
          "apiName": "getFriendApplicationList",
          "apiNameCN": imt("获取好友申请列表"),
          "apiDesc": imt("获取好友申请列表"),
          "detailRoute": GetFriendApplicationList(),
          "codeFile": "lib/im/getFriendApplicationList.dart",
        },
        {
          "apiName": "agreeFriendApplication",
          "apiNameCN": imt("同意好友申请"),
          "apiDesc": imt("同意好友申请"),
          "detailRoute": AgreeFriendApplication(),
          "codeFile": "lib/im/agreeFriendApplication.dart"
        },
        {
          "apiName": "refuseFriendApplicationState",
          "apiNameCN": imt("拒绝好友申请"),
          "apiDesc": imt("拒绝好友申请"),
          "detailRoute": RefuseFriendApplication(),
          "codeFile": "lib/im/refuseFriendApplication.dart"
        },
        {
          "apiName": "getBlackList",
          "apiNameCN": imt("获取黑名单列表"),
          "apiDesc": imt("获取黑名单列表"),
          "detailRoute": GetBlackList(),
          "codeFile": "lib/im/getBlackList.dart",
        },
        {
          "apiName": "addToBlackList",
          "apiNameCN": imt("添加到黑名单"),
          "apiDesc": imt("添加到黑名单"),
          "detailRoute": AddToBlackList(),
          "codeFile": "lib/im/addToBlackList.dart",
        },
        {
          "apiName": "deleteFromBlackList",
          "apiNameCN": imt("从黑名单移除"),
          "apiDesc": imt("从黑名单移除"),
          "detailRoute": DeleteFromBlackList(),
          "codeFile": "lib/im/deleteFromBlackList.dart",
        },
        {
          "apiName": "createFriendGroup",
          "apiNameCN": imt("创建好友分组"),
          "apiDesc": imt("创建好友分组"),
          "detailRoute": CreateFriendGroup(),
          "codeFile": "lib/im/createFriendGroup.dart",
        },
        {
          "apiName": "getFriendGroups",
          "apiNameCN": imt("获取好友分组"),
          "apiDesc": imt("获取好友分组"),
          "detailRoute": GetFriendGroups(),
          "codeFile": "lib/im/getFriendGroups.dart",
        },
        {
          "apiName": "deleteFriendGroup",
          "apiNameCN": imt("删除好友分组"),
          "apiDesc": imt("删除好友分组"),
          "detailRoute": DeleteFriendGroup(),
          "codeFile": "lib/im/deleteFriendGroup.dart",
        },
        {
          "apiName": "renameFriendGroup",
          "apiNameCN": imt("重命名好友分组"),
          "apiDesc": imt("重命名好友分组"),
          "detailRoute": RenameFriendGroup(),
          "codeFile": "lib/im/renameFriendGroup.dart",
        },
        {
          "apiName": "addFriendsToFriendGroup",
          "apiNameCN": imt("添加好友到分组"),
          "apiDesc": imt("添加好友到分组"),
          "detailRoute": AddFriendsToFriendGroup(),
          "codeFile": "lib/im/addFriendsToFriendGroup.dart",
        },
        {
          "apiName": "deleteFriendsFromFriendGroup",
          "apiNameCN": imt("从分组中删除好友"),
          "apiDesc": imt("从分组中删除好友"),
          "detailRoute": DeleteFriendsFromFriendGroup(),
          "codeFile": "lib/im/deleteFriendsFromFriendGroup.dart",
        },
        {
          "apiName": "searchFriends",
          "apiNameCN": imt("搜索好友"),
          "apiDesc": imt("搜索好友"),
          "detailRoute": SearchFriends(),
          "codeFile": "lib/im/searchFriends.dart",
        },
      ]
    },
    {
      "apiManager": "V2TimMessageManager",
      "managerName": imt("群组模块"),
      "apis": [
        {
          "apiName": "createGroup",
          "apiNameCN": imt("高级创建群组"),
          "apiDesc": imt("高考创建群组"),
          "detailRoute": CreateGroupV2(),
          "codeFile": "lib/im/createGroup_v2.dart",
        },
        {
          "apiName": "getJoinedGroupList",
          "apiNameCN": imt("获取加群列表"),
          "apiDesc": imt("获取加群列表"),
          "detailRoute": GetJoinedGroupList(),
          "codeFile": "lib/im/getJoinedGroupList.dart",
        },
        {
          "apiName": "getGroupsInfo",
          "apiNameCN": imt("获取群信息"),
          "apiDesc": imt("获取群信息"),
          "detailRoute": GetGroupsInfo(),
          "codeFile": "lib/im/getGroupsInfo.dart",
        },
        {
          "apiName": "setGroupInfo",
          "apiNameCN": imt("设置群信息"),
          "apiDesc": imt("设置群信息"),
          "detailRoute": SetGroupInfo(),
          "codeFile": "lib/im/setGroupInfo.dart",
        },
        {
          "apiName": "getGroupOnlineMemberCount",
          "apiNameCN": imt("获取群在线人数"),
          "apiDesc": imt("获取群在线人数"),
          "detailRoute": GetGroupOnlineMemberCount(),
          "codeFile": "lib/im/getGroupOnlineMemberCount.dart",
        },
        {
          "apiName": "getGroupMemberList",
          "apiNameCN": imt("获取群成员列表"),
          "apiDesc": imt("获取群成员列表"),
          "detailRoute": GetGroupMemberList(),
          "codeFile": "lib/im/getGroupMemberList.dart",
        },
        {
          "apiName": "getGroupMembersInfo",
          "apiNameCN": imt("获取群成员信息"),
          "apiDesc": imt("获取群成员信息"),
          "detailRoute": GetGroupMembersInfo(),
          "codeFile": "lib/im/getGroupMembersInfo.dart",
        },
        {
          "apiName": "setGroupMemberInfo",
          "apiNameCN": imt("设置群成员信息"),
          "apiDesc": imt("设置群成员信息"),
          "detailRoute": SetGroupMemberInfo(),
          "codeFile": "lib/im/setGroupMemberInfo.dart",
        },
        {
          "apiName": "muteGroupMember",
          "apiNameCN": imt("禁言群成员"),
          "apiDesc": imt("禁言群成员"),
          "detailRoute": MuteGroupMember(),
          "codeFile": "lib/im/muteGroupMember.dart",
        },
        {
          "apiName": "inviteUserToGroup",
          "apiNameCN": imt("邀请好友进群"),
          "apiDesc": imt("邀请好友进群"),
          "detailRoute": InviteUserToGroup(),
          "codeFile": "lib/im/inviteUserToGroup.dart",
        },
        {
          "apiName": "kickGroupMember",
          "apiNameCN": imt("踢人出群"),
          "apiDesc": imt("踢人出群"),
          "detailRoute": KickGroupMember(),
          "codeFile": "lib/im/kickGroupMember.dart",
        },
        {
          "apiName": "setGroupMemberRole",
          "apiNameCN": imt("设置群角色"),
          "apiDesc": imt("设置群角色"),
          "detailRoute": SetGroupMemberRole(),
          "codeFile": "lib/im/setGroupMemberRole.dart",
        },
        {
          "apiName": "transferGroupOwner",
          "apiNameCN": imt("转移群主"),
          "apiDesc": imt("转移群主"),
          "detailRoute": TransferGroupOwner(),
          "codeFile": "lib/im/transferGroupOwner.dart",
        },
        {
          "apiName": "searchGroups",
          "apiNameCN": imt("搜索群列表"),
          "apiDesc": imt("搜索群列表"),
          "detailRoute": SearchGroups(),
          "codeFile": "lib/im/searchGroups.dart",
        },
        {
          "apiName": "searchGroupMembers",
          "apiNameCN": imt("搜索群成员"),
          "apiDesc": imt("搜索群成员"),
          "detailRoute": SearchGroupMembers(),
          "codeFile": "lib/im/searchGroupMembers.dart",
        }
      ]
    },
    {
      "apiManager": "V2TimMessageManager",
      "managerName": imt("信令模块"),
      "apis": [
        {
          "apiName": "invite",
          "apiNameCN": imt("发起邀请"),
          "apiDesc": imt("发起邀请"),
          "detailRoute": Invite(),
          "codeFile": "lib/im/invite.dart",
        },
        {
          "apiName": "inviteInGroup",
          "apiNameCN": imt("在群组中发起邀请"),
          "apiDesc": imt("在群组中发起邀请"),
          "detailRoute": InviteInGroup(),
          "codeFile": "lib/im/inviteInGroup.dart",
        },
        {
          "apiName": "getSignallingInfo",
          "apiNameCN": imt("获取信令信息"),
          "apiDesc": imt("获取信令信息"),
          "detailRoute": GetSignalingInfo(),
          "codeFile": "lib/im/getSignalingInfo.dart",
        },
        {
          "apiName": "addInvitedSignaling",
          "apiNameCN": imt("添加邀请信令"),
          "apiDesc": imt("添加邀请信令（可以用于群离线推送消息触发的邀请信令）"),
          "detailRoute": AddInvitedSignaling(),
          "codeFile": "lib/im/addInvitedSignaling.dart",
        },
      ]
    },
    // AddInvitedSignaling
    {
      "apiManager": "V2TimMessageManager",
      "managerName": imt("离线推送模块"),
      "apis": [
        {
          "apiName": "setOfflinePushConfig",
          "apiNameCN": imt("上报推送配置"),
          "apiDesc": imt("在群组中发起邀请"),
          "detailRoute": SetOfflinePushConfig(),
          "codeFile": "lib/im/setOfflinePushConfig.dart",
        },
      ]
    }
  ];
}
