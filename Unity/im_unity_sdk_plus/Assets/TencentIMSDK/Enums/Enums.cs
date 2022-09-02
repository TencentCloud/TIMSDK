namespace com.tencent.imsdk.unity.enums
{
  public enum TIMResult
  {
    /// <summary>
    /// <description>接口调用成功 (Request Succeeds)</description>
    /// </summary>
    TIM_SUCC = 0,
    /// <summary>
    /// <description>接口调用失败，ImSDK未初始化 (Request fails, ImSDK hasn't initiated)</description>
    /// </summary>
    TIM_ERR_SDKUNINIT = -1,// 接口调用失败，ImSDK未初始化
    /// <summary>
    /// <description>接口调用失败，用户未登录 (Request fails, user hasn't logged in)</description>
    /// </summary>
    TIM_ERR_NOTLOGIN = -2, // 接口调用失败，用户未登录
    /// <summary>
    /// <description>接口调用失败，错误的Json格式或Json Key (Request fails, wrong JSON format)</description>
    /// </summary>
    TIM_ERR_JSON = -3,     // 接口调用失败，错误的Json格式或Json Key
    /// <summary>
    /// <description>接口调用失败，参数错误 (Request fails, wrong parameters)</description>
    /// </summary>
    TIM_ERR_PARAM = -4,    // 接口调用失败，参数错误
    /// <summary>
    /// <description>接口调用失败，无效的会话 (Request fails, invalid conversation)</description>
    /// </summary>
    TIM_ERR_CONV = -5,     // 接口调用失败，无效的会话
    /// <summary>
    /// <description>接口调用失败，无效的群组 (Request fails, invalid group)</description>
    /// </summary>
    TIM_ERR_GROUP = -6,    // 接口调用失败，无效的群组
  };
  public enum TIMLoginStatus
  {
    /// <summary>
    /// <description>已登录 (Logged in)</description>
    /// </summary>
    kTIMLoginStatus_Logined = 1,     // 已登录
    /// <summary>
    /// <description>登录中 (Logging)</description>
    /// </summary>
    kTIMLoginStatus_Logining = 2,    // 登录中
    /// <summary>
    /// <description>未登录 (Not logged in)</description>
    /// </summary>
    kTIMLoginStatus_UnLogined = 3,   // 未登录
    /// <summary>
    /// <description>登出中 (Logging out)</description>
    /// </summary>
    kTIMLoginStatus_Logouting = 4,   // 登出中

  };
  public enum TIMConvType
  {
    /// <summary>
    /// <description>无效会话 (Invalid conversation)</description>
    /// </summary>
    kTIMConv_Invalid, // 无效会话
    /// <summary>
    /// <description>个人会话 (C2C conversation)</description>
    /// </summary>
    kTIMConv_C2C,     // 个人会话
    /// <summary>
    /// <description>群组会话 (Group conversation)</description>
    /// </summary>
    kTIMConv_Group,   // 群组会话
    /// <summary>
    /// <description>系统会话 (System conversation)</description>
    /// </summary>
    kTIMConv_System,  // 系统会话
  };

  public enum TIMMsgPriority
  {
    /// <summary>
    /// <description>优先级最高，一般为红包或者礼物消息 (High priority, for red packet, gift message or so)</description>
    /// </summary>
    kTIMMsgPriority_High,   // 优先级最高，一般为红包或者礼物消息
    /// <summary>
    /// <description>表示优先级次之，建议为普通消息 (Normal priority, normal message)</description>
    /// </summary>
    kTIMMsgPriority_Normal, // 表示优先级次之，建议为普通消息
    /// <summary>
    /// <description>建议为点赞消息等 (Low priority, for thubmsup or so)</description>
    /// </summary>
    kTIMMsgPriority_Low,    // 建议为点赞消息等
    /// <summary>
    /// <description>优先级最低，一般为成员进退群通知(后台下发) (Lowest priority, for group member joining/quiting and or so (Server generated message))</description>
    /// </summary>
    kTIMMsgPriority_Lowest, // 优先级最低，一般为成员进退群通知(后台下发)
  };

  public enum TIMPlatform
  {
    /// <summary>
    /// <description>未知平台 (Unknown platform)</description>
    /// </summary>
    kTIMPlatform_Other = 0,      // 未知平台
    /// <summary>
    /// <description>Windows平台 (Windows)</description>
    /// </summary>
    kTIMPlatform_Windows,        // Windows平台
    /// <summary>
    /// <description>Android平台 (Android)</description>
    /// </summary>
    kTIMPlatform_Android,        // Android平台
    /// <summary>
    /// <description>iOS平台 (iOS)</description>
    /// </summary>
    kTIMPlatform_IOS,            // iOS平台
    /// <summary>
    /// <description>MacOS平台 (MacOS)</description>
    /// </summary>
    kTIMPlatform_Mac,            // MacOS平台
    /// <summary>
    /// <description>iOS模拟器平台 (iOS simulator)</description>
    /// </summary>
    kTIMPlatform_Simulator,      // iOS模拟器平台
  };

  public enum TIMMsgStatus
  {
    /// <summary>
    /// <description>消息正在发送 (Sending)</description>
    /// </summary>
    kTIMMsg_Sending = 1,        // 消息正在发送
    /// <summary>
    /// <description>消息发送成功 (Sent successfully)</description>
    /// </summary>
    kTIMMsg_SendSucc = 2,       // 消息发送成功
    /// <summary>
    /// <description>消息发送失败 (Sending failed)</description>
    /// </summary>
    kTIMMsg_SendFail = 3,       // 消息发送失败
    /// <summary>
    /// <description>消息已删除 (Message deleted)</description>
    /// </summary>
    kTIMMsg_Deleted = 4,        // 消息已删除
    /// <summary>
    /// <description>消息导入状态 (Message locally imported)</description>
    /// </summary>
    kTIMMsg_LocalImported = 5,  // 消息导入状态
    /// <summary>
    /// <description>消息撤回状态 (Message revoked)</description>
    /// </summary>
    kTIMMsg_Revoked = 6,        // 消息撤回状态
    /// <summary>
    /// <description>消息取消 (Message cancelled)</description>
    /// </summary>
    kTIMMsg_Cancel = 7,         // 消息取消

  };

  public enum TIMGenderType
  {
    /// <summary>
    /// <description>未知性别 (Unknown gender)</description>
    /// </summary>
    kTIMGenderType_Unkown, // 未知性别
    /// <summary>
    /// <description>性别男 (Male)</description>
    /// </summary>
    kTIMGenderType_Male,   // 性别男
    /// <summary>
    /// <description>性别女 (Female)</description>
    /// </summary>
    kTIMGenderType_Female, // 性别女
  };
  public enum TIMProfileAddPermission
  {
    /// <summary>
    /// <description>未知 (Unknown permission)</description>
    /// </summary>
    kTIMProfileAddPermission_Unknown,       // 未知
    /// <summary>
    /// <description>允许任何人添加好友 (Allow anyone add me as friend)</description>
    /// </summary>
    kTIMProfileAddPermission_AllowAny,      // 允许任何人添加好友
    /// <summary>
    /// <description>添加好友需要验证 (Confirmation before add me as friend)</description>
    /// </summary>
    kTIMProfileAddPermission_NeedConfirm,   // 添加好友需要验证
    /// <summary>
    /// <description>拒绝任何人添加好友 (Deny anyone add me as friend)</description>
    /// </summary>
    kTIMProfileAddPermission_DenyAny,       // 拒绝任何人添加好友
  };

  public enum TIMElemType
  {
    /// <summary>
    /// <description>文本元素 (Text element)</description>
    /// </summary>
    kTIMElem_Text,           // 文本元素
    /// <summary>
    /// <description>图片元素 (Image element)</description>
    /// </summary>
    kTIMElem_Image,          // 图片元素
    /// <summary>
    /// <description>声音元素 (Sound element)</description>
    /// </summary>
    kTIMElem_Sound,          // 声音元素
    /// <summary>
    /// <description>自定义元素 (Custom element)</description>
    /// </summary>
    kTIMElem_Custom,         // 自定义元素
    /// <summary>
    /// <description>文件元素 (File element)</description>
    /// </summary>
    kTIMElem_File,           // 文件元素
    /// <summary>
    /// <description>群组系统消息元素 (Group tips element)</description>
    /// </summary>
    kTIMElem_GroupTips,      // 群组系统消息元素
    /// <summary>
    /// <description>表情元素 (Face element)</description>
    /// </summary>
    kTIMElem_Face,           // 表情元素
    /// <summary>
    /// <description>位置元素 (Location element)</description>
    /// </summary>
    kTIMElem_Location,       // 位置元素
    /// <summary>
    /// <description>群组系统通知元素 (Group report element)</description>
    /// </summary>
    kTIMElem_GroupReport,    // 群组系统通知元素
    /// <summary>
    /// <description>视频元素 (Video element)</description>
    /// </summary>
    kTIMElem_Video,          // 视频元素
    /// <summary>
    /// <description>关系链变更消息元素 (Friendship changed element)</description>
    /// </summary>
    kTIMElem_FriendChange,   // 关系链变更消息元素
    /// <summary>
    /// <description>资料变更消息元素 (Profile changed element)</description>
    /// </summary>
    kTIMElem_ProfileChange,  // 资料变更消息元素
    /// <summary>
    /// <description>合并消息元素 (Merge element)</description>
    /// </summary>
    kTIMElem_Merge,          // 合并消息元素
    /// <summary>
    /// <description>未知元素类型 (Invalid element)</description>
    /// </summary>
    kTIMElem_Invalid = -1,   // 未知元素类型
  };
  public enum TIMImageLevel
  {
    /// <summary>
    /// <description>原图发送 (Original image)</description>
    /// </summary>
    kTIMImageLevel_Orig,        // 原图发送
    /// <summary>
    /// <description>高压缩率图发送(图片较小,默认值) (Compressed image (small image, default))</description>
    /// </summary>
    kTIMImageLevel_Compression, // 高压缩率图发送(图片较小,默认值)
    /// <summary>
    /// <description>高清图发送(图片较大) (HD image (large image))</description>
    /// </summary>
    kTIMImageLevel_HD,          // 高清图发送(图片较大)
  };
  public enum TIMGroupTipType
  {
    /// <summary>
    /// <description>无效的群提示 (Invalid group tip)</description>
    /// </summary>
    kTIMGroupTip_None,              // 无效的群提示
    /// <summary>
    /// <description>邀请加入提示 (Inviting group tip)</description>
    /// </summary>
    kTIMGroupTip_Invite,            // 邀请加入提示
    /// <summary>
    /// <description>退群提示 (Quiting group tip)</description>
    /// </summary>
    kTIMGroupTip_Quit,              // 退群提示
    /// <summary>
    /// <description>踢人提示 (Kicking group tip)</description>
    /// </summary>
    kTIMGroupTip_Kick,              // 踢人提示
    /// <summary>
    /// <description>设置管理员提示 (Seting admin group tip)</description>
    /// </summary>
    kTIMGroupTip_SetAdmin,          // 设置管理员提示
    /// <summary>
    /// <description>取消管理员提示 (Cancelling admin group tip)</description>
    /// </summary>
    kTIMGroupTip_CancelAdmin,       // 取消管理员提示
    /// <summary>
    /// <description>群信息修改提示 (Group info changed group tip)</description>
    /// </summary>
    kTIMGroupTip_GroupInfoChange,   // 群信息修改提示
    /// <summary>
    /// <description>群成员信息修改提示 (Group member info changed group tip)</description>
    /// </summary>
    kTIMGroupTip_MemberInfoChange,  // 群成员信息修改提示
  };
  public enum TIMGroupTipGroupChangeFlag
  {
    /// <summary>
    /// <description>未知的修改 (Unknown group tip changed flag)</description>
    /// </summary>
    kTIMGroupTipChangeFlag_Unknown,      // 未知的修改
    /// <summary>
    /// <description>修改群组名称 (Group name changed flag)</description>
    /// </summary>
    kTIMGroupTipChangeFlag_Name,         // 修改群组名称
    /// <summary>
    /// <description>修改群简介 (Group introduction changed flag)</description>
    /// </summary>
    kTIMGroupTipChangeFlag_Introduction, // 修改群简介
    /// <summary>
    /// <description>修改群公告 (Group notification changed flag)</description>
    /// </summary>
    kTIMGroupTipChangeFlag_Notification, // 修改群公告
    /// <summary>
    /// <description>修改群头像URL (Group avatar URL changed flag)</description>
    /// </summary>
    kTIMGroupTipChangeFlag_FaceUrl,      // 修改群头像URL
    /// <summary>
    /// <description>修改群所有者 (Group changed owner)</description>
    /// </summary>
    kTIMGroupTipChangeFlag_Owner,        // 修改群所有者
    /// <summary>
    /// <description>修改群自定义信息 (Group custom data changed flag)</description>
    /// </summary>
    kTIMGroupTipChangeFlag_Custom,       // 修改群自定义信息
    /// <summary>
    /// <description>群属性变更 (新增) (Group attributes (added) changed flag)</description>
    /// </summary>
    kTIMGroupTipChangeFlag_Attribute,    // 群属性变更 (新增)
  };
  public enum TIMGroupReportType
  {
    /// <summary>
    /// <description>未知类型 (Unknown group report)</description>
    /// </summary>
    kTIMGroupReport_None,         // 未知类型
    /// <summary>
    /// <description>申请加群(只有管理员会接收到) (Join group request's group report (Only for group admin))</description>
    /// </summary>
    kTIMGroupReport_AddRequest,   // 申请加群(只有管理员会接收到)
    /// <summary>
    /// <description>申请加群被同意(只有申请人自己接收到) (Group request admission's group report (Only for applicant))</description>
    /// </summary>
    kTIMGroupReport_AddAccept,    // 申请加群被同意(只有申请人自己接收到)
    /// <summary>
    /// <description>申请加群被拒绝(只有申请人自己接收到) (Group request denied's group report (Only for applicant))</description>
    /// </summary>
    kTIMGroupReport_AddRefuse,    // 申请加群被拒绝(只有申请人自己接收到)
    /// <summary>
    /// <description>被管理员踢出群(只有被踢者接收到) (Being Kicked out's group report (Only for operant))</description>
    /// </summary>
    kTIMGroupReport_BeKicked,     // 被管理员踢出群(只有被踢者接收到)
    /// <summary>
    /// <description>群被解散(全员接收) (Group dismissed's group report (For all group members))</description>
    /// </summary>
    kTIMGroupReport_Delete,       // 群被解散(全员接收)
    /// <summary>
    /// <description>创建群(创建者接收, 不展示) (Group created's group report (Only for creator, no displaying))</description>
    /// </summary>
    kTIMGroupReport_Create,       // 创建群(创建者接收, 不展示)
    /// <summary>
    /// <description>无需被邀请者同意，拉入群中（例如工作群） (Invitation's group report (No confirmation, eg. Working group))</description>
    /// </summary>
    kTIMGroupReport_Invite,       // 无需被邀请者同意，拉入群中（例如工作群）
    /// <summary>
    /// <description>主动退群(主动退出者接收, 不展示) (Quited from group's group report (Only for operator, no displaying))</description>
    /// </summary>
    kTIMGroupReport_Quit,         // 主动退群(主动退出者接收, 不展示)
    /// <summary>
    /// <description>设置管理员(被设置者接收) (Granted admin's group report (Operant only))</description>
    /// </summary>
    kTIMGroupReport_GrantAdmin,   // 设置管理员(被设置者接收)
    /// <summary>
    /// <description>取消管理员(被取消者接收) (Cancelled admin's group report (Operant only))</description>
    /// </summary>
    kTIMGroupReport_CancelAdmin,  // 取消管理员(被取消者接收)
    /// <summary>
    /// <description>群已被回收(全员接收, 不展示) (Recycled group's report (For all group member, no displaying))</description>
    /// </summary>
    kTIMGroupReport_GroupRecycle, // 群已被回收(全员接收, 不展示)
    /// <summary>
    /// <description>被邀请者收到邀请，由被邀请者同意是否接受 (Invitation requset received, operant determines to accept or not)</description>
    /// </summary>
    kTIMGroupReport_InviteReq,    // 被邀请者收到邀请，由被邀请者同意是否接受
    /// <summary>
    /// <description>邀请加群被同意(只有发出邀请者会接收到) (Invitation accepted (Only for inviter))</description>
    /// </summary>
    kTIMGroupReport_InviteAccept, // 邀请加群被同意(只有发出邀请者会接收到)
    /// <summary>
    /// <description>邀请加群被拒绝(只有发出邀请者会接收到) (Invitation rejected (Only for inviter))</description>
    /// </summary>
    kTIMGroupReport_InviteRefuse, // 邀请加群被拒绝(只有发出邀请者会接收到)
    /// <summary>
    /// <description>已读上报多终端同步通知(只有上报人自己收到) (Tip's report read (multi-platform synchronization tip, only for reporter))</description>
    /// </summary>
    kTIMGroupReport_ReadReport,   // 已读上报多终端同步通知(只有上报人自己收到)
    /// <summary>
    /// <description>用户自定义通知(默认全员接收) (User defined tip (Default for all group members))</description>
    /// </summary>
    kTIMGroupReport_UserDefine,   // 用户自定义通知(默认全员接收)
  };

  public enum TIMReceiveMessageOpt
  {
    /// <summary>
    /// <description>在线正常接收消息，离线时会进行 APNs 推送 (Receive online message, offline message goes through APNs)</description>
    /// </summary>
    kTIMRecvMsgOpt_Receive = 0,  // 在线正常接收消息，离线时会进行 APNs 推送
    /// <summary>
    /// <description>不会接收到消息，离线不会有推送通知 (Receive no message (online & offline))</description>
    /// </summary>
    kTIMRecvMsgOpt_Not_Receive,  // 不会接收到消息，离线不会有推送通知
    /// <summary>
    /// <description>在线正常接收消息，离线不会有推送通知 (Receive only online message)</description>
    /// </summary>
    kTIMRecvMsgOpt_Not_Notify,   // 在线正常接收消息，离线不会有推送通知
  };
  public enum TIMProfileChangeType
  {
    /// <summary>
    /// <description>未知类型 (Unknown type)</description>
    /// </summary>
    kTIMProfileChange_None,       // 未知类型
    /// <summary>
    /// <description>资料修改 (Profile changed)</description>
    /// </summary>
    kTIMProfileChange_Profile,    // 资料修改
  };
  public enum TIMOfflinePushFlag
  {
    /// <summary>
    /// <description>按照默认规则进行推送 (Default offline push)</description>
    /// </summary>
    kTIMOfflinePushFlag_Default,   // 按照默认规则进行推送
    /// <summary>
    /// <description>不进行推送 (No offline push)</description>
    /// </summary>
    kTIMOfflinePushFlag_NoPush,    // 不进行推送
  };
  public enum TIMAndroidOfflinePushNotifyMode
  {
    /// <summary>
    /// <description>普通通知栏消息模式，离线消息下发后，点击通知栏消息直接启动应用，不会给应用进行回调 (Normal Android offline push notification mode. Offline message sends as notification, and click the notification may launch the APP.)</description>
    /// </summary>
    kTIMAndroidOfflinePushNotifyMode_Normal,   // 普通通知栏消息模式，离线消息下发后，点击通知栏消息直接启动应用，不会给应用进行回调
    /// <summary>
    /// <description>自定义消息模式，离线消息下发后，点击通知栏消息会给应用进行回调 (Custom Andoird offline push notification mode. Click notification will trigger custom callback.)</description>
    /// </summary>
    kTIMAndroidOfflinePushNotifyMode_Custom,   // 自定义消息模式，离线消息下发后，点击通知栏消息会给应用进行回调
  };
  public enum TIMGroupMemberRole
  {
    /// <summary>
    /// <description>未定义 (Unknown member role)</description>
    /// </summary>
    kTIMMemberRole_None = 0,    // 未定义
    /// <summary>
    /// <description>群成员 (Group member)</description>
    /// </summary>
    kTIMMemberRole_Normal = 200,  // 群成员
    /// <summary>
    /// <description>管理员 (Group admin)</description>
    /// </summary>
    kTIMMemberRole_Admin = 300,  // 管理员
    /// <summary>
    /// <description>超级管理员(群主） (Group super admin (Owner))</description>
    /// </summary>
    kTIMMemberRole_Owner = 400,  // 超级管理员(群主）
  };
  public enum TIMDownloadType
  {
    /// <summary>
    /// <description>视频缩略图 (Video thumbnail)</description>
    /// </summary>
    kTIMDownload_VideoThumb = 0, // 视频缩略图
    /// <summary>
    /// <description>文件 (File)</description>
    /// </summary>
    kTIMDownload_File,           // 文件
    /// <summary>
    /// <description>视频 (Video)</description>
    /// </summary>
    kTIMDownload_Video,          // 视频
    /// <summary>
    /// <description>声音 (Sound)</description>
    /// </summary>
    kTIMDownload_Sound,          // 声音
  };
  public enum TIMKeywordListMatchType
  {
    /// <summary>
    /// <description>Or</description>
    /// </summary>
    TIMKeywordListMatchType_Or,
    /// <summary>
    /// <description>And</description>
    /// </summary>
    TIMKeywordListMatchType_And
  };

  public enum TIMGroupType
  {
    /// <summary>
    /// <description>公开群（Public），成员上限 2000 人，任何人都可以申请加群，但加群需群主或管理员审批，适合用于类似 QQ 中由群主管理的兴趣群。 (Public group, maximum 2000 members, anyone can apply to join the group and wait for admin's approval. Like QQ group)</description>
    /// </summary>
    kTIMGroup_Public,     // 公开群（Public），成员上限 2000 人，任何人都可以申请加群，但加群需群主或管理员审批，适合用于类似 QQ 中由群主管理的兴趣群。
    /// <summary>
    /// <description>工作群（Work），成员上限 200  人，不支持由用户主动加入，需要他人邀请入群，适合用于类似微信中随意组建的工作群（对应老版本的 Private 群）。 (Work group, maximum 200 members, invite members only. Like WeChat's work group (Old version's Private group))</description>
    /// </summary>
    kTIMGroup_Private,    // 工作群（Work），成员上限 200  人，不支持由用户主动加入，需要他人邀请入群，适合用于类似微信中随意组建的工作群（对应老版本的 Private 群）。
    /// <summary>
    /// <description>会议群（Meeting），成员上限 6000 人，任何人都可以自由进出，且加群无需被审批，适合用于视频会议和在线培训等场景（对应老版本的 ChatRoom 群）。 (Meeting group, maximum 6000 members, anyone can join freely without permission, used for online video meeting. (Old version's ChatRoom group))</description>
    /// </summary>
    kTIMGroup_ChatRoom,   // 会议群（Meeting），成员上限 6000 人，任何人都可以自由进出，且加群无需被审批，适合用于视频会议和在线培训等场景（对应老版本的 ChatRoom 群）。
    /// <summary>
    /// <description>在线成员广播大群，推荐使用 直播群（AVChatRoom） (Broadcast chat room group, please use AVChatRoom)</description>
    /// </summary>
    kTIMGroup_BChatRoom,  // 在线成员广播大群，推荐使用 直播群（AVChatRoom）
    /// <summary>
    /// <description>直播群（AVChatRoom），人数无上限，任何人都可以自由进出，消息吞吐量大，适合用作直播场景中的高并发弹幕聊天室。 (AVChatRoom, unlimited group members, anyone can join freely and provide high-volume group messages, used for live streaming chat room)</description>
    /// </summary>
    kTIMGroup_AVChatRoom, // 直播群（AVChatRoom），人数无上限，任何人都可以自由进出，消息吞吐量大，适合用作直播场景中的高并发弹幕聊天室。
    /// <summary>
    /// <description>社群（Community），成员上限 100000 人，任何人都可以自由进出，且加群无需被审批，适合用于知识分享和游戏交流等超大社区群聊场景。5.8 版本开始支持，需要您购买旗舰版套餐。 (Community, maximum 100,000 members, anyone joins freely without permission, used for knowledge sharing and game community. (Available ^5.8 and Flagship package only))</description>
    /// </summary>
    kTIMGroup_Community,  // 社群（Community），成员上限 100000 人，任何人都可以自由进出，且加群无需被审批，适合用于知识分享和游戏交流等超大社区群聊场景。5.8 版本开始支持，需要您购买旗舰版套餐。
  };
  public enum TIMGroupAddOption
  {
    /// <summary>
    /// <description>禁止加群 (Forbid Joining group)</description>
    /// </summary>
    kTIMGroupAddOpt_Forbid = 0,  // 禁止加群
    /// <summary>
    /// <description>需要管理员审批 (Admin confirmation before joining group)</description>
    /// </summary>
    kTIMGroupAddOpt_Auth = 1,    // 需要管理员审批
    /// <summary>
    /// <description>任何人都可以加群 (Anyone can freely join the group)</description>
    /// </summary>
    kTIMGroupAddOpt_Any = 2,     // 任何人都可以加群
  };
  public enum TIMGroupModifyInfoFlag
  {
    /// <summary>
    /// <description>None</description>
    /// </summary>
    kTIMGroupModifyInfoFlag_None = 0x00,
    /// <summary>
    /// <description>修改群组名称 (Modify group name)</description>
    /// </summary>
    kTIMGroupModifyInfoFlag_Name = 0x01,       // 修改群组名称
    /// <summary>
    /// <description>修改群公告 (Modify group notification)</description>
    /// </summary>
    kTIMGroupModifyInfoFlag_Notification = 0x01 << 1,  // 修改群公告
    /// <summary>
    /// <description>修改群简介 (Modify group introduction)</description>
    /// </summary>
    kTIMGroupModifyInfoFlag_Introduction = 0x01 << 2,  // 修改群简介
    /// <summary>
    /// <description>修改群头像URL (Modify group avatar URL)</description>
    /// </summary>
    kTIMGroupModifyInfoFlag_FaceUrl = 0x01 << 3,  // 修改群头像URL
    /// <summary>
    /// <description>修改群组添加选项 (Modify joining group option)</description>
    /// </summary>
    kTIMGroupModifyInfoFlag_AddOption = 0x01 << 4,  // 修改群组添加选项
    /// <summary>
    /// <description>修改群最大成员数 (Modify maximum group member)</description>
    /// </summary>
    kTIMGroupModifyInfoFlag_MaxMmeberNum = 0x01 << 5,  // 修改群最大成员数
    /// <summary>
    /// <description>修改群是否可见 (modify is group visible)</description>
    /// </summary>
    kTIMGroupModifyInfoFlag_Visible = 0x01 << 6,  // 修改群是否可见
    /// <summary>
    /// <description>修改群是否允许被搜索 (Modify is group searchable)</description>
    /// </summary>
    kTIMGroupModifyInfoFlag_Searchable = 0x01 << 7,  // 修改群是否允许被搜索
    /// <summary>
    /// <description>修改群是否全体禁言 (Modify is group all muted)</description>
    /// </summary>
    kTIMGroupModifyInfoFlag_ShutupAll = 0x01 << 8,  // 修改群是否全体禁言
    /// <summary>
    /// <description>修改群自定义信息 (Modify group custom data)</description>
    /// </summary>
    kTIMGroupModifyInfoFlag_Custom = 0x01 << 9,  // 修改群自定义信息
    /// <summary>
    /// <description>修改群主 (Modify group owner)</description>
    /// </summary>
    kTIMGroupModifyInfoFlag_Owner = 0x01 << 31, // 修改群主

  };
  public enum TIMGroupMemberInfoFlag
  {
    /// <summary>
    /// <description>无 (None)</description>
    /// </summary>
    kTIMGroupMemberInfoFlag_None = 0x00,       // 无
    /// <summary>
    /// <description>加入时间 (Join time)</description>
    /// </summary>
    kTIMGroupMemberInfoFlag_JoinTime = 0x01,       // 加入时间
    /// <summary>
    /// <description>群消息接收选项 (Receiving message option)</description>
    /// </summary>
    kTIMGroupMemberInfoFlag_MsgFlag = 0x01 << 1,  // 群消息接收选项
    /// <summary>
    /// <description>成员已读消息seq (Read message seq)</description>
    /// </summary>
    kTIMGroupMemberInfoFlag_MsgSeq = 0x01 << 2,  // 成员已读消息seq
    /// <summary>
    /// <description>成员角色 (Member role)</description>
    /// </summary>
    kTIMGroupMemberInfoFlag_MemberRole = 0x01 << 3,  // 成员角色
    /// <summary>
    /// <description>禁言时间。当该值为0时表示没有被禁言 (Mute time, 0 means unmute)</description>
    /// </summary>
    kTIMGroupMemberInfoFlag_ShutupUntill = 0x01 << 4,  // 禁言时间。当该值为0时表示没有被禁言
    /// <summary>
    /// <description>群名片 (Group name card)</description>
    /// </summary>
    kTIMGroupMemberInfoFlag_NameCard = 0x01 << 5,  // 群名片
  };


  public enum TIMGroupMemberRoleFlag
  {
    /// <summary>
    /// <description>获取全部角色类型 (All role)</description>
    /// </summary>
    kTIMGroupMemberRoleFlag_All = 0x00,       // 获取全部角色类型
    /// <summary>
    /// <description>获取所有者(群主) (Owner only)</description>
    /// </summary>
    kTIMGroupMemberRoleFlag_Owner = 0x01,       // 获取所有者(群主)
    /// <summary>
    /// <description>获取管理员，不包括群主 (Admin only, without the owner)</description>
    /// </summary>
    kTIMGroupMemberRoleFlag_Admin = 0x01 << 1,  // 获取管理员，不包括群主
    /// <summary>
    /// <description>获取普通群成员，不包括群主和管理员 (Normal members only)</description>
    /// </summary>
    kTIMGroupMemberRoleFlag_Member = 0x01 << 2,  // 获取普通群成员，不包括群主和管理员
  };
  public enum TIMGroupMemberModifyInfoFlag
  {
    /// <summary>
    /// <description>None</description>
    /// </summary>
    kTIMGroupMemberModifyFlag_None = 0x00,      //
    /// <summary>
    /// <description>修改消息接收选项 (Modify receiving message option)</description>
    /// </summary>
    kTIMGroupMemberModifyFlag_MsgFlag = 0x01,      // 修改消息接收选项
    /// <summary>
    /// <description>修改成员角色 (Modify member role)</description>
    /// </summary>
    kTIMGroupMemberModifyFlag_MemberRole = 0x01 << 1, // 修改成员角色
    /// <summary>
    /// <description>修改禁言时间 (Modify member muted time)</description>
    /// </summary>
    kTIMGroupMemberModifyFlag_ShutupTime = 0x01 << 2, // 修改禁言时间
    /// <summary>
    /// <description>修改群名片 (Modify name card)</description>
    /// </summary>
    kTIMGroupMemberModifyFlag_NameCard = 0x01 << 3, // 修改群名片
    /// <summary>
    /// <description>修改群成员自定义信息 (Modify group member custom data)</description>
    /// </summary>
    kTIMGroupMemberModifyFlag_Custom = 0x01 << 4, // 修改群成员自定义信息

  };
  public enum TIMGroupPendencyType
  {
    /// <summary>
    /// <description>请求加群 (Request join)</description>
    /// </summary>
    kTIMGroupPendency_RequestJoin = 0,  // 请求加群
    /// <summary>
    /// <description>邀请加群 (Invite join)</description>
    /// </summary>
    kTIMGroupPendency_InviteJoin = 1,   // 邀请加群
    /// <summary>
    /// <description>邀请和请求的 (Request and invite join)</description>
    /// </summary>
    kTIMGroupPendency_ReqAndInvite = 2, // 邀请和请求的
  };
  public enum TIMGroupPendencyHandle
  {
    /// <summary>
    /// <description>未处理 (Not handled)</description>
    /// </summary>
    kTIMGroupPendency_NotHandle = 0,      // 未处理
    /// <summary>
    /// <description>他人处理 (Other handled)</description>
    /// </summary>
    kTIMGroupPendency_OtherHandle = 1,    // 他人处理
    /// <summary>
    /// <description>操作方处理 (Operator handled)</description>
    /// </summary>
    kTIMGroupPendency_OperatorHandle = 2, // 操作方处理
  };

  /**
  * @brief 群未决处理操作类型
*/
  public enum TIMGroupPendencyHandleResult
  {
    /// <summary>
    /// <description>拒绝 (Refuse)</description>
    /// </summary>
    kTIMGroupPendency_Refuse = 0,  // 拒绝
    /// <summary>
    /// <description>同意 (Accept)</description>
    /// </summary>
    kTIMGroupPendency_Accept = 1,  // 同意
  };
  public enum TIMGroupSearchFieldKey
  {
    /// <summary>
    /// <description>群 ID (Group ID)</description>
    /// </summary>
    kTIMGroupSearchFieldKey_GroupId = 0x01,  //  群 ID
    /// <summary>
    /// <description>群名称 (Group name)</description>
    /// </summary>
    kTIMGroupSearchFieldKey_GroupName = 0x01 << 1, // 群名称
  };
  public enum TIMGroupMemberSearchFieldKey
  {
    /// <summary>
    /// <description>用户 ID (User ID)</description>
    /// </summary>
    kTIMGroupMemberSearchFieldKey_Identifier = 0x01, // 用户 ID
    /// <summary>
    /// <description>昵称 (Nickname)</description>
    /// </summary>
    kTIMGroupMemberSearchFieldKey_NikeName = 0x01 << 1, // 昵称
    /// <summary>
    /// <description>备注 (Remark)</description>
    /// </summary>
    kTIMGroupMemberSearchFieldKey_Remark = 0x01 << 2, // 备注
    /// <summary>
    /// <description>名片 (Name card)</description>
    /// </summary>
    kTIMGroupMemberSearchFieldKey_NameCard = 0x01 << 3,  // 名片
  };
  public enum TIMFriendType
  {
    /// <summary>
    /// <description>单向好友：用户A的好友表中有用户B，但B的好友表中却没有A (Single friend: B's in A's friend list but not vice versa)</description>
    /// </summary>
    FriendTypeSignle,  // 单向好友：用户A的好友表中有用户B，但B的好友表中却没有A
    /// <summary>
    /// <description>双向好友：用户A的好友表中有用户B，B的好友表中也有A (Both friend: A is friend of B and vice versa)</description>
    /// </summary>
    FriendTypeBoth,    // 双向好友：用户A的好友表中有用户B，B的好友表中也有A
  };
  public enum TIMFriendResponseAction
  {
    /// <summary>
    /// <description>同意 (Agree)</description>
    /// </summary>
    ResponseActionAgree,       // 同意
    /// <summary>
    /// <description>同意并添加 (Agree and add)</description>
    /// </summary>
    ResponseActionAgreeAndAdd, // 同意并添加
    /// <summary>
    /// <description>拒绝 (Reject)</description>
    /// </summary>
    ResponseActionReject,      // 拒绝
  };
  public enum TIMFriendCheckRelation
  {
    /// <summary>
    /// <description>无关系 (No relation)</description>
    /// </summary>
    FriendCheckNoRelation,  // 无关系
    /// <summary>
    /// <description>仅A中有B (Check A with B)</description>
    /// </summary>
    FriendCheckAWithB,      // 仅A中有B
    /// <summary>
    /// <description>仅B中有A (Check B with A)</description>
    /// </summary>
    FriendCheckBWithA,      // 仅B中有A
    /// <summary>
    /// <description>双向的 (Check both way friend)</description>
    /// </summary>
    FriendCheckBothWay,     // 双向的
  };
  public enum TIMFriendPendencyType
  {
    /// <summary>
    /// <description>别人发给我的 (Coming in friend request)</description>
    /// </summary>
    FriendPendencyTypeComeIn,  // 别人发给我的
    /// <summary>
    /// <description>我发给别人的 (Sending out friend request)</description>
    /// </summary>
    FriendPendencyTypeSendOut, // 我发给别人的
    /// <summary>
    /// <description>双向的 (Both way friend request)</description>
    /// </summary>
    FriendPendencyTypeBoth,    // 双向的
  };
  public enum TIMFriendshipSearchFieldKey
  {
    /// <summary>
    /// <description>用户 ID (Search User ID)</description>
    /// </summary>
    kTIMFriendshipSearchFieldKey_Identifier = 0x01,  // 用户 ID
    /// <summary>
    /// <description>昵称 (Search nickname)</description>
    /// </summary>
    kTIMFriendshipSearchFieldKey_NikeName = 0x01 << 1, // 昵称
    /// <summary>
    /// <description>备注 (Search remark)</description>
    /// </summary>
    kTIMFriendshipSearchFieldKey_Remark = 0x01 << 2, // 备注
  };

  public enum TIMConvEvent
  {
    /// <summary>
    /// <description>会话新增,例如收到一条新消息,产生一个新的会话是事件触发 (New conversation. Eg. When receiving a message from nonexistent conversation, it will create a new conversation)</description>
    /// </summary>
    kTIMConvEvent_Add,    // 会话新增,例如收到一条新消息,产生一个新的会话是事件触发
    /// <summary>
    /// <description>会话删除,例如自己删除某会话时会触发 (Delete conversation)</description>
    /// </summary>
    kTIMConvEvent_Del,    // 会话删除,例如自己删除某会话时会触发
    /// <summary>
    /// <description>会话更新,会话内消息的未读计数变化和收到新消息时触发 (Update conversation, when receiving new mesasge or unread count changed)</description>
    /// </summary>
    kTIMConvEvent_Update, // 会话更新,会话内消息的未读计数变化和收到新消息时触发
    /// <summary>
    /// <description>会话开始 (Start conversation)</description>
    /// </summary>
    kTIMConvEvent_Start,  // 会话开始
    /// <summary>
    /// <description>会话结束 (End conversation)</description>
    /// </summary>
    kTIMConvEvent_Finish, // 会话结束

  };
  public enum TIMGroupAtType
  {
    /// <summary>
    /// <description>@ 我 (@ME)</description>
    /// </summary>
    kTIMGroup_At_Me = 1,                    // @ 我
    /// <summary>
    /// <description>@ 群里所有人 (@ALL)</description>
    /// </summary>
    kTIMGroup_At_All,                       // @ 群里所有人
    /// <summary>
    /// <description>@ 群里所有人并且单独 @ 我 (@ALL and @ME)</description>
    /// </summary>
    kTIMGroup_At_All_At_ME,                 // @ 群里所有人并且单独 @ 我
  };
  public enum TIMNetworkStatus
  {
    /// <summary>
    /// <description>已连接 (Connected)</description>
    /// </summary>
    kTIMConnected,       // 已连接
    /// <summary>
    /// <description>失去连接 (Disconnected)</description>
    /// </summary>
    kTIMDisconnected,    // 失去连接
    /// <summary>
    /// <description>正在连接 (Connecting)</description>
    /// </summary>
    kTIMConnecting,      // 正在连接
    /// <summary>
    /// <description>连接失败 (Failed)</description>
    /// </summary>
    kTIMConnectFailed,   // 连接失败
  };

  public enum TIMLogLevel
  {
    /// <summary>
    /// <description>关闭日志输出 (Log off)</description>
    /// </summary>
    kTIMLog_Off,     // 关闭日志输出
    /// <summary>
    /// <description>全量日志 (Test log)</description>
    /// </summary>
    kTIMLog_Test,    // 全量日志
    /// <summary>
    /// <description>开发调试过程中一些详细信息日志 (Verbose log)</description>
    /// </summary>
    kTIMLog_Verbose, // 开发调试过程中一些详细信息日志
    /// <summary>
    /// <description>调试日志 (Debug log)</description>
    /// </summary>
    kTIMLog_Debug,   // 调试日志
    /// <summary>
    /// <description>信息日志 (Info log)</description>
    /// </summary>
    kTIMLog_Info,    // 信息日志
    /// <summary>
    /// <description>警告日志 (Warning log)</description>
    /// </summary>
    kTIMLog_Warn,    // 警告日志
    /// <summary>
    /// <description>错误日志 (Error log)</description>
    /// </summary>
    kTIMLog_Error,   // 错误日志
    /// <summary>
    /// <description>断言日志 (Assertion log)</description>
    /// </summary>
    kTIMLog_Assert,  // 断言日志
  };
  public enum TIMGroupGetInfoFlag
  {
    /// <summary>
    /// <description>None</description>
    /// </summary>
    kTIMGroupInfoFlag_None = 0x00,
    /// <summary>
    /// <description>群组名称 (Group name)</description>
    /// </summary>
    kTIMGroupInfoFlag_Name = 0x01,       // 群组名称
    /// <summary>
    /// <description>群组创建时间 (Group created time)</description>
    /// </summary>
    kTIMGroupInfoFlag_CreateTime = 0x01 << 1,  // 群组创建时间
    /// <summary>
    /// <description>群组创建者帐号 (Group owner UIN)</description>
    /// </summary>
    kTIMGroupInfoFlag_OwnerUin = 0x01 << 2,  // 群组创建者帐号
    /// <summary>
    /// <description>Seq (Group seq)</description>
    /// </summary>
    kTIMGroupInfoFlag_Seq = 0x01 << 3,
    /// <summary>
    /// <description>群组信息最后修改时间 (Group last modified time)</description>
    /// </summary>
    kTIMGroupInfoFlag_LastTime = 0x01 << 4,  // 群组信息最后修改时间
    /// <summary>
    /// <description>NextMsgSeq (Group next message seq)</description>
    /// </summary>
    kTIMGroupInfoFlag_NextMsgSeq = 0x01 << 5,
    /// <summary>
    /// <description>最新群组消息时间 (Group last message time)</description>
    /// </summary>
    kTIMGroupInfoFlag_LastMsgTime = 0X01 << 6,  // 最新群组消息时间
    /// <summary>
    /// <description>AppId</description>
    /// </summary>
    kTIMGroupInfoFlag_AppId = 0x01 << 7,
    /// <summary>
    /// <description>群组成员数量 (Group member count)</description>
    /// </summary>
    kTIMGroupInfoFlag_MemberNum = 0x01 << 8,  // 群组成员数量
    /// <summary>
    /// <description>群组成员最大数量 (Group maximum member count)</description>
    /// </summary>
    kTIMGroupInfoFlag_MaxMemberNum = 0x01 << 9,  // 群组成员最大数量
    /// <summary>
    /// <description>群公告内容 (Group notification)</description>
    /// </summary>
    kTIMGroupInfoFlag_Notification = 0x01 << 10, // 群公告内容
    /// <summary>
    /// <description>群简介内容 (Group introduction)</description>
    /// </summary>
    kTIMGroupInfoFlag_Introduction = 0x01 << 11, // 群简介内容
    /// <summary>
    /// <description>群头像URL (Group avatar URL)</description>
    /// </summary>
    kTIMGroupInfoFlag_FaceUrl = 0x01 << 12, // 群头像URL
    /// <summary>
    /// <description>加群选项 (Group add option)</description>
    /// </summary>
    kTIMGroupInfoFlag_AddOpton = 0x01 << 13, // 加群选项
    /// <summary>
    /// <description>群类型 (Group type)</description>
    /// </summary>
    kTIMGroupInfoFlag_GroupType = 0x01 << 14, // 群类型
    /// <summary>
    /// <description>群组内最新一条消息 (Group last message)</description>
    /// </summary>
    kTIMGroupInfoFlag_LastMsg = 0x01 << 15, // 群组内最新一条消息
    /// <summary>
    /// <description>群组在线成员数 (Group online member count)</description>
    /// </summary>
    kTIMGroupInfoFlag_OnlineNum = 0x01 << 16, // 群组在线成员数
    /// <summary>
    /// <description>群组是否可见 (Is group visible)</description>
    /// </summary>
    kTIMGroupInfoFlag_Visible = 0x01 << 17, // 群组是否可见
    /// <summary>
    /// <description>群组是否可以搜索 (Is group searchable)</description>
    /// </summary>
    kTIMGroupInfoFlag_Searchable = 0x01 << 18, // 群组是否可以搜索
    /// <summary>
    /// <description>群组是否全禁言 (Is all muted)</description>
    /// </summary>
    kTIMGroupInfoFlag_ShutupAll = 0x01 << 19, // 群组是否全禁言
  };

  public enum TIMInternalOperation
  {
    /// <summary>
    /// <description>internal_operation_sso_data</description>
    /// </summary>
    internal_operation_sso_data,
    /// <summary>
    /// <description>internal_operation_userid_tinyid</description>
    /// </summary>
    internal_operation_userid_tinyid,
    /// <summary>
    /// <description>internal_operation_tinyid_userid</description>
    /// </summary>
    internal_operation_tinyid_userid,
    /// <summary>
    /// <description>internal_operation_set_env</description>
    /// </summary>
    internal_operation_set_env,
    /// <summary>
    /// <description>internal_operation_set_max_retry_count</description>
    /// </summary>
    internal_operation_set_max_retry_count,
    /// <summary>
    /// <description>internal_operation_set_custom_server_info</description>
    /// </summary>
    internal_operation_set_custom_server_info,
    /// <summary>
    /// <description>internal_operation_set_sm4_gcm_callback</description>
    /// </summary>
    internal_operation_set_sm4_gcm_callback,
    /// <summary>
    /// <description>internal_operation_init_local_storage</description>
    /// </summary>
    internal_operation_init_local_storage,
    /// <summary>
    /// <description>internal_operation_set_cos_save_region_for_conversation</description>
    /// </summary>
    internal_operation_set_cos_save_region_for_conversation,
    /// <summary>
    /// <description>internal_operation_set_ui_platform</description>
    /// </summary>
    internal_operation_set_ui_platform,

  }

  public enum HandleGroupMemberResult
  {
    /// <summary>
    /// <description>kTIMGroupMember_HandledErr 失败 (Fail)</description>
    /// </summary>
    kTIMGroupMember_HandledErr,
    /// <summary>
    /// <description>kTIMGroupMember_HandledSuc 成功 (Success)</description>
    /// </summary>
    kTIMGroupMember_HandledSuc,
    /// <summary>
    /// <description>kTIMGroupMember_Included 已是群成员 (Member already)</description>
    /// </summary>
    kTIMGroupMember_Included,
    /// <summary>
    /// <description>kTIMGroupMember_Invited 已发送邀请 (Invited)</description>
    /// </summary>
    kTIMGroupMember_Invited,
  };

  public enum TIMFriendshipRelationType
  {
    /// <summary>
    /// <description>kTIMFriendshipRelationType_None 未知关系 (Unknown relation type)</description>
    /// </summary>
    kTIMFriendshipRelationType_None,
    /// <summary>
    /// <description>kTIMFriendshipRelationType_InMyFriendList 单向好友：对方是我的好友，我不是对方的好友 (Single friend: I'm peer's friend only)</description>
    /// </summary>
    kTIMFriendshipRelationType_InMyFriendList,
    /// <summary>
    /// <description>kTIMFriendshipRelationType_InOtherFriendList 单向好友：对方不是我的好友，我是对方的好友 (Single friend: Peer is my friend only)</description>
    /// </summary>
    kTIMFriendshipRelationType_InOtherFriendList,
    /// <summary>
    /// <description>kTIMFriendshipRelationType_BothFriend 双向好友 (Both way friend)</description>
    /// </summary>
    kTIMFriendshipRelationType_BothFriend,
  };

  public enum TIMGroupMessageReadMembersFilter
  {
    /// <summary>
    /// <description>群消息已读成员列表 (Group message read member list)</description>
    /// </summary>
    TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ = 0,  // 群消息已读成员列表
    /// <summary>
    /// <description>群消息未读成员列表 (Group message unread member list)</description>
    /// </summary>
    TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_UNREAD = 1,  // 群消息未读成员列表
  };

  public enum TIMUserStatusType
  {
    /// <summary>
    /// <description>未知状态 (Unknown status)</description>
    /// </summary>
    kTIMUserStatusType_Unkown = 0,  // 未知状态
    /// <summary>
    /// <description>在线状态 (Online)</description>
    /// </summary>
    kTIMUserStatusType_Online = 1,  // 在线状态
    /// <summary>
    /// <description>离线状态 (Offline)</description>
    /// </summary>
    kTIMUserStatusType_Offline = 2,  // 离线状态
    /// <summary>
    /// <description>未登录 (Unlogged in (called TIMLogout or never logged in))</description>
    /// </summary>
    kTIMUserStatusType_UnLogined = 3,  // 未登录（如主动调用 TIMLogout 接口，或者账号注册后还未登录）
  };
}