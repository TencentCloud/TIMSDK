using com.tencent.im.unity.demo.types;
using System.Collections.Generic;
public static class I18n
{
  public static readonly Dictionary<string, I18nData> dict = new Dictionary<string, I18nData>{
    {
      "Base Module", new I18nData{
        cn = "基础模块"
      }
    },
    {
    "Conversation Module", new I18nData{
      cn = "会话模块"
      }
    },
    {
      "Message Module", new I18nData{
      cn = "消息模块"
      }
    },
    {
      "FriendShip Module", new I18nData{
      cn = "好友关系链模块"
      }
    },
    {
      "Group Module", new I18nData{
      cn = "群组模块"
      }
    },
    {
      "Config", new I18nData{
        cn = "配置信息"
      }
    },
    {
      "Modify Successfully", new I18nData{
        cn = "修改成功"
      }
    },
    {
      "Confirm", new I18nData{
        cn = "确认设置"
      }
    },
    {
      "Reset", new I18nData{
        cn = "清除所有配置"
      }
    },
    {
      "MessageLabel", new I18nData{
        cn = "发送文本",
        en = "Text Message Content"
      }
    },
    {
      "DataLabel", new I18nData{
        cn = "自定义数据Data",
        en = "Custom Message Data"
      }
    },
    {
      "DescLabel", new I18nData{
        cn = "自定义数据Desc",
        en = "Custom Message Desc"
      }
    },
    {
      "ExtLabel", new I18nData{
        cn = "自定义数据Extension",
        en = "Custom Message Extension"
      }
    },
    {
      "SelectFriendLabel", new I18nData{
        cn = "选择好友",
        en = "Select Friend"
      }
    },
    {
      "SelectFriendGroupNameLabel", new I18nData{
        cn = "选择好友分组",
        en = "Select Friend Group Name"
      }
    },
    {
      "SelectRoleLabel", new I18nData{
        cn = "选择角色",
        en = "Select Role"
      }
    },
    {
      "SelectBlackLabel", new I18nData{
        cn = "选择黑名单用户",
        en = "Select Black List User"
      }
    },
    {
      "SelectGroupLabel", new I18nData{
        cn = "选择群组",
        en = "Select Group"
      }
    },
    {
      "SelectGroupMemberLabel", new I18nData{
        cn = "选择群成员",
        en = "Select Group Member"
      }
    },
    {
      "SelectConvLabel", new I18nData{
        cn = "选择会话",
        en = "Select Conversation"
      }
    },
    {
      "SelectPriorityLabel", new I18nData{
        cn = "选择优先级",
        en = "Select Message Priority"
      }
    },
    {
      "IsOnlineLabel", new I18nData{
        cn = "是否仅在线用户接受到信息",
        en = "Only online users can receive messages"
      }
    },
    {
      "IsUnreadLabel", new I18nData{
        cn = "发送消息是否不计入未读数",
        en = "Don't count this message in Unread Receipt"
      }
    },
    {
      "needReceiptLabel", new I18nData{
        cn = "是否需要回执",
        en = "Need read receipt"
      }
    },
    {
      "getGroupListFailed", new I18nData{
        cn = "获取群组失败，请登陆",
        en = "Get group list failed, please login"
      }
    },
    {
      "getGroupMemberListFailed", new I18nData{
        cn = "获取群组成员列表失败，请登陆",
        en = "Get group member list failed, please login"
      }
    },
    {
      "getBlackListFailed", new I18nData{
        cn = "获取黑名单失败，请登陆",
        en = "Get black list failed, please login"
      }
    },
    {
      "getMsgListFailed", new I18nData{
        cn = "获取消息列表失败，请登陆",
        en = "Get message list failed, please login"
      }
    },
    {
      "getConvListFailed", new I18nData{
        cn = "获取会话失败，请登陆",
        en = "Get conv list failed, please login"
      }
    },
    {
      "getFriendListFailed", new I18nData{
        cn = "获取好友失败，请登陆",
        en = "Get friend list failed, please login"
      }
    },
    {
      "getFriendGroupListFailed", new I18nData{
        cn = "获取好友分组失败，请登陆",
        en = "Get friend group list failed, please login"
      }
    },
    {
      "getPendencyListFailed", new I18nData{
        cn = "获取好友请求失败，请登陆",
        en = "Get friend pendency list failed, please login"
      }
    },
    {
      "getGroupPendencyListFailed", new I18nData{
        cn = "获取群组请求失败，请登陆",
        en = "Get group pendency list failed, please login"
      }
    },
    {
      "Copy", new I18nData{
        cn ="复制结果",
        en = "Copy Result"
      }
    },
    {
      "SelectUserLabel", new I18nData{
        cn = "选择用户",
        en = "Select User"
      }
    },
    {
      "GroupIDLabel", new I18nData{
        cn = "群ID",
        en = "GroupID"
      }
    },
    {
      "GreetingLabel", new I18nData{
        cn = "进群打招呼 Message",
        en = "Greeting Message"
      }
    },
    {
      "GroupNameLabel", new I18nData{
        cn = "群名称",
        en = "Group Name"
      }
    },
    {
      "SelectGroupTypeLabel", new I18nData{
        cn = "选择群类型",
        en = "Select Group Type"
      }
    },
    {
      "EventListener", new I18nData {
        cn = "事件回调",
        en ="Event Callback"
      }
    },
    {
      "register", new I18nData {
        cn = "注册",
        en = "Register"
      }
    },
    {
      "remove", new I18nData {
        cn = "注销",
        en = "Remove"
      }
    },
    {
      "AddRecvNewMsgCallback", new I18nData{
        cn = "收到新消息回调"
      }
    },
    {
      "SetMsgReadedReceiptCallback", new I18nData{
        cn = "消息已读回执回调"
      }
    },
    {
      "SetMsgRevokeCallback", new I18nData{
        cn = "接收的消息被撤回回调"
      }
    },
    {
      "SetGroupTipsEventCallback", new I18nData{
        cn = "群组系统消息回调"
      }
    },
    {
      "SetMsgElemUploadProgressCallback", new I18nData{
        cn = "消息内元素相关文件上传进度回调"
      }
    },
    {
      "SetGroupAttributeChangedCallback", new I18nData{
        cn = "群组属性变更回调"
      }
    },
    {
      "SetConvEventCallback", new I18nData{
        cn = "会话事件回调"
      }
    },
    {
      "SetConvTotalUnreadMessageCountChangedCallback", new I18nData{
        cn = "会话未读消息总数变更回调"
      }
    },
    {
      "SetNetworkStatusListenerCallback", new I18nData{
        cn = "网络连接状态监听回调"
      }
    },
    {
      "SetKickedOfflineCallback", new I18nData{
        cn = "被踢下线通知回调"
      }
    },
    {
      "SetUserSigExpiredCallback", new I18nData{
        cn = "票据过期回调"
      }
    },
    {
      "SetOnAddFriendCallback", new I18nData{
        cn = "添加好友回调"
      }
    },
    {
      "SetOnDeleteFriendCallback", new I18nData{
        cn = "删除好友回调"
      }
    },
    {
      "SetUpdateFriendProfileCallback", new I18nData{
        cn = "更新好友资料回调"
      }
    },
    {
      "SetFriendAddRequestCallback", new I18nData{
        cn = "好友添加请求回调"
      }
    },
    {
      "SetFriendApplicationListDeletedCallback", new I18nData{
        cn = "好友申请被删除回调"
      }
    },
    {
      "SetFriendApplicationListReadCallback", new I18nData{
        cn = "好友申请已读回调"
      }
    },
    {
      "SetFriendBlackListAddedCallback", new I18nData{
        cn = "黑名单新增回调"
      }
    },
    {
      "SetFriendBlackListDeletedCallback", new I18nData{
        cn = "黑名单删除回调"
      }
    },
    {
      "FriendIDLabel", new I18nData{
        cn = "好友UserID",
        en = "Friend's UserID"
      }
    },
    {
      "FriendRemarkLabel", new I18nData{
        cn = "好友备注",
        en = "Friend's Remark"
      }
    },
    {
      "FriendGroupLabel", new I18nData{
        cn = "好友分组，分组需提前创建",
        en = "Friend's group name, which is predefined"
      }
    },
    {
      "FriendAddWordLabel", new I18nData{
        cn = "好友附言",
        en = "Reason for adding friend"
      }
    },
    {
      "FriendResponseActionLabel", new I18nData{
        cn = "响应好友添加",
        en = "Response to adding friend request"
      }
    },
    {
      "SelectFriendTypeLabel", new I18nData{
        cn = "好友类型",
        en = "Friend type"
      }
    },
    {
      "ImageMessageLabel", new I18nData{
        cn = "选择图片",
        en = "Select image"
      }
    },
    {
      "VideoMessageLabel", new I18nData{
        cn = "选择视频",
        en = "Select video"
      }
    },
    {
      "ScreenshotMessageLabel", new I18nData{
        cn = "选择视频截图",
        en = "Select video thumbnail"
      }
    },
    {
      "FileMessageLabel", new I18nData{
        cn = "选择文件",
        en = "Select file"
      }
    },
    {
      "SoundMessageLabel", new I18nData{
        cn = "开始录音",
        en = "Start recording"
      }
    },
    {
      "SoundFinMessageLabel", new I18nData{
        cn = "结束录音",
        en = "End recording"
      }
    },
    {
      "DraftLabel", new I18nData{
        cn = "草稿内容",
        en = "Draft content"
      }
    },
    {
      "PinLabel", new I18nData{
        cn = "会话置顶",
        en = "Pin conversation"
      }
    },
    {
      "SelectMsgLabel", new I18nData{
        cn = "选择消息",
        en = "Select message"
      }
    },
    {
      "SelectMemberFilterLabel", new I18nData{
        cn = "选择群消息成员列表",
        en = "Select group read message member list"
      }
    },
    {
      "SelectFriendPendencyTypeLabel", new I18nData{
        cn = "选择好友添加请求未决类型",
        en = "Select the pendency type of friend request"
      }
    },
    {
      "SelectGroupPendencyLabel", new I18nData{
        cn = "选择加群请求",
        en = "Select the pendency of joining group request"
      }
    },
    {
      "GroupHandlePendencyMsgLabel", new I18nData{
        cn = "加群请求处理附言",
        en = "Comments of handling group request"
      }
    },
    {
      "GroupHandlePendencyLabel", new I18nData{
        cn = "同意加群",
        en = "Accept joining group request"
      }
    },
    {
      "FaceIndexLabel", new I18nData{
        cn = "表情索引",
        en = "Index of face message"
      }
    },
    {
      "FaceBufLabel", new I18nData{
        cn = "表情额外信息",
        en = "Extra info of face message"
      }
    },
    {
      "LongtitudeLabel", new I18nData{
        cn = "经度",
        en = "Longtitude"
      }
    },
    {
      "LatitudeLabel", new I18nData{
        cn = "纬度",
        en = "Latitude"
      }
    },
    {
      "LocationDescLabel", new I18nData{
        cn = "位置描述",
        en = "Description of location message"
      }
    },
    {
      "FriendGroupNameLabel", new I18nData{
        cn = "好友分组名称",
        en = "Friend group name"
      }
    },
    {
      "KeywordLabel", new I18nData{
        cn = "关键字",
        en = "Keyword"
      }
    },
    {
      "FriendSearchFieldLabel", new I18nData{
        cn = "好友搜索类型",
        en = "Friendship search field"
      }
    },
    {
      "FriendCustomKeyLabel", new I18nData{
        cn = "自定义好友字段名称",
        en = "Friend's profile custom key"
      }
    },
    {
      "FriendCustomValueLabel", new I18nData{
        cn = "自定义好友字段值",
        en = "Friend's profile custom value"
      }
    },
    {
      "FriendCustomKeyPlaceHolder", new I18nData{
        cn = "请在控制台查看，按,分隔多个key",
        en = "Check key on the Console, keys are separated by ','"
      }
    },
    {
      "GroupSearchKeywordPlaceHolder", new I18nData{
        cn = "按,分隔多个关键字，做多支持5个",
        en = "Keywords are separated by ',', maximum 5"
      }
    },
    {
      "IsSearchUserIdLabel", new I18nData{
        cn = "设置是否搜索群成员 userID",
        en = "Search keywords as userID"
      }
    },
    {
      "IsSearchNickNameLabel", new I18nData{
        cn = "设置是否搜索群成员昵称",
        en = "Search keywords as nickname"
      }
    },
    {
      "IsSearchRemarkLabel", new I18nData{
        cn = "设置是否搜索群成员备注",
        en = "Search keywords as remark"
      }
    },
    {
      "IsSearchNameCardLabel", new I18nData{
        cn = "设置是否搜索群成员名片",
        en = "Search keywords as name card"
      }
    },
  };
};