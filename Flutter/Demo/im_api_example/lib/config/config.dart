import 'package:im_api_example/im/addEventListener.dart';
import 'package:im_api_example/im/addFriend.dart';
import 'package:im_api_example/im/addFriendsToFriendGroup.dart';
import 'package:im_api_example/im/addInvitedSignaling.dart';
import 'package:im_api_example/im/addToBlackList.dart';
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
import 'package:im_api_example/im/muteGroupMember.dart';
import 'package:im_api_example/im/pinConversation.dart';
import 'package:im_api_example/im/quitGroup.dart';
import 'package:im_api_example/im/reSendMessage.dart';
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

class Config {
  static const String appName = "API Example For Flutter";
  static const int sdkappid = 0;

  // 【重要】 生产环境userSig请放在服务端生产。
  static const String key = "";
  static const String XG_ACCESS_ID = "A7CH63Q4QBZB"; // 腾讯云TPNS控制台注册所得ACCESS_ID
  static const String XG_ACCESS_KEY =
      "3ba86c2eaa4f99152c271b1f6eda3021"; // 腾讯云TPNS控制台注册所得ACCESS_KEY

  static final List<Map<String, dynamic>> apiData = [
    {
      "apiManager": "V2TimManager",
      "managerName": "基础模块",
      "apis": [
        {
          "apiName": "initSDK",
          "apiNameCN": "初始化SDK",
          "apiDesc": "sdk 初始化",
          "detailRoute": InitSDK(),
          "codeFile": "lib/im/initSDK.dart",
        },
        {
          "apiName": "addEventListener",
          "apiNameCN": "添加事件监听",
          "apiDesc": "事件监听应先于登录方法前添加，以防漏消息",
          "detailRoute": AddEventListener(),
          "codeFile": "lib/im/addEventListener.dart",
        },
        {
          "apiName": "getServerTime",
          "apiNameCN": "获取服务端时间",
          "apiDesc": "sdk 获取服务端时间",
          "detailRoute": GetServerTime(),
          "codeFile": "lib/im/getServerTime.dart",
        },
        {
          "apiName": "login",
          "apiNameCN": "登录",
          "apiDesc": "sdk 登录接口，先初始化",
          "detailRoute": Login(),
          "codeFile": "lib/im/login.dart",
        },
        {
          "apiName": "logout",
          "apiNameCN": "登出",
          "apiDesc": "sdk 登录接口，先初始化",
          "detailRoute": Logout(),
          "codeFile": "lib/im/logout.dart",
        },
        {
          "apiName": "sendC2CTextMessage",
          "apiNameCN": "发送C2C文本消息",
          "apiDesc": "发送C2C文本消息",
          "detailRoute": SendC2CTextMessage(),
          "codeFile": "lib/im/sendC2CTextMessage.dart",
        },
        {
          "apiName": "sendC2CCustomMessage",
          "apiNameCN": "发送C2C自定义消息",
          "apiDesc": "发送C2C自定义消息",
          "detailRoute": SendC2CCustomMessage(),
          "codeFile": "lib/im/sendC2CCustomMessage.dart",
        },
        {
          "apiName": "sendGroupTextMessage",
          "apiNameCN": "发送Group文本消息",
          "apiDesc": "发送Group文本消息",
          "detailRoute": SendGroupTextMessage(),
          "codeFile": "lib/im/sendGroupTextMessage.dart",
        },
        {
          "apiName": "sendGroupCustomMessage",
          "apiNameCN": "发送Group自定义消息",
          "apiDesc": "发送Group自定义消息",
          "detailRoute": SendGroupCustomMessage(),
          "codeFile": "lib/im/sendGroupCustomMessage.dart",
        },
        {
          "apiName": "getVersion",
          "apiNameCN": "获取 SDK 版本",
          "apiDesc": "获取 SDK 版本",
          "detailRoute": GetVersion(),
          "codeFile": "lib/im/getVersion.dart",
        },
        {
          "apiName": "getLoginUser",
          "apiNameCN": "获取当前登录用户",
          "apiDesc": "获取当前登录用户",
          "detailRoute": GetLoginUser(),
          "codeFile": "lib/im/getLoginUser.dart",
        },
        {
          "apiName": "getLoginStatus",
          "apiNameCN": "获取当前登录状态",
          "apiDesc": "获取当前登录状态",
          "detailRoute": GetLoginStatus(),
          "codeFile": "lib/im/getLoginStatus.dart",
        },
        {
          "apiName": "getUsersInfo",
          "apiNameCN": "获取用户信息",
          "apiDesc": "获取用户信息",
          "detailRoute": GetUserInfo(),
          "codeFile": "lib/im/getUsersInfo.dart",
        },
        {
          "apiName": "createGroup",
          "apiNameCN": "创建群聊",
          "apiDesc": "创建群聊",
          "detailRoute": CreateGroup(),
          "codeFile": "lib/im/createGroup.dart",
        },
        {
          "apiName": "joinGroup",
          "apiNameCN": "加入群聊",
          "apiDesc": "加入群聊",
          "detailRoute": JoinGroup(),
          "codeFile": "lib/im/joinGroup.dart",
        },
        {
          "apiName": "quitGroup",
          "apiNameCN": "退出群聊",
          "apiDesc": "退出群聊",
          "detailRoute": QuitGroup(),
          "codeFile": "lib/im/quitGroup.dart",
        },
        {
          "apiName": "dismissGroup",
          "apiNameCN": "解散群聊",
          "apiDesc": "解散群聊",
          "detailRoute": DismissGroup(),
          "codeFile": "lib/im/dismissGroup.dart",
        },
        {
          "apiName": "setSelfInfo",
          "apiNameCN": "设置个人信息",
          "apiDesc": "设置个人信息",
          "detailRoute": SetSelfInfo(),
          "codeFile": "lib/im/setSelfInfo.dart",
        },
        {
          "apiName": "callExperimentalAPI",
          "apiNameCN": "试验性接口",
          "apiDesc": "试验性接口",
          "detailRoute": CallExperimentalAPI(),
          "codeFile": "lib/im/callExperimentalAPIState.dart",
        },
      ]
    },
    {
      "apiManager": "V2TimMessageManager",
      "managerName": "会话模块",
      "apis": [
        {
          "apiName": "getConversationList",
          "apiNameCN": "获取会话列表",
          "apiDesc": "获取会话列表",
          "detailRoute": GetConversationList(),
          "codeFile": "lib/im/getConversationList.dart",
        },
        {
          "apiName": "getConversationListByConversaionIds",
          "apiNameCN": "获取会话列表",
          "apiDesc": "获取会话列表",
          "detailRoute": GetConversationByIDs(),
          "codeFile": "lib/im/getConversationListByConversaionIds.dart",
        },
        {
          "apiName": "getConversation",
          "apiNameCN": "获取会话详情",
          "apiDesc": "获取会话详情",
          "detailRoute": GetConversation(),
          "codeFile": "lib/im/getConversation.dart",
        },
        {
          "apiName": "deleteConversation",
          "apiNameCN": "删除会话",
          "apiDesc": "删除会话",
          "detailRoute": DeleteConversation(),
          "codeFile": "lib/im/deleteConversation.dart",
        },
        {
          "apiName": "setConversationDraft",
          "apiNameCN": "设置会话为草稿",
          "apiDesc": "设置会话为草稿",
          "detailRoute": SetConversationDraft(),
          "codeFile": "lib/im/setConversationDraft.dart",
        },
        {
          "apiName": "pinConversation",
          "apiNameCN": "会话置顶",
          "apiDesc": "会话置顶",
          "detailRoute": PinConversation(),
          "codeFile": "lib/im/pinConversation.dart",
        },
        {
          "apiName": "getTotalUnreadMessageCount",
          "apiNameCN": "获取会话未读总数",
          "apiDesc": "获取会话未读总数",
          "detailRoute": GetTotalUnreadMessageCount(),
          "codeFile": "lib/im/getTotalUnreadMessageCount.dart",
        },
      ]
    },
    {
      "apiManager": "V2TimMessageManager",
      "managerName": "消息模块",
      "apis": [
        {
          "apiName": "sendTextMessage",
          "apiNameCN": "发送文本消息",
          "apiDesc": "发送文本消息",
          "detailRoute": SendTextMessage(),
          "codeFile": "lib/im/sendTextMessage.dart",
        },
        {
          "apiName": "sendCustomMessage",
          "apiNameCN": "发送自定义消息",
          "apiDesc": "发送自定义消息",
          "detailRoute": SendCustomMessage(),
          "codeFile": "lib/im/sendCustomMessage.dart",
        },
        {
          "apiName": "sendImageMessage",
          "apiNameCN": "发送图片消息",
          "apiDesc": "发送图片消息",
          "detailRoute": SendImageMessage(),
          "codeFile": "lib/im/sendImageMessage.dart",
        },
        {
          "apiName": "sendVideoMessage",
          "apiNameCN": "发送视频消息",
          "apiDesc": "发送视频消息",
          "detailRoute": SendVideoMessage(),
          "codeFile": "lib/im/sendVideoMessage.dart",
        },
        {
          "apiName": "sendFileMessage",
          "apiNameCN": "发送文件消息",
          "apiDesc": "发送文件消息",
          "detailRoute": SendFileMessage(),
          "codeFile": "lib/im/sendFileMessage.dart",
        },
        {
          "apiName": "sendSoundMessage",
          "apiNameCN": "发送录音消息",
          "apiDesc": "发送录音消息",
          "detailRoute": SendSoundMessage(),
          "codeFile": "lib/im/sendSoundMessage.dart",
        },
        {
          "apiName": "sendTextAtMessage",
          "apiNameCN": "发送文本At消息",
          "apiDesc": "发送文本At消息",
          "detailRoute": SendTextAtMessage(),
          "codeFile": "lib/im/sendTextAtMessage.dart",
        },
        {
          "apiName": "sendLocationMessage",
          "apiNameCN": "发送地理位置消息",
          "apiDesc": "发送地理位置消息",
          "detailRoute": SendLocationMessage(),
          "codeFile": "lib/im/sendLocationMessage.dart",
        },
        {
          "apiName": "sendFaceMessage",
          "apiNameCN": "发送表情消息",
          "apiDesc": "发送表情消息",
          "detailRoute": SendFaceMessage(),
          "codeFile": "lib/im/sendFaceMessage.dart",
        },
        {
          "apiName": "sendMergerMessage",
          "apiNameCN": "发送合并消息",
          "apiDesc": "发送合并消息",
          "detailRoute": SendMergerMessage(),
          "codeFile": "lib/im/sendMergerMessage.dart",
        },
        {
          "apiName": "sendForwardMessage",
          "apiNameCN": "发送转发消息",
          "apiDesc": "发送转发消息",
          "detailRoute": SendForwardMessage(),
          "codeFile": "lib/im/sendForwardMessage.dart",
        },
        {
          "apiName": "reSendMessage",
          "apiNameCN": "重发消息",
          "apiDesc": "重发消息",
          "detailRoute": ReSendMessage(),
          "codeFile": "lib/im/reSendMessage.dart",
        },
        {
          "apiName": "setLocalCustomData",
          "apiNameCN": "修改本地消息（String）",
          "apiDesc": "修改本地消息（String）",
          "detailRoute": SetLocalCustomData(),
          "codeFile": "lib/im/setLocalCustomData.dart",
        },
        {
          "apiName": "setLocalCustomInt",
          "apiNameCN": "修改本地消息（Int）",
          "apiDesc": "修改本地消息（Int）",
          "detailRoute": SetLocalCustomInt(),
          "codeFile": "lib/im/setLocalCustomInt.dart",
        },
        {
          "apiName": "setCloudCustomData",
          "apiNameCN": "修改云端消息（String）",
          "apiDesc": "修改云端消息（String）",
          "detailRoute": SetCloudCustomData(),
          "codeFile": "lib/im/setCloudCustomData.dart",
        },
        {
          "apiName": "getC2CHistoryMessageList",
          "apiNameCN": "获取C2C历史消息",
          "apiDesc": "获取C2C历史消息",
          "detailRoute": GetC2CHistoryMessageList(),
          "codeFile": "lib/im/getC2CHistoryMessageList.dart",
        },
        {
          "apiName": "getGroupHistoryMessageList",
          "apiNameCN": "获取Group历史消息",
          "apiDesc": "获取Group历史消息",
          "detailRoute": GetGroupHistoryMessageList(),
          "codeFile": "lib/im/getGroupHistoryMessageList.dart",
        },
        {
          "apiName": "getHistoryMessageList",
          "apiNameCN": "获取历史消息高级接口",
          "apiDesc": "获取历史消息高级接口",
          "detailRoute": GetHistoryMessageList(),
          "codeFile": "lib/im/getHistoryMessageList.dart",
        },
        {
          "apiName": "getHistoryMessageListWithoutFormat",
          "apiNameCN": "获取历史消息高级接口（不格式化）",
          "apiDesc": "获取历史消息高级接口",
          "detailRoute": GetHistoryMessageListWithoutFormat(),
          "codeFile": "lib/im/getHistoryMessageListWithoutFormat.dart",
        },
        {
          "apiName": "revokeMessage",
          "apiNameCN": "撤回消息",
          "apiDesc": "撤回消息",
          "detailRoute": RevokeMessage(),
          "codeFile": "lib/im/revokeMessage.dart",
        },
        {
          "apiName": "markC2CMessageAsRead",
          "apiNameCN": "标记C2C会话已读",
          "apiDesc": "标记C2C会话已读",
          "detailRoute": MarkC2CMessageAsRead(),
          "codeFile": "lib/im/markC2CMessageAsRead.dart",
        },
        {
          "apiName": "markGroupMessageAsRead",
          "apiNameCN": "标记Group会话已读",
          "apiDesc": "标记Group会话已读",
          "detailRoute": MarkGroupMessageAsRead(),
          "codeFile": "lib/im/markGroupMessageAsRead.dart",
        },
        {
          "apiName": "deleteMessageFromLocalStorage",
          "apiNameCN": "删除本地消息",
          "apiDesc": "删除本地消息",
          "detailRoute": DeleteMessageFromLocalStorage(),
          "codeFile": "lib/im/deleteMessageFromLocalStorage.dart",
        },
        {
          "apiName": "deleteMessages",
          "apiNameCN": "删除消息",
          "apiDesc": "删除消息",
          "detailRoute": DeleteMessages(),
          "codeFile": "lib/im/deleteMessages.dart",
        },
        {
          "apiName": "insertGroupMessageToLocalStorage",
          "apiNameCN": "向group中插入一条本地消息",
          "apiDesc": "向group中插入一条本地消息",
          "detailRoute": InsertGroupMessageToLocalStorage(),
          "codeFile": "lib/im/insertGroupMessageToLocalStorage.dart",
        },
        {
          "apiName": "insertC2CMessageToLocalStorage",
          "apiNameCN": "向c2c会话中插入一条本地消息",
          "apiDesc": "向c2c会话中插入一条本地消息",
          "detailRoute": InsertC2CMessageToLocalStorage(),
          "codeFile": "lib/im/insertC2CMessageToLocalStorage.dart",
        },
        {
          "apiName": "clearC2CHistoryMessage",
          "apiNameCN": "清空单聊本地及云端的消息",
          "apiDesc": "清空单聊本地及云端的消息",
          "detailRoute": ClearC2CHistoryMessage(),
          "codeFile": "lib/im/clearC2CHistoryMessage.dart",
        },
        {
          "apiName": "getC2CReceiveMessageOpt",
          "apiNameCN": "获取用户消息接收选项",
          "apiDesc": "获取用户消息接收选项",
          "detailRoute": GetC2CReceiveMessageOpt(),
          "codeFile": "lib/im/getC2CReceiveMessageOpt.dart",
        },
        {
          "apiName": "clearGroupHistoryMessage",
          "apiNameCN": "清空群组单聊本地及云端的消息",
          "apiDesc": "清空群组单聊本地及云端的消息",
          "detailRoute": ClearGroupHistoryMessage(),
          "codeFile": "lib/im/clearGroupHistoryMessage.dart",
        },
        {
          "apiName": "searchLocalMessages",
          "apiNameCN": "搜索本地消息",
          "apiDesc": "搜索本地消息",
          "detailRoute": SearchLocalMessages(),
          "codeFile": "lib/im/searchLocalMessages.dart",
        },
        {
          "apiName": "findMessages",
          "apiNameCN": "查询指定会话中的本地消息",
          "apiDesc": "查询指定会话中的本地消息",
          "detailRoute": FindMessages(),
          "codeFile": "lib/im/findMessages.dart",
        },
      ]
    },
    {
      "apiManager": "V2TimMessageManager",
      "managerName": "好友关系链模块",
      "apis": [
        {
          "apiName": "getFriendList",
          "apiNameCN": "获取好友列表",
          "apiDesc": "获取好友列表",
          "detailRoute": GetFriendList(),
          "codeFile": "lib/im/getFriendList.dart",
        },
        {
          "apiName": "getFriendsInfo",
          "apiNameCN": "获取好友信息",
          "apiDesc": "获取好友信息",
          "detailRoute": GetFriendsInfo(),
          "codeFile": "lib/im/getFriendsInfo.dart",
        },
        {
          "apiName": "addFriend",
          "apiNameCN": "添加好友",
          "apiDesc": "添加好友",
          "detailRoute": AddFriend(),
          "codeFile": "lib/im/addFriend.dart",
        },
        {
          "apiName": "setFriendInfo",
          "apiNameCN": "设置好友信息",
          "apiDesc": "设置好友信息",
          "detailRoute": SetFriendInfo(),
          "codeFile": "lib/im/setFriendInfo.dart",
        },
        {
          "apiName": "deleteFromFriendList",
          "apiNameCN": "删除好友",
          "apiDesc": "删除好友",
          "detailRoute": DeleteFromFriendList(),
          "codeFile": "lib/im/deleteFromFriendList.dart",
        },
        {
          "apiName": "checkFriend",
          "apiNameCN": "检测好友",
          "apiDesc": "检测好友",
          "detailRoute": CheckFriend(),
          "codeFile": "lib/im/checkFriend.dart",
        },
        {
          "apiName": "getFriendApplicationList",
          "apiNameCN": "获取好友申请列表",
          "apiDesc": "获取好友申请列表",
          "detailRoute": GetFriendApplicationList(),
          "codeFile": "lib/im/getFriendApplicationList.dart",
        },
        {
          "apiName": "getBlackList",
          "apiNameCN": "获取黑名单列表",
          "apiDesc": "获取黑名单列表",
          "detailRoute": GetBlackList(),
          "codeFile": "lib/im/getBlackList.dart",
        },
        {
          "apiName": "addToBlackList",
          "apiNameCN": "添加到黑名单",
          "apiDesc": "添加到黑名单",
          "detailRoute": AddToBlackList(),
          "codeFile": "lib/im/addToBlackList.dart",
        },
        {
          "apiName": "deleteFromBlackList",
          "apiNameCN": "从黑名单移除",
          "apiDesc": "从黑名单移除",
          "detailRoute": DeleteFromBlackList(),
          "codeFile": "lib/im/deleteFromBlackList.dart",
        },
        {
          "apiName": "createFriendGroup",
          "apiNameCN": "创建好友分组",
          "apiDesc": "创建好友分组",
          "detailRoute": CreateFriendGroup(),
          "codeFile": "lib/im/createFriendGroup.dart",
        },
        {
          "apiName": "getFriendGroups",
          "apiNameCN": "获取好友分组",
          "apiDesc": "获取好友分组",
          "detailRoute": GetFriendGroups(),
          "codeFile": "lib/im/getFriendGroups.dart",
        },
        {
          "apiName": "deleteFriendGroup",
          "apiNameCN": "删除好友分组",
          "apiDesc": "删除好友分组",
          "detailRoute": DeleteFriendGroup(),
          "codeFile": "lib/im/deleteFriendGroup.dart",
        },
        {
          "apiName": "renameFriendGroup",
          "apiNameCN": "重命名好友分组",
          "apiDesc": "重命名好友分组",
          "detailRoute": RenameFriendGroup(),
          "codeFile": "lib/im/renameFriendGroup.dart",
        },
        {
          "apiName": "addFriendsToFriendGroup",
          "apiNameCN": "添加好友到分组",
          "apiDesc": "添加好友到分组",
          "detailRoute": AddFriendsToFriendGroup(),
          "codeFile": "lib/im/addFriendsToFriendGroup.dart",
        },
        {
          "apiName": "deleteFriendsFromFriendGroup",
          "apiNameCN": "从分组中删除好友",
          "apiDesc": "从分组中删除好友",
          "detailRoute": DeleteFriendsFromFriendGroup(),
          "codeFile": "lib/im/deleteFriendsFromFriendGroup.dart",
        },
        {
          "apiName": "searchFriends",
          "apiNameCN": "搜索好友",
          "apiDesc": "搜索好友",
          "detailRoute": SearchFriends(),
          "codeFile": "lib/im/searchFriends.dart",
        },
      ]
    },
    {
      "apiManager": "V2TimMessageManager",
      "managerName": "群组模块",
      "apis": [
        {
          "apiName": "createGroup",
          "apiNameCN": "高级创建群组",
          "apiDesc": "高考创建群组",
          "detailRoute": CreateGroupV2(),
          "codeFile": "lib/im/createGroup_v2.dart",
        },
        {
          "apiName": "getJoinedGroupList",
          "apiNameCN": "获取加群列表",
          "apiDesc": "获取加群列表",
          "detailRoute": GetJoinedGroupList(),
          "codeFile": "lib/im/getJoinedGroupList.dart",
        },
        {
          "apiName": "getGroupsInfo",
          "apiNameCN": "获取群信息",
          "apiDesc": "获取群信息",
          "detailRoute": GetGroupsInfo(),
          "codeFile": "lib/im/getGroupsInfo.dart",
        },
        {
          "apiName": "setGroupInfo",
          "apiNameCN": "设置群信息",
          "apiDesc": "设置群信息",
          "detailRoute": SetGroupInfo(),
          "codeFile": "lib/im/setGroupInfo.dart",
        },
        {
          "apiName": "getGroupOnlineMemberCount",
          "apiNameCN": "获取群在线人数",
          "apiDesc": "获取群在线人数",
          "detailRoute": GetGroupOnlineMemberCount(),
          "codeFile": "lib/im/getGroupOnlineMemberCount.dart",
        },
        {
          "apiName": "getGroupMemberList",
          "apiNameCN": "获取群成员列表",
          "apiDesc": "获取群成员列表",
          "detailRoute": GetGroupMemberList(),
          "codeFile": "lib/im/getGroupMemberList.dart",
        },
        {
          "apiName": "getGroupMembersInfo",
          "apiNameCN": "获取群成员信息",
          "apiDesc": "获取群成员信息",
          "detailRoute": GetGroupMembersInfo(),
          "codeFile": "lib/im/getGroupMembersInfo.dart",
        },
        {
          "apiName": "setGroupMemberInfo",
          "apiNameCN": "设置群成员信息",
          "apiDesc": "设置群成员信息",
          "detailRoute": SetGroupMemberInfo(),
          "codeFile": "lib/im/setGroupMemberInfo.dart",
        },
        {
          "apiName": "muteGroupMember",
          "apiNameCN": "禁言群成员",
          "apiDesc": "禁言群成员",
          "detailRoute": MuteGroupMember(),
          "codeFile": "lib/im/muteGroupMember.dart",
        },
        {
          "apiName": "inviteUserToGroup",
          "apiNameCN": "邀请好友进群",
          "apiDesc": "邀请好友进群",
          "detailRoute": InviteUserToGroup(),
          "codeFile": "lib/im/inviteUserToGroup.dart",
        },
        {
          "apiName": "kickGroupMember",
          "apiNameCN": "踢人出群",
          "apiDesc": "踢人出群",
          "detailRoute": KickGroupMember(),
          "codeFile": "lib/im/kickGroupMember.dart",
        },
        {
          "apiName": "setGroupMemberRole",
          "apiNameCN": "设置群角色",
          "apiDesc": "设置群角色",
          "detailRoute": SetGroupMemberRole(),
          "codeFile": "lib/im/setGroupMemberRole.dart",
        },
        {
          "apiName": "transferGroupOwner",
          "apiNameCN": "转移群主",
          "apiDesc": "转移群主",
          "detailRoute": TransferGroupOwner(),
          "codeFile": "lib/im/transferGroupOwner.dart",
        },
        {
          "apiName": "searchGroups",
          "apiNameCN": "搜索群列表",
          "apiDesc": "搜索群列表",
          "detailRoute": SearchGroups(),
          "codeFile": "lib/im/searchGroups.dart",
        },
        {
          "apiName": "searchGroupMembers",
          "apiNameCN": "搜索群成员",
          "apiDesc": "搜索群成员",
          "detailRoute": SearchGroupMembers(),
          "codeFile": "lib/im/searchGroupMembers.dart",
        }
      ]
    },
    {
      "apiManager": "V2TimMessageManager",
      "managerName": "信令模块",
      "apis": [
        {
          "apiName": "invite",
          "apiNameCN": "发起邀请",
          "apiDesc": "发起邀请",
          "detailRoute": Invite(),
          "codeFile": "lib/im/invite.dart",
        },
        {
          "apiName": "inviteInGroup",
          "apiNameCN": "在群组中发起邀请",
          "apiDesc": "在群组中发起邀请",
          "detailRoute": InviteInGroup(),
          "codeFile": "lib/im/inviteInGroup.dart",
        },
        {
          "apiName": "getSignallingInfo",
          "apiNameCN": "获取信令信息",
          "apiDesc": "获取信令信息",
          "detailRoute": GetSignalingInfo(),
          "codeFile": "lib/im/getSignalingInfo.dart",
        },
        {
          "apiName": "addInvitedSignaling",
          "apiNameCN": "添加邀请信令",
          "apiDesc": "添加邀请信令（可以用于群离线推送消息触发的邀请信令）",
          "detailRoute": AddInvitedSignaling(),
          "codeFile": "lib/im/addInvitedSignaling.dart",
        },
      ]
    },
    // AddInvitedSignaling
    {
      "apiManager": "V2TimMessageManager",
      "managerName": "离线推送模块",
      "apis": [
        {
          "apiName": "setOfflinePushConfig",
          "apiNameCN": "上报推送配置",
          "apiDesc": "在群组中发起邀请",
          "detailRoute": SetOfflinePushConfig(),
          "codeFile": "lib/im/setOfflinePushConfig.dart",
        },
      ]
    }
  ];
}
