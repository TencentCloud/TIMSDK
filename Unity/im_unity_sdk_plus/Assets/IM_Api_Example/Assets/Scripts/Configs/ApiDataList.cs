namespace com.tencent.im.unity.demo.config.ApiDataList
{
  public static class ApiDataList
  {
    public static string ApiDataListStr = @"[
  {
    ""apiManager"": ""V2TimManager"",
    ""managerName"": ""基础模块"",
    ""apis"": [
      {
        ""apiName"": ""initSDK"",
        ""apiText"": ""初始化SDK"",
        ""apiDesc"": ""sdk 初始化"",
        ""scene"": ""InitSDK""
      },
      {
        ""apiName"": ""addEventListener"",
        ""apiText"": ""添加事件监听"",
        ""apiDesc"": ""事件监听应先于登录方法前添加，以防漏消息"",
        ""scene"": ""AddEventListener""
      },
      {
        ""apiName"": ""getServerTime"",
        ""apiText"": ""获取服务端时间"",
        ""apiDesc"": ""sdk 获取服务端时间"",
        ""scene"": ""GetServerTime""
      },
      {
        ""apiName"": ""login"",
        ""apiText"": ""登录"",
        ""apiDesc"": ""sdk 登录接口，先初始化"",
        ""scene"": ""Login""
      },
      {
        ""apiName"": ""logout"",
        ""apiText"": ""登出"",
        ""apiDesc"": ""sdk 登录接口，先初始化"",
        ""scene"": ""Logout""
      },
      {
        ""apiName"": ""getLoginUser"",
        ""apiText"": ""获取当前登录用户"",
        ""apiDesc"": ""获取当前登录用户"",
        ""scene"": ""GetLoginUser""
      },
      {
        ""apiName"": ""profileGetUserProfileList"",
        ""apiText"": ""获取用户信息列表"",
        ""apiDesc"": ""获取用户信息列表"",
        ""scene"": ""ProfileGetUserProfileList""
      },
      {
        ""apiName"": ""groupCreate"",
        ""apiText"": ""创建群组"",
        ""apiDesc"": ""创建群组"",
        ""scene"": ""GroupCreate""
      },
      {
        ""apiName"": ""groupJoin"",
        ""apiText"": ""加入群组"",
        ""apiDesc"": ""加入群组"",
        ""scene"": ""GroupJoin""
      },
      {
        ""apiName"": ""groupDelete"",
        ""apiText"": ""退出（解散）群组"",
        ""apiDesc"": ""退出（解散）群组"",
        ""scene"": ""GroupDelete""
      }
    ]
  },
  {
    ""apiManager"": ""V2TimMessageManager"",
    ""managerName"": ""会话模块"",
    ""apis"": [
      {
        ""apiName"": ""convGetConvList"",
        ""apiText"": ""获取会话列表"",
        ""apiDesc"": ""获取会话列表"",
        ""scene"": ""ConvGetConvList""
      }
    ]
  },
  {
    ""apiManager"": ""V2TimMessageManager"",
    ""managerName"": ""消息模块"",
    ""apis"": [
      {
        ""apiName"": ""sendTextMessage"",
        ""apiText"": ""发送文本消息"",
        ""apiDesc"": ""发送文本消息"",
        ""scene"": ""SendTextMessage""
      }
    ]
  },
  {
    ""apiManager"": ""V2TimMessageManager"",
    ""managerName"": ""好友关系链模块"",
    ""apis"": [
      {
        ""apiName"": ""friendshipGetFriendProfileList"",
        ""apiText"": ""获取好友列表"",
        ""apiDesc"": ""获取好友列表"",
        ""scene"": ""FriendshipGetFriendProfileList""
      }
    ]
  },
  {
    ""apiManager"": ""V2TimMessageManager"",
    ""managerName"": ""群组模块"",
    ""apis"": [
      {
        ""apiName"": ""GroupGetJoinedGroupList"",
        ""apiText"": ""获取加群列表"",
        ""apiDesc"": ""获取加群列表"",
        ""scene"": ""GroupGetJoinedGroupList""
      }
    ]
  },
]
";

    private static string AllApiDataListStr = @"[
  {
    ""apiManager"": ""V2TimManager"",
    ""managerName"": ""基础模块"",
    ""apis"": [
      {
        ""apiName"": ""initSDK"",
        ""apiText"": ""初始化SDK"",
        ""apiDesc"": ""sdk 初始化"",
        ""scene"": ""InitSDK""
      },
      {
        ""apiName"": ""addEventListener"",
        ""apiText"": ""添加事件监听"",
        ""apiDesc"": ""事件监听应先于登录方法前添加，以防漏消息"",
        ""scene"": ""AddEventListener""
      },
      {
        ""apiName"": ""getServerTime"",
        ""apiText"": ""获取服务端时间"",
        ""apiDesc"": ""sdk 获取服务端时间"",
        ""scene"": ""GetServerTime""
      },
      {
        ""apiName"": ""login"",
        ""apiText"": ""登录"",
        ""apiDesc"": ""sdk 登录接口，先初始化"",
        ""scene"": ""Login""
      },
      {
        ""apiName"": ""logout"",
        ""apiText"": ""登出"",
        ""apiDesc"": ""sdk 登录接口，先初始化"",
        ""scene"": ""Logout""
      },
      {
        ""apiName"": ""sendC2CTextMessage"",
        ""apiText"": ""发送C2C文本消息（3.6版本已弃用）"",
        ""apiDesc"": ""发送C2C文本消息（3.6版本已弃用）"",
        ""scene"": ""SendC2CTextMessage""
      },
      {
        ""apiName"": ""sendC2CCustomMessage"",
        ""apiText"": ""发送C2C自定义消息（3.6版本已弃用）"",
        ""apiDesc"": ""发送C2C自定义消息（3.6版本已弃用）"",
        ""scene"": ""SendC2CCustomMessage""
      },
      {
        ""apiName"": ""sendGroupTextMessage"",
        ""apiText"": ""发送Group文本消息（3.6版本已弃用）"",
        ""apiDesc"": ""发送Group文本消息（3.6版本已弃用）"",
        ""scene"": ""SendGroupTextMessage""
      },
      {
        ""apiName"": ""sendGroupCustomMessage"",
        ""apiText"": ""发送Group自定义消息（3.6版本已弃用）"",
        ""apiDesc"": ""发送Group自定义消息（3.6版本已弃用）"",
        ""scene"": ""SendGroupCustomMessage""
      },
      {
        ""apiName"": ""getVersion"",
        ""apiText"": ""获取 SDK 版本"",
        ""apiDesc"": ""获取 SDK 版本"",
        ""scene"": ""GetVersion""
      },
      {
        ""apiName"": ""getLoginUser"",
        ""apiText"": ""获取当前登录用户"",
        ""apiDesc"": ""获取当前登录用户"",
        ""scene"": ""GetLoginUser""
      },
      {
        ""apiName"": ""getLoginStatus"",
        ""apiText"": ""获取当前登录状态"",
        ""apiDesc"": ""获取当前登录状态"",
        ""scene"": ""GetLoginStatus""
      },
      {
        ""apiName"": ""getUsersInfo"",
        ""apiText"": ""获取用户信息"",
        ""apiDesc"": ""获取用户信息"",
        ""scene"": ""GetUserInfo""
      },
      {
        ""apiName"": ""createGroup"",
        ""apiText"": ""创建群组"",
        ""apiDesc"": ""创建群组"",
        ""scene"": ""GroupCreate""
      },
      {
        ""apiName"": ""joinGroup"",
        ""apiText"": ""加入群组"",
        ""apiDesc"": ""加入群组"",
        ""scene"": ""JoinGroup""
      },
      {
        ""apiName"": ""quitGroup"",
        ""apiText"": ""退出群组"",
        ""apiDesc"": ""退出群组"",
        ""scene"": ""QuitGroup""
      },
      {
        ""apiName"": ""dismissGroup"",
        ""apiText"": ""解散群组"",
        ""apiDesc"": ""解散群组"",
        ""scene"": ""DismissGroup""
      },
      {
        ""apiName"": ""setSelfInfo"",
        ""apiText"": ""设置个人信息"",
        ""apiDesc"": ""设置个人信息"",
        ""scene"": ""SetSelfInfo""
      },
      {
        ""apiName"": ""callExperimentalAPI"",
        ""apiText"": ""试验性接口"",
        ""apiDesc"": ""试验性接口"",
        ""scene"": ""CallExperimentalAPI""
      }
    ]
  },
  {
    ""apiManager"": ""V2TimMessageManager"",
    ""managerName"": ""会话模块"",
    ""apis"": [
      {
        ""apiName"": ""getConversationList"",
        ""apiText"": ""获取会话列表"",
        ""apiDesc"": ""获取会话列表"",
        ""scene"": ""GetConversationList""
      },
      {
        ""apiName"": ""getConversationListByConversaionIds"",
        ""apiText"": ""获取会话列表"",
        ""apiDesc"": ""获取会话列表"",
        ""scene"": ""GetConversationByIDs""
      },
      {
        ""apiName"": ""getConversation"",
        ""apiText"": ""获取会话详情"",
        ""apiDesc"": ""获取会话详情"",
        ""scene"": ""GetConversation""
      },
      {
        ""apiName"": ""deleteConversation"",
        ""apiText"": ""删除会话"",
        ""apiDesc"": ""删除会话"",
        ""scene"": ""DeleteConversation""
      },
      {
        ""apiName"": ""setConversationDraft"",
        ""apiText"": ""设置会话为草稿"",
        ""apiDesc"": ""设置会话为草稿"",
        ""scene"": ""SetConversationDraft""
      },
      {
        ""apiName"": ""pinConversation"",
        ""apiText"": ""会话置顶"",
        ""apiDesc"": ""会话置顶"",
        ""scene"": ""PinConversation""
      },
      {
        ""apiName"": ""getTotalUnreadMessageCount"",
        ""apiText"": ""获取会话未读总数"",
        ""apiDesc"": ""获取会话未读总数"",
        ""scene"": ""GetTotalUnreadMessageCount""
      }
    ]
  },
  {
    ""apiManager"": ""V2TimMessageManager"",
    ""managerName"": ""消息模块"",
    ""apis"": [
      {
        ""apiName"": ""sendTextMessage"",
        ""apiText"": ""发送文本消息"",
        ""apiDesc"": ""发送文本消息"",
        ""scene"": ""SendTextMessage""
      },
      {
        ""apiName"": ""sendCustomMessage"",
        ""apiText"": ""发送自定义消息"",
        ""apiDesc"": ""发送自定义消息"",
        ""scene"": ""SendCustomMessage""
      },
      {
        ""apiName"": ""sendImageMessage"",
        ""apiText"": ""发送图片消息"",
        ""apiDesc"": ""发送图片消息"",
        ""scene"": ""SendImageMessage""
      },
      {
        ""apiName"": ""sendVideoMessage"",
        ""apiText"": ""发送视频消息"",
        ""apiDesc"": ""发送视频消息"",
        ""scene"": ""SendVideoMessage""
      },
      {
        ""apiName"": ""sendFileMessage"",
        ""apiText"": ""发送文件消息"",
        ""apiDesc"": ""发送文件消息"",
        ""scene"": ""SendFileMessage""
      },
      {
        ""apiName"": ""sendSoundMessage"",
        ""apiText"": ""发送录音消息"",
        ""apiDesc"": ""发送录音消息"",
        ""scene"": ""SendSoundMessage""
      },
      {
        ""apiName"": ""sendTextAtMessage"",
        ""apiText"": ""发送文本At消息"",
        ""apiDesc"": ""发送文本At消息"",
        ""scene"": ""SendTextAtMessage""
      },
      {
        ""apiName"": ""sendLocationMessage"",
        ""apiText"": ""发送地理位置消息"",
        ""apiDesc"": ""发送地理位置消息"",
        ""scene"": ""SendLocationMessage""
      },
      {
        ""apiName"": ""sendFaceMessage"",
        ""apiText"": ""发送表情消息"",
        ""apiDesc"": ""发送表情消息"",
        ""scene"": ""SendFaceMessage""
      },
      {
        ""apiName"": ""sendMergerMessage"",
        ""apiText"": ""发送合并消息"",
        ""apiDesc"": ""发送合并消息"",
        ""scene"": ""SendMergerMessage""
      },
      {
        ""apiName"": ""sendForwardMessage"",
        ""apiText"": ""发送转发消息"",
        ""apiDesc"": ""发送转发消息"",
        ""scene"": ""SendForwardMessage""
      },
      {
        ""apiName"": ""reSendMessage"",
        ""apiText"": ""重发消息"",
        ""apiDesc"": ""重发消息"",
        ""scene"": ""ReSendMessage""
      },
      {
        ""apiName"": ""setLocalCustomData"",
        ""apiText"": ""修改本地消息（String）"",
        ""apiDesc"": ""修改本地消息（String）"",
        ""scene"": ""SetLocalCustomData""
      },
      {
        ""apiName"": ""setLocalCustomInt"",
        ""apiText"": ""修改本地消息（Int）"",
        ""apiDesc"": ""修改本地消息（Int）"",
        ""scene"": ""SetLocalCustomInt""
      },
      {
        ""apiName"": ""setCloudCustomData"",
        ""apiText"": ""修改云端消息（String-已弃用）"",
        ""apiDesc"": ""修改云端消息（String-已弃用）"",
        ""scene"": ""SetCloudCustomData""
      },
      {
        ""apiName"": ""getC2CHistoryMessageList"",
        ""apiText"": ""获取C2C历史消息"",
        ""apiDesc"": ""获取C2C历史消息"",
        ""scene"": ""GetC2CHistoryMessageList""
      },
      {
        ""apiName"": ""getGroupHistoryMessageList"",
        ""apiText"": ""获取Group历史消息"",
        ""apiDesc"": ""获取Group历史消息"",
        ""scene"": ""GetGroupHistoryMessageList""
      },
      {
        ""apiName"": ""getHistoryMessageList"",
        ""apiText"": ""获取历史消息高级接口"",
        ""apiDesc"": ""获取历史消息高级接口"",
        ""scene"": ""GetHistoryMessageList""
      },
      {
        ""apiName"": ""getHistoryMessageListWithoutFormat"",
        ""apiText"": ""获取历史消息高级接口（不格式化）"",
        ""apiDesc"": ""获取历史消息高级接口"",
        ""scene"": ""GetHistoryMessageListWithoutFormat""
      },
      {
        ""apiName"": ""revokeMessage"",
        ""apiText"": ""撤回消息"",
        ""apiDesc"": ""撤回消息"",
        ""scene"": ""RevokeMessage""
      },
      {
        ""apiName"": ""markC2CMessageAsRead"",
        ""apiText"": ""标记C2C会话已读"",
        ""apiDesc"": ""标记C2C会话已读"",
        ""scene"": ""MarkC2CMessageAsRead""
      },
      {
        ""apiName"": ""markGroupMessageAsRead"",
        ""apiText"": ""标记Group会话已读"",
        ""apiDesc"": ""标记Group会话已读"",
        ""scene"": ""MarkGroupMessageAsRead""
      },
      {
        ""apiName"": ""MarkAllMessageAsRead"",
        ""apiText"": ""标记所有消息为已读"",
        ""apiDesc"": ""标记所有消息为已读"",
        ""scene"": ""MarkAllMessageAsRead""
      },
      {
        ""apiName"": ""deleteMessageFromLocalStorage"",
        ""apiText"": ""删除本地消息"",
        ""apiDesc"": ""删除本地消息"",
        ""scene"": ""DeleteMessageFromLocalStorage""
      },
      {
        ""apiName"": ""deleteMessages"",
        ""apiText"": ""删除消息"",
        ""apiDesc"": ""删除消息"",
        ""scene"": ""DeleteMessages""
      },
      {
        ""apiName"": ""insertGroupMessageToLocalStorage"",
        ""apiText"": ""向group中插入一条本地消息"",
        ""apiDesc"": ""向group中插入一条本地消息"",
        ""scene"": ""InsertGroupMessageToLocalStorage""
      },
      {
        ""apiName"": ""insertC2CMessageToLocalStorage"",
        ""apiText"": ""向c2c会话中插入一条本地消息"",
        ""apiDesc"": ""向c2c会话中插入一条本地消息"",
        ""scene"": ""InsertC2CMessageToLocalStorage""
      },
      {
        ""apiName"": ""clearC2CHistoryMessage"",
        ""apiText"": ""清空单聊本地及云端的消息"",
        ""apiDesc"": ""清空单聊本地及云端的消息"",
        ""scene"": ""ClearC2CHistoryMessage""
      },
      {
        ""apiName"": ""getC2CReceiveMessageOpt"",
        ""apiText"": ""获取用户消息接收选项"",
        ""apiDesc"": ""获取用户消息接收选项"",
        ""scene"": ""GetC2CReceiveMessageOpt""
      },
      {
        ""apiName"": ""clearGroupHistoryMessage"",
        ""apiText"": ""清空群组单聊本地及云端的消息"",
        ""apiDesc"": ""清空群组单聊本地及云端的消息"",
        ""scene"": ""ClearGroupHistoryMessage""
      },
      {
        ""apiName"": ""searchLocalMessages"",
        ""apiText"": ""搜索本地消息"",
        ""apiDesc"": ""搜索本地消息"",
        ""scene"": ""SearchLocalMessages""
      },
      {
        ""apiName"": ""findMessages"",
        ""apiText"": ""查询指定会话中的本地消息"",
        ""apiDesc"": ""查询指定会话中的本地消息"",
        ""scene"": ""FindMessages""
      },
      {
        ""apiName"": ""sendMessageReadReceipts"",
        ""apiText"": ""发送群已读回执"",
        ""apiDesc"": ""发送群已读回执"",
        ""scene"": ""SendMessageReadReceipts""
      },
      {
        ""apiName"": ""getMessageReadReceipts"",
        ""apiText"": ""获取群已读回执"",
        ""apiDesc"": ""获取群已读回执"",
        ""scene"": ""GetMessageReadReceipts""
      },
      {
        ""apiName"": ""getGroupMessageReadMemberList"",
        ""apiText"": ""获取群已读（未读）成员列表"",
        ""apiDesc"": ""获取群已读（未读）成员列表"",
        ""scene"": ""GetGroupMessageReadMemberList""
      }
    ]
  },
  {
    ""apiManager"": ""V2TimMessageManager"",
    ""managerName"": ""好友关系链模块"",
    ""apis"": [
      {
        ""apiName"": ""getFriendList"",
        ""apiText"": ""获取好友列表"",
        ""apiDesc"": ""获取好友列表"",
        ""scene"": ""GetFriendList""
      },
      {
        ""apiName"": ""getFriendsInfo"",
        ""apiText"": ""获取好友信息"",
        ""apiDesc"": ""获取好友信息"",
        ""scene"": ""GetFriendsInfo""
      },
      {
        ""apiName"": ""addFriend"",
        ""apiText"": ""添加好友"",
        ""apiDesc"": ""添加好友"",
        ""scene"": ""AddFriend""
      },
      {
        ""apiName"": ""setFriendInfo"",
        ""apiText"": ""设置好友信息"",
        ""apiDesc"": ""设置好友信息"",
        ""scene"": ""SetFriendInfo""
      },
      {
        ""apiName"": ""deleteFromFriendList"",
        ""apiText"": ""删除好友"",
        ""apiDesc"": ""删除好友"",
        ""scene"": ""DeleteFromFriendList""
      },
      {
        ""apiName"": ""checkFriend"",
        ""apiText"": ""检测好友"",
        ""apiDesc"": ""检测好友"",
        ""scene"": ""CheckFriend""
      },
      {
        ""apiName"": ""getFriendApplicationList"",
        ""apiText"": ""获取好友申请列表"",
        ""apiDesc"": ""获取好友申请列表"",
        ""scene"": ""GetFriendApplicationList""
      },
      {
        ""apiName"": ""agreeFriendApplication"",
        ""apiText"": ""同意好友申请"",
        ""apiDesc"": ""同意好友申请"",
        ""scene"": ""AgreeFriendApplication""
      },
      {
        ""apiName"": ""refuseFriendApplicationState"",
        ""apiText"": ""拒绝好友申请"",
        ""apiDesc"": ""拒绝好友申请"",
        ""scene"": ""RefuseFriendApplication""
      },
      {
        ""apiName"": ""getBlackList"",
        ""apiText"": ""获取黑名单列表"",
        ""apiDesc"": ""获取黑名单列表"",
        ""scene"": ""GetBlackList""
      },
      {
        ""apiName"": ""addToBlackList"",
        ""apiText"": ""添加到黑名单"",
        ""apiDesc"": ""添加到黑名单"",
        ""scene"": ""AddToBlackList""
      },
      {
        ""apiName"": ""deleteFromBlackList"",
        ""apiText"": ""从黑名单移除"",
        ""apiDesc"": ""从黑名单移除"",
        ""scene"": ""DeleteFromBlackList""
      },
      {
        ""apiName"": ""createFriendGroup"",
        ""apiText"": ""创建好友分组"",
        ""apiDesc"": ""创建好友分组"",
        ""scene"": ""CreateFriendGroup""
      },
      {
        ""apiName"": ""getFriendGroups"",
        ""apiText"": ""获取好友分组"",
        ""apiDesc"": ""获取好友分组"",
        ""scene"": ""GetFriendGroups""
      },
      {
        ""apiName"": ""deleteFriendGroup"",
        ""apiText"": ""删除好友分组"",
        ""apiDesc"": ""删除好友分组"",
        ""scene"": ""DeleteFriendGroup""
      },
      {
        ""apiName"": ""renameFriendGroup"",
        ""apiText"": ""重命名好友分组"",
        ""apiDesc"": ""重命名好友分组"",
        ""scene"": ""RenameFriendGroup""
      },
      {
        ""apiName"": ""addFriendsToFriendGroup"",
        ""apiText"": ""添加好友到分组"",
        ""apiDesc"": ""添加好友到分组"",
        ""scene"": ""AddFriendsToFriendGroup""
      },
      {
        ""apiName"": ""deleteFriendsFromFriendGroup"",
        ""apiText"": ""从分组中删除好友"",
        ""apiDesc"": ""从分组中删除好友"",
        ""scene"": ""DeleteFriendsFromFriendGroup""
      },
      {
        ""apiName"": ""searchFriends"",
        ""apiText"": ""搜索好友"",
        ""apiDesc"": ""搜索好友"",
        ""scene"": ""SearchFriends""
      }
    ]
  },
  {
    ""apiManager"": ""V2TimMessageManager"",
    ""managerName"": ""群组模块"",
    ""apis"": [
      {
        ""apiName"": ""createGroup"",
        ""apiText"": ""高级创建群组"",
        ""apiDesc"": ""高级创建群组"",
        ""scene"": ""CreateGroupV2""
      },
      {
        ""apiName"": ""getJoinedGroupList"",
        ""apiText"": ""获取加群列表"",
        ""apiDesc"": ""获取加群列表"",
        ""scene"": ""GetJoinedGroupList""
      },
      {
        ""apiName"": ""getGroupsInfo"",
        ""apiText"": ""获取群信息"",
        ""apiDesc"": ""获取群信息"",
        ""scene"": ""GetGroupsInfo""
      },
      {
        ""apiName"": ""setGroupInfo"",
        ""apiText"": ""设置群信息"",
        ""apiDesc"": ""设置群信息"",
        ""scene"": ""SetGroupInfo""
      },
      {
        ""apiName"": ""getGroupOnlineMemberCount"",
        ""apiText"": ""获取群在线人数"",
        ""apiDesc"": ""获取群在线人数"",
        ""scene"": ""GetGroupOnlineMemberCount""
      },
      {
        ""apiName"": ""getGroupMemberList"",
        ""apiText"": ""获取群成员列表"",
        ""apiDesc"": ""获取群成员列表"",
        ""scene"": ""GetGroupMemberList""
      },
      {
        ""apiName"": ""getGroupMembersInfo"",
        ""apiText"": ""获取群成员信息"",
        ""apiDesc"": ""获取群成员信息"",
        ""scene"": ""GetGroupMembersInfo""
      },
      {
        ""apiName"": ""setGroupMemberInfo"",
        ""apiText"": ""设置群成员信息"",
        ""apiDesc"": ""设置群成员信息"",
        ""scene"": ""SetGroupMemberInfo""
      },
      {
        ""apiName"": ""muteGroupMember"",
        ""apiText"": ""禁言群成员"",
        ""apiDesc"": ""禁言群成员"",
        ""scene"": ""MuteGroupMember""
      },
      {
        ""apiName"": ""inviteUserToGroup"",
        ""apiText"": ""邀请好友进群"",
        ""apiDesc"": ""邀请好友进群"",
        ""scene"": ""InviteUserToGroup""
      },
      {
        ""apiName"": ""kickGroupMember"",
        ""apiText"": ""踢人出群"",
        ""apiDesc"": ""踢人出群"",
        ""scene"": ""KickGroupMember""
      },
      {
        ""apiName"": ""setGroupMemberRole"",
        ""apiText"": ""设置群角色"",
        ""apiDesc"": ""设置群角色"",
        ""scene"": ""SetGroupMemberRole""
      },
      {
        ""apiName"": ""transferGroupOwner"",
        ""apiText"": ""转移群主"",
        ""apiDesc"": ""转移群主"",
        ""scene"": ""TransferGroupOwner""
      },
      {
        ""apiName"": ""searchGroups"",
        ""apiText"": ""搜索群列表"",
        ""apiDesc"": ""搜索群列表"",
        ""scene"": ""SearchGroups""
      },
      {
        ""apiName"": ""searchGroupMembers"",
        ""apiText"": ""搜索群成员"",
        ""apiDesc"": ""搜索群成员"",
        ""scene"": ""SearchGroupMembers""
      }
    ]
  },
  {
    ""apiManager"": ""V2TimMessageManager"",
    ""managerName"": ""信令模块"",
    ""apis"": [
      {
        ""apiName"": ""invite"",
        ""apiText"": ""发起邀请"",
        ""apiDesc"": ""发起邀请"",
        ""scene"": ""Invite""
      },
      {
        ""apiName"": ""inviteInGroup"",
        ""apiText"": ""在群组中发起邀请"",
        ""apiDesc"": ""在群组中发起邀请"",
        ""scene"": ""InviteInGroup""
      },
      {
        ""apiName"": ""getSignallingInfo"",
        ""apiText"": ""获取信令信息"",
        ""apiDesc"": ""获取信令信息"",
        ""scene"": ""GetSignalingInfo""
      },
      {
        ""apiName"": ""addInvitedSignaling"",
        ""apiText"": ""添加邀请信令"",
        ""apiDesc"": ""添加邀请信令（可以用于群离线推送消息触发的邀请信令）"",
        ""scene"": ""AddInvitedSignaling""
      }
    ]
  },
  {
    ""apiManager"": ""V2TimMessageManager"",
    ""managerName"": ""离线推送模块"",
    ""apis"": [
      {
        ""apiName"": ""setOfflinePushConfig"",
        ""apiText"": ""上报推送配置"",
        ""apiDesc"": ""在群组中发起邀请"",
        ""scene"": ""SetOfflinePushConfig""
      }
    ]
  }
]
";
  }
}