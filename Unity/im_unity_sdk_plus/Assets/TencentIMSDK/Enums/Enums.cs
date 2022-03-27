namespace com.tencent.imsdk.unity.enums
{
    public enum TIMResult
    {
        /// <summary>
        /// <description>接口调用成功</description>
        /// </summary>
        TIM_SUCC = 0,
        /// <summary>
        /// <description>接口调用失败，ImSDK未初始化</description>
        /// </summary>     
        TIM_ERR_SDKUNINIT = -1,// 接口调用失败，ImSDK未初始化
        /// <summary>
        /// <description>接口调用失败，用户未登录</description>
        /// </summary>
        TIM_ERR_NOTLOGIN = -2, // 接口调用失败，用户未登录
        /// <summary>
        /// <description>接口调用失败，错误的Json格式或Json Key</description>
        /// </summary>
        TIM_ERR_JSON = -3,     // 接口调用失败，错误的Json格式或Json Key
        /// <summary>
        /// <description>接口调用失败，参数错误</description>
        /// </summary>
        TIM_ERR_PARAM = -4,    // 接口调用失败，参数错误
        /// <summary>
        /// <description>接口调用失败，无效的会话</description>
        /// </summary>
        TIM_ERR_CONV = -5,     // 接口调用失败，无效的会话
        /// <summary>
        /// <description>接口调用失败，无效的群组</description>
        /// </summary>
        TIM_ERR_GROUP = -6,    // 接口调用失败，无效的群组
    };
    public enum TIMLoginStatus
    {
        /// <summary>
        /// <description>已登录</description>
        /// </summary>
        kTIMLoginStatus_Logined = 1,     // 已登录
        /// <summary>
        /// <description>登录中</description>
        /// </summary>
        kTIMLoginStatus_Logining = 2,    // 登录中
        /// <summary>
        /// <description>未登录</description>
        /// </summary>
        kTIMLoginStatus_UnLogined = 3,   // 未登录
        /// <summary>
        /// <description>登出中</description>
        /// </summary>
        kTIMLoginStatus_Logouting = 4,   // 登出中

    };
    public enum TIMConvType
    {
        /// <summary>
        /// <description>无效会话</description>
        /// </summary>
        kTIMConv_Invalid, // 无效会话
        /// <summary>
        /// <description>个人会话</description>
        /// </summary>
        kTIMConv_C2C,     // 个人会话
        /// <summary>
        /// <description>群组会话</description>
        /// </summary>
        kTIMConv_Group,   // 群组会话
        /// <summary>
        /// <description>系统会话</description>
        /// </summary>
        kTIMConv_System,  // 系统会话
    };

    public enum TIMMsgPriority
    {
        /// <summary>
        /// <description>优先级最高，一般为红包或者礼物消息</description>
        /// </summary>
        kTIMMsgPriority_High,   // 优先级最高，一般为红包或者礼物消息
        /// <summary>
        /// <description>表示优先级次之，建议为普通消息</description>
        /// </summary>
        kTIMMsgPriority_Normal, // 表示优先级次之，建议为普通消息
        /// <summary>
        /// <description>建议为点赞消息等</description>
        /// </summary>
        kTIMMsgPriority_Low,    // 建议为点赞消息等
        /// <summary>
        /// <description>优先级最低，一般为成员进退群通知(后台下发)</description>
        /// </summary>
        kTIMMsgPriority_Lowest, // 优先级最低，一般为成员进退群通知(后台下发)
    };

    public enum TIMPlatform
    {
        /// <summary>
        /// <description>未知平台</description>
        /// </summary>
        kTIMPlatform_Other = 0,      // 未知平台
        /// <summary>
        /// <description>Windows平台</description>
        /// </summary>
        kTIMPlatform_Windows,        // Windows平台
        /// <summary>
        /// <description>Android平台</description>
        /// </summary>
        kTIMPlatform_Android,        // Android平台
        /// <summary>
        /// <description>iOS平台</description>
        /// </summary>
        kTIMPlatform_IOS,            // iOS平台
        /// <summary>
        /// <description>MacOS平台</description>
        /// </summary>
        kTIMPlatform_Mac,            // MacOS平台
        /// <summary>
        /// <description>iOS模拟器平台</description>
        /// </summary>
        kTIMPlatform_Simulator,      // iOS模拟器平台
    };

    public enum TIMMsgStatus
    {
        /// <summary>
        /// <description>消息正在发送</description>
        /// </summary>
        kTIMMsg_Sending = 1,        // 消息正在发送
        /// <summary>
        /// <description>消息发送成功</description>
        /// </summary>
        kTIMMsg_SendSucc = 2,       // 消息发送成功
        /// <summary>
        /// <description>消息发送失败</description>
        /// </summary>
        kTIMMsg_SendFail = 3,       // 消息发送失败
        /// <summary>
        /// <description>消息已删除</description>
        /// </summary>
        kTIMMsg_Deleted = 4,        // 消息已删除
        /// <summary>
        /// <description>消息导入状态</description>
        /// </summary>
        kTIMMsg_LocalImported = 5,  // 消息导入状态
        /// <summary>
        /// <description>消息撤回状态</description>
        /// </summary>
        kTIMMsg_Revoked = 6,        // 消息撤回状态
        /// <summary>
        /// <description>消息取消</description>
        /// </summary>
        kTIMMsg_Cancel = 7,         // 消息取消
        
    };

    public enum TIMGenderType
    {
        /// <summary>
        /// <description>未知性别</description>
        /// </summary>
        kTIMGenderType_Unkown, // 未知性别
        /// <summary>
        /// <description>性别男</description>
        /// </summary>
        kTIMGenderType_Male,   // 性别男
        /// <summary>
        /// <description>性别女</description>
        /// </summary>
        kTIMGenderType_Female, // 性别女
    };
    public enum TIMProfileAddPermission
    {
        /// <summary>
        /// <description>未知</description>
        /// </summary>
        kTIMProfileAddPermission_Unknown,       // 未知
        /// <summary>
        /// <description>允许任何人添加好友</description>
        /// </summary>
        kTIMProfileAddPermission_AllowAny,      // 允许任何人添加好友
        /// <summary>
        /// <description>添加好友需要验证</description>
        /// </summary>
        kTIMProfileAddPermission_NeedConfirm,   // 添加好友需要验证
        /// <summary>
        /// <description>拒绝任何人添加好友</description>
        /// </summary>
        kTIMProfileAddPermission_DenyAny,       // 拒绝任何人添加好友
    };

    public enum TIMElemType
    {
        /// <summary>
        /// <description>文本元素</description>
        /// </summary>
        kTIMElem_Text,           // 文本元素
        /// <summary>
        /// <description>图片元素</description>
        /// </summary>
        kTIMElem_Image,          // 图片元素
        /// <summary>
        /// <description>声音元素</description>
        /// </summary>
        kTIMElem_Sound,          // 声音元素
        /// <summary>
        /// <description>自定义元素</description>
        /// </summary>
        kTIMElem_Custom,         // 自定义元素
        /// <summary>
        /// <description>文件元素</description>
        /// </summary>
        kTIMElem_File,           // 文件元素
        /// <summary>
        /// <description>群组系统消息元素</description>
        /// </summary>
        kTIMElem_GroupTips,      // 群组系统消息元素
        /// <summary>
        /// <description>表情元素</description>
        /// </summary>
        kTIMElem_Face,           // 表情元素
        /// <summary>
        /// <description>位置元素</description>
        /// </summary>
        kTIMElem_Location,       // 位置元素
        /// <summary>
        /// <description>群组系统通知元素</description>
        /// </summary>
        kTIMElem_GroupReport,    // 群组系统通知元素
        /// <summary>
        /// <description>视频元素</description>
        /// </summary>
        kTIMElem_Video,          // 视频元素
        /// <summary>
        /// <description>关系链变更消息元素</description>
        /// </summary>
        kTIMElem_FriendChange,   // 关系链变更消息元素
        /// <summary>
        /// <description>资料变更消息元素</description>
        /// </summary>
        kTIMElem_ProfileChange,  // 资料变更消息元素
        /// <summary>
        /// <description>合并消息元素</description>
        /// </summary>
        kTIMElem_Merge,          // 合并消息元素
        /// <summary>
        /// <description>未知元素类型</description>
        /// </summary>
        kTIMElem_Invalid = -1,   // 未知元素类型
    };
    public enum TIMImageLevel
    {
        /// <summary>
        /// <description>原图发送</description>
        /// </summary>
        kTIMImageLevel_Orig,        // 原图发送
        /// <summary>
        /// <description>高压缩率图发送(图片较小,默认值)</description>
        /// </summary>
        kTIMImageLevel_Compression, // 高压缩率图发送(图片较小,默认值)
        /// <summary>
        /// <description>高清图发送(图片较大)</description>
        /// </summary>
        kTIMImageLevel_HD,          // 高清图发送(图片较大)
    };
    public enum TIMGroupTipType
    {
        /// <summary>
        /// <description>无效的群提示</description>
        /// </summary>
        kTIMGroupTip_None,              // 无效的群提示
        /// <summary>
        /// <description>邀请加入提示</description>
        /// </summary>
        kTIMGroupTip_Invite,            // 邀请加入提示
        /// <summary>
        /// <description>退群提示</description>
        /// </summary>
        kTIMGroupTip_Quit,              // 退群提示
        /// <summary>
        /// <description>踢人提示</description>
        /// </summary>
        kTIMGroupTip_Kick,              // 踢人提示
        /// <summary>
        /// <description>设置管理员提示</description>
        /// </summary>
        kTIMGroupTip_SetAdmin,          // 设置管理员提示
        /// <summary>
        /// <description>取消管理员提示</description>
        /// </summary>
        kTIMGroupTip_CancelAdmin,       // 取消管理员提示
        /// <summary>
        /// <description>群信息修改提示</description>
        /// </summary>
        kTIMGroupTip_GroupInfoChange,   // 群信息修改提示
        /// <summary>
        /// <description>群成员信息修改提示</description>
        /// </summary>
        kTIMGroupTip_MemberInfoChange,  // 群成员信息修改提示
    };
    public enum TIMGroupTipGroupChangeFlag
    {
        /// <summary>
        /// <description>未知的修改</description>
        /// </summary>
        kTIMGroupTipChangeFlag_Unknown,      // 未知的修改
        /// <summary>
        /// <description>修改群组名称</description>
        /// </summary>
        kTIMGroupTipChangeFlag_Name,         // 修改群组名称
        /// <summary>
        /// <description>修改群简介</description>
        /// </summary>
        kTIMGroupTipChangeFlag_Introduction, // 修改群简介
        /// <summary>
        /// <description>修改群公告</description>
        /// </summary>
        kTIMGroupTipChangeFlag_Notification, // 修改群公告
        /// <summary>
        /// <description>修改群头像URL</description>
        /// </summary>
        kTIMGroupTipChangeFlag_FaceUrl,      // 修改群头像URL
        /// <summary>
        /// <description>修改群所有者</description>
        /// </summary>
        kTIMGroupTipChangeFlag_Owner,        // 修改群所有者
        /// <summary>
        /// <description>修改群自定义信息</description>
        /// </summary>
        kTIMGroupTipChangeFlag_Custom,       // 修改群自定义信息
        /// <summary>
        /// <description>群属性变更 (新增)</description>
        /// </summary>
        kTIMGroupTipChangeFlag_Attribute,    // 群属性变更 (新增)
    };
    public enum TIMGroupReportType
    {
        /// <summary>
        /// <description>未知类型</description>
        /// </summary>
        kTIMGroupReport_None,         // 未知类型
        /// <summary>
        /// <description>申请加群(只有管理员会接收到)</description>
        /// </summary>
        kTIMGroupReport_AddRequest,   // 申请加群(只有管理员会接收到)
        /// <summary>
        /// <description>申请加群被同意(只有申请人自己接收到)</description>
        /// </summary>
        kTIMGroupReport_AddAccept,    // 申请加群被同意(只有申请人自己接收到)
        /// <summary>
        /// <description>申请加群被拒绝(只有申请人自己接收到)</description>
        /// </summary>
        kTIMGroupReport_AddRefuse,    // 申请加群被拒绝(只有申请人自己接收到)
        /// <summary>
        /// <description>被管理员踢出群(只有被踢者接收到)</description>
        /// </summary>
        kTIMGroupReport_BeKicked,     // 被管理员踢出群(只有被踢者接收到)
        /// <summary>
        /// <description>群被解散(全员接收)</description>
        /// </summary>
        kTIMGroupReport_Delete,       // 群被解散(全员接收)
        /// <summary>
        /// <description>创建群(创建者接收, 不展示)</description>
        /// </summary>
        kTIMGroupReport_Create,       // 创建群(创建者接收, 不展示)
        /// <summary>
        /// <description>无需被邀请者同意，拉入群中（例如工作群）</description>
        /// </summary>
        kTIMGroupReport_Invite,       // 无需被邀请者同意，拉入群中（例如工作群）
        /// <summary>
        /// <description>主动退群(主动退出者接收, 不展示)</description>
        /// </summary>
        kTIMGroupReport_Quit,         // 主动退群(主动退出者接收, 不展示)
        /// <summary>
        /// <description>设置管理员(被设置者接收)</description>
        /// </summary>
        kTIMGroupReport_GrantAdmin,   // 设置管理员(被设置者接收)
        /// <summary>
        /// <description>取消管理员(被取消者接收)</description>
        /// </summary>
        kTIMGroupReport_CancelAdmin,  // 取消管理员(被取消者接收)
        /// <summary>
        /// <description>群已被回收(全员接收, 不展示)</description>
        /// </summary>
        kTIMGroupReport_GroupRecycle, // 群已被回收(全员接收, 不展示)
        /// <summary>
        /// <description>被邀请者收到邀请，由被邀请者同意是否接受</description>
        /// </summary>
        kTIMGroupReport_InviteReq,    // 被邀请者收到邀请，由被邀请者同意是否接受
        /// <summary>
        /// <description>邀请加群被同意(只有发出邀请者会接收到)</description>
        /// </summary>
        kTIMGroupReport_InviteAccept, // 邀请加群被同意(只有发出邀请者会接收到)
        /// <summary>
        /// <description>邀请加群被拒绝(只有发出邀请者会接收到)</description>
        /// </summary>
        kTIMGroupReport_InviteRefuse, // 邀请加群被拒绝(只有发出邀请者会接收到)
        /// <summary>
        /// <description>已读上报多终端同步通知(只有上报人自己收到)</description>
        /// </summary>
        kTIMGroupReport_ReadReport,   // 已读上报多终端同步通知(只有上报人自己收到)
        /// <summary>
        /// <description>用户自定义通知(默认全员接收)</description>
        /// </summary>
        kTIMGroupReport_UserDefine,   // 用户自定义通知(默认全员接收)
    };

    public enum TIMReceiveMessageOpt
    {
        /// <summary>
        /// <description>在线正常接收消息，离线时会进行 APNs 推送</description>
        /// </summary>
        kTIMRecvMsgOpt_Receive = 0,  // 在线正常接收消息，离线时会进行 APNs 推送
        /// <summary>
        /// <description>不会接收到消息，离线不会有推送通知</description>
        /// </summary>
        kTIMRecvMsgOpt_Not_Receive,  // 不会接收到消息，离线不会有推送通知
        /// <summary>
        /// <description>在线正常接收消息，离线不会有推送通知</description>
        /// </summary>
        kTIMRecvMsgOpt_Not_Notify,   // 在线正常接收消息，离线不会有推送通知
    };
    public enum TIMProfileChangeType
    {
        /// <summary>
        /// <description>未知类型</description>
        /// </summary>
        kTIMProfileChange_None,       // 未知类型
        /// <summary>
        /// <description>资料修改</description>
        /// </summary>
        kTIMProfileChange_Profile,    // 资料修改
    };
    public enum TIMOfflinePushFlag
    {
        /// <summary>
        /// <description>按照默认规则进行推送</description>
        /// </summary>
        kTIMOfflinePushFlag_Default,   // 按照默认规则进行推送
        /// <summary>
        /// <description>不进行推送</description>
        /// </summary>
        kTIMOfflinePushFlag_NoPush,    // 不进行推送
    };
    public enum TIMAndroidOfflinePushNotifyMode
    {
        /// <summary>
        /// <description>普通通知栏消息模式，离线消息下发后，点击通知栏消息直接启动应用，不会给应用进行回调</description>
        /// </summary>
        kTIMAndroidOfflinePushNotifyMode_Normal,   // 普通通知栏消息模式，离线消息下发后，点击通知栏消息直接启动应用，不会给应用进行回调
        /// <summary>
        /// <description>自定义消息模式，离线消息下发后，点击通知栏消息会给应用进行回调</description>
        /// </summary>
        kTIMAndroidOfflinePushNotifyMode_Custom,   // 自定义消息模式，离线消息下发后，点击通知栏消息会给应用进行回调
    };
    public enum TIMGroupMemberRole
    {
        /// <summary>
        /// <description>未定义</description>
        /// </summary>
        kTIMMemberRole_None = 0,    // 未定义
        /// <summary>
        /// <description>群成员</description>
        /// </summary>
        kTIMMemberRole_Normal = 200,  // 群成员
        /// <summary>
        /// <description>管理员</description>
        /// </summary>
        kTIMMemberRole_Admin = 300,  // 管理员
        /// <summary>
        /// <description>超级管理员(群主）</description>
        /// </summary>
        kTIMMemberRole_Owner = 400,  // 超级管理员(群主）
    };
    public enum TIMDownloadType
    {
        /// <summary>
        /// <description>视频缩略图</description>
        /// </summary>
        kTIMDownload_VideoThumb = 0, // 视频缩略图
        /// <summary>
        /// <description>文件</description>
        /// </summary>
        kTIMDownload_File,           // 文件
        /// <summary>
        /// <description>视频</description>
        /// </summary>
        kTIMDownload_Video,          // 视频
        /// <summary>
        /// <description>声音</description>
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
        /// <description>公开群（Public），成员上限 2000 人，任何人都可以申请加群，但加群需群主或管理员审批，适合用于类似 QQ 中由群主管理的兴趣群。</description>
        /// </summary>
        kTIMGroup_Public,     // 公开群（Public），成员上限 2000 人，任何人都可以申请加群，但加群需群主或管理员审批，适合用于类似 QQ 中由群主管理的兴趣群。
        /// <summary>
        /// <description>工作群（Work），成员上限 200  人，不支持由用户主动加入，需要他人邀请入群，适合用于类似微信中随意组建的工作群（对应老版本的 Private 群）。</description>
        /// </summary>
        kTIMGroup_Private,    // 工作群（Work），成员上限 200  人，不支持由用户主动加入，需要他人邀请入群，适合用于类似微信中随意组建的工作群（对应老版本的 Private 群）。
        /// <summary>
        /// <description>会议群（Meeting），成员上限 6000 人，任何人都可以自由进出，且加群无需被审批，适合用于视频会议和在线培训等场景（对应老版本的 ChatRoom 群）。</description>
        /// </summary>
        kTIMGroup_ChatRoom,   // 会议群（Meeting），成员上限 6000 人，任何人都可以自由进出，且加群无需被审批，适合用于视频会议和在线培训等场景（对应老版本的 ChatRoom 群）。
        /// <summary>
        /// <description>在线成员广播大群，推荐使用 直播群（AVChatRoom）</description>
        /// </summary>
        kTIMGroup_BChatRoom,  // 在线成员广播大群，推荐使用 直播群（AVChatRoom）
        /// <summary>
        /// <description>直播群（AVChatRoom），人数无上限，任何人都可以自由进出，消息吞吐量大，适合用作直播场景中的高并发弹幕聊天室。</description>
        /// </summary>
        kTIMGroup_AVChatRoom, // 直播群（AVChatRoom），人数无上限，任何人都可以自由进出，消息吞吐量大，适合用作直播场景中的高并发弹幕聊天室。
        /// <summary>
        /// <description>社群（Community），成员上限 100000 人，任何人都可以自由进出，且加群无需被审批，适合用于知识分享和游戏交流等超大社区群聊场景。5.8 版本开始支持，需要您购买旗舰版套餐。</description>
        /// </summary>
        kTIMGroup_Community,  // 社群（Community），成员上限 100000 人，任何人都可以自由进出，且加群无需被审批，适合用于知识分享和游戏交流等超大社区群聊场景。5.8 版本开始支持，需要您购买旗舰版套餐。
    };
    public enum TIMGroupAddOption
    {
        /// <summary>
        /// <description>禁止加群</description>
        /// </summary>
        kTIMGroupAddOpt_Forbid = 0,  // 禁止加群
        /// <summary>
        /// <description>需要管理员审批</description>
        /// </summary>
        kTIMGroupAddOpt_Auth = 1,    // 需要管理员审批
        /// <summary>
        /// <description>任何人都可以加群</description>
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
        /// <description>修改群组名称</description>
        /// </summary>
        kTIMGroupModifyInfoFlag_Name = 0x01,       // 修改群组名称
        /// <summary>
        /// <description>修改群公告</description>
        /// </summary>
        kTIMGroupModifyInfoFlag_Notification = 0x01 << 1,  // 修改群公告
        /// <summary>
        /// <description>修改群简介</description>
        /// </summary>
        kTIMGroupModifyInfoFlag_Introduction = 0x01 << 2,  // 修改群简介
        /// <summary>
        /// <description>修改群头像URL</description>
        /// </summary>
        kTIMGroupModifyInfoFlag_FaceUrl = 0x01 << 3,  // 修改群头像URL
        /// <summary>
        /// <description>修改群组添加选项</description>
        /// </summary>
        kTIMGroupModifyInfoFlag_AddOption = 0x01 << 4,  // 修改群组添加选项
        /// <summary>
        /// <description>修改群最大成员数</description>
        /// </summary>
        kTIMGroupModifyInfoFlag_MaxMmeberNum = 0x01 << 5,  // 修改群最大成员数
        /// <summary>
        /// <description>修改群是否可见</description>
        /// </summary>
        kTIMGroupModifyInfoFlag_Visible = 0x01 << 6,  // 修改群是否可见
        /// <summary>
        /// <description>修改群是否允许被搜索</description>
        /// </summary>
        kTIMGroupModifyInfoFlag_Searchable = 0x01 << 7,  // 修改群是否允许被搜索
        /// <summary>
        /// <description>修改群是否全体禁言</description>
        /// </summary>
        kTIMGroupModifyInfoFlag_ShutupAll = 0x01 << 8,  // 修改群是否全体禁言
        /// <summary>
        /// <description>修改群自定义信息</description>
        /// </summary>
        kTIMGroupModifyInfoFlag_Custom = 0x01 << 9,  // 修改群自定义信息
        /// <summary>
        /// <description>修改群主</description>
        /// </summary>
        kTIMGroupModifyInfoFlag_Owner = 0x01 << 31, // 修改群主

    };
    public enum TIMGroupMemberInfoFlag
    {
        /// <summary>
        /// <description>无</description>
        /// </summary>
        kTIMGroupMemberInfoFlag_None = 0x00,       // 无
        /// <summary>
        /// <description>加入时间</description>
        /// </summary>
        kTIMGroupMemberInfoFlag_JoinTime = 0x01,       // 加入时间
        /// <summary>
        /// <description>群消息接收选项</description>
        /// </summary>
        kTIMGroupMemberInfoFlag_MsgFlag = 0x01 << 1,  // 群消息接收选项
        /// <summary>
        /// <description>成员已读消息seq</description>
        /// </summary>
        kTIMGroupMemberInfoFlag_MsgSeq = 0x01 << 2,  // 成员已读消息seq
        /// <summary>
        /// <description>成员角色</description>
        /// </summary>
        kTIMGroupMemberInfoFlag_MemberRole = 0x01 << 3,  // 成员角色
        /// <summary>
        /// <description>禁言时间。当该值为0时表示没有被禁言</description>
        /// </summary>
        kTIMGroupMemberInfoFlag_ShutupUntill = 0x01 << 4,  // 禁言时间。当该值为0时表示没有被禁言
        /// <summary>
        /// <description>群名片</description>
        /// </summary>
        kTIMGroupMemberInfoFlag_NameCard = 0x01 << 5,  // 群名片
    };


    public enum TIMGroupMemberRoleFlag
    {
        /// <summary>
        /// <description>获取全部角色类型</description>
        /// </summary>
        kTIMGroupMemberRoleFlag_All = 0x00,       // 获取全部角色类型
        /// <summary>
        /// <description>获取所有者(群主)</description>
        /// </summary>
        kTIMGroupMemberRoleFlag_Owner = 0x01,       // 获取所有者(群主)
        /// <summary>
        /// <description>获取管理员，不包括群主</description>
        /// </summary>
        kTIMGroupMemberRoleFlag_Admin = 0x01 << 1,  // 获取管理员，不包括群主
        /// <summary>
        /// <description>获取普通群成员，不包括群主和管理员</description>
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
        /// <description>修改消息接收选项</description>
        /// </summary>
        kTIMGroupMemberModifyFlag_MsgFlag = 0x01,      // 修改消息接收选项
        /// <summary>
        /// <description>修改成员角色</description>
        /// </summary>
        kTIMGroupMemberModifyFlag_MemberRole = 0x01 << 1, // 修改成员角色
        /// <summary>
        /// <description>修改禁言时间</description>
        /// </summary>
        kTIMGroupMemberModifyFlag_ShutupTime = 0x01 << 2, // 修改禁言时间
        /// <summary>
        /// <description>修改群名片</description>
        /// </summary>
        kTIMGroupMemberModifyFlag_NameCard = 0x01 << 3, // 修改群名片
        /// <summary>
        /// <description>修改群成员自定义信息</description>
        /// </summary>
        kTIMGroupMemberModifyFlag_Custom = 0x01 << 4, // 修改群成员自定义信息

    };
    public enum TIMGroupPendencyType
    {
        /// <summary>
        /// <description>请求加群</description>
        /// </summary>
        kTIMGroupPendency_RequestJoin = 0,  // 请求加群
        /// <summary>
        /// <description>邀请加群</description>
        /// </summary>
        kTIMGroupPendency_InviteJoin = 1,   // 邀请加群
        /// <summary>
        /// <description>邀请和请求的</description>
        /// </summary>
        kTIMGroupPendency_ReqAndInvite = 2, // 邀请和请求的
    };
    public enum TIMGroupPendencyHandle
    {
        /// <summary>
        /// <description>未处理</description>
        /// </summary>
        kTIMGroupPendency_NotHandle = 0,      // 未处理
        /// <summary>
        /// <description>他人处理</description>
        /// </summary>
        kTIMGroupPendency_OtherHandle = 1,    // 他人处理
        /// <summary>
        /// <description>操作方处理</description>
        /// </summary>
        kTIMGroupPendency_OperatorHandle = 2, // 操作方处理
    };

    /**
    * @brief 群未决处理操作类型
*/
    public enum TIMGroupPendencyHandleResult
    {
        /// <summary>
        /// <description>拒绝</description>
        /// </summary>
        kTIMGroupPendency_Refuse = 0,  // 拒绝
        /// <summary>
        /// <description>同意</description>
        /// </summary>
        kTIMGroupPendency_Accept = 1,  // 同意
    };
    public enum TIMGroupSearchFieldKey
    {
        /// <summary>
        /// <description>群 ID</description>
        /// </summary>
        kTIMGroupSearchFieldKey_GroupId = 0x01,  //  群 ID
        /// <summary>
        /// <description>群名称</description>
        /// </summary>
        kTIMGroupSearchFieldKey_GroupName = 0x01 << 1, // 群名称
    };
    public enum TIMGroupMemberSearchFieldKey
    {
        /// <summary>
        /// <description>用户 ID</description>
        /// </summary>
        kTIMGroupMemberSearchFieldKey_Identifier = 0x01, // 用户 ID
        /// <summary>
        /// <description>昵称</description>
        /// </summary>
        kTIMGroupMemberSearchFieldKey_NikeName = 0x01 << 1, // 昵称
        /// <summary>
        /// <description>备注</description>
        /// </summary>
        kTIMGroupMemberSearchFieldKey_Remark = 0x01 << 2, // 备注
        /// <summary>
        /// <description>名片</description>
        /// </summary>
        kTIMGroupMemberSearchFieldKey_NameCard = 0x01 << 3,  // 名片
    };
    public enum TIMFriendType
    {
        /// <summary>
        /// <description>单向好友：用户A的好友表中有用户B，但B的好友表中却没有A</description>
        /// </summary>
        FriendTypeSignle,  // 单向好友：用户A的好友表中有用户B，但B的好友表中却没有A
        /// <summary>
        /// <description>双向好友：用户A的好友表中有用户B，B的好友表中也有A</description>
        /// </summary>
        FriendTypeBoth,    // 双向好友：用户A的好友表中有用户B，B的好友表中也有A
    };
    public enum TIMFriendResponseAction
    {
        /// <summary>
        /// <description>同意</description>
        /// </summary>
        ResponseActionAgree,       // 同意
        /// <summary>
        /// <description>同意并添加</description>
        /// </summary>
        ResponseActionAgreeAndAdd, // 同意并添加
        /// <summary>
        /// <description>拒绝</description>
        /// </summary>
        ResponseActionReject,      // 拒绝
    };
    public enum TIMFriendCheckRelation
    {
        /// <summary>
        /// <description>无关系</description>
        /// </summary>
        FriendCheckNoRelation,  // 无关系
        /// <summary>
        /// <description>仅A中有B</description>
        /// </summary>
        FriendCheckAWithB,      // 仅A中有B
        /// <summary>
        /// <description>仅B中有A</description>
        /// </summary>
        FriendCheckBWithA,      // 仅B中有A
        /// <summary>
        /// <description>双向</description>
        /// </summary>
        FriendCheckBothWay,     // 双向
    };
    public enum TIMFriendPendencyType
    {
        /// <summary>
        /// <description>别人发给我的</description>
        /// </summary>
        FriendPendencyTypeComeIn,  // 别人发给我的
        /// <summary>
        /// <description>我发给别人的</description>
        /// </summary>
        FriendPendencyTypeSendOut, // 我发给别人的
        /// <summary>
        /// <description>双向的</description>
        /// </summary>
        FriendPendencyTypeBoth,    // 双向的
    };
    public enum TIMFriendshipSearchFieldKey
    {
        /// <summary>
        /// <description>用户 ID</description>
        /// </summary>
        kTIMFriendshipSearchFieldKey_Identifier = 0x01,  // 用户 ID
        /// <summary>
        /// <description>昵称</description>
        /// </summary>
        kTIMFriendshipSearchFieldKey_NikeName = 0x01 << 1, // 昵称
        /// <summary>
        /// <description>备注</description>
        /// </summary>
        kTIMFriendshipSearchFieldKey_Remark = 0x01 << 2, // 备注
    };

    public enum TIMConvEvent
    {
        /// <summary>
        /// <description>会话新增,例如收到一条新消息,产生一个新的会话是事件触发</description>
        /// </summary>
        kTIMConvEvent_Add,    // 会话新增,例如收到一条新消息,产生一个新的会话是事件触发
        /// <summary>
        /// <description>会话删除,例如自己删除某会话时会触发</description>
        /// </summary>
        kTIMConvEvent_Del,    // 会话删除,例如自己删除某会话时会触发
        /// <summary>
        /// <description>会话更新,会话内消息的未读计数变化和收到新消息时触发</description>
        /// </summary>
        kTIMConvEvent_Update, // 会话更新,会话内消息的未读计数变化和收到新消息时触发
        /// <summary>
        /// <description>会话开始</description>
        /// </summary>
        kTIMConvEvent_Start,  // 会话开始
        /// <summary>
        /// <description>会话结束</description>
        /// </summary>
        kTIMConvEvent_Finish, // 会话结束

    };
    public enum TIMGroupAtType
    {
        /// <summary>
        /// <description>@ 我</description>
        /// </summary>
        kTIMGroup_At_Me = 1,                    // @ 我
        /// <summary>
        /// <description>@ 群里所有人</description>
        /// </summary>
        kTIMGroup_At_All,                       // @ 群里所有人
        /// <summary>
        /// <description>@ 群里所有人并且单独 @ 我</description>
        /// </summary>
        kTIMGroup_At_All_At_ME,                 // @ 群里所有人并且单独 @ 我
    };
    public enum TIMNetworkStatus
    {
        /// <summary>
        /// <description>已连接</description>
        /// </summary>
        kTIMConnected,       // 已连接
        /// <summary>
        /// <description>失去连接</description>
        /// </summary>
        kTIMDisconnected,    // 失去连接
        /// <summary>
        /// <description>正在连接</description>
        /// </summary>
        kTIMConnecting,      // 正在连接
        /// <summary>
        /// <description>连接失败</description>
        /// </summary>
        kTIMConnectFailed,   // 连接失败
    };

    public enum TIMLogLevel
    {
        /// <summary>
        /// <description>关闭日志输出</description>
        /// </summary>
        kTIMLog_Off,     // 关闭日志输出
        /// <summary>
        /// <description>全量日志</description>
        /// </summary>
        kTIMLog_Test,    // 全量日志
        /// <summary>
        /// <description>开发调试过程中一些详细信息日志</description>
        /// </summary>
        kTIMLog_Verbose, // 开发调试过程中一些详细信息日志
        /// <summary>
        /// <description>调试日志</description>
        /// </summary>
        kTIMLog_Debug,   // 调试日志
        /// <summary>
        /// <description>信息日志</description>
        /// </summary>
        kTIMLog_Info,    // 信息日志
        /// <summary>
        /// <description>警告日志</description>
        /// </summary>
        kTIMLog_Warn,    // 警告日志
        /// <summary>
        /// <description>断言日志</description>
        /// </summary>
        kTIMLog_Error,   // 断言日志
        /// <summary>
        /// <description>断言日志</description>
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
        /// <description>群组名称</description>
        /// </summary>
        kTIMGroupInfoFlag_Name = 0x01,       // 群组名称
        /// <summary>
        /// <description>群组创建时间</description>
        /// </summary>
        kTIMGroupInfoFlag_CreateTime = 0x01 << 1,  // 群组创建时间
        /// <summary>
        /// <description>群组创建者帐号</description>
        /// </summary>
        kTIMGroupInfoFlag_OwnerUin = 0x01 << 2,  // 群组创建者帐号
        /// <summary>
        /// <description>Seq</description>
        /// </summary>
        kTIMGroupInfoFlag_Seq = 0x01 << 3,
        /// <summary>
        /// <description>群组信息最后修改时间</description>
        /// </summary>
        kTIMGroupInfoFlag_LastTime = 0x01 << 4,  // 群组信息最后修改时间
        /// <summary>
        /// <description>NextMsgSeq</description>
        /// </summary>
        kTIMGroupInfoFlag_NextMsgSeq = 0x01 << 5,
        /// <summary>
        /// <description>最新群组消息时间</description>
        /// </summary>
        kTIMGroupInfoFlag_LastMsgTime = 0X01 << 6,  // 最新群组消息时间
        /// <summary>
        /// <description>AppId</description>
        /// </summary>
        kTIMGroupInfoFlag_AppId = 0x01 << 7,
        /// <summary>
        /// <description>群组成员数量</description>
        /// </summary>
        kTIMGroupInfoFlag_MemberNum = 0x01 << 8,  // 群组成员数量
        /// <summary>
        /// <description>群组成员最大数量</description>
        /// </summary>
        kTIMGroupInfoFlag_MaxMemberNum = 0x01 << 9,  // 群组成员最大数量
        /// <summary>
        /// <description>群公告内容</description>
        /// </summary>
        kTIMGroupInfoFlag_Notification = 0x01 << 10, // 群公告内容
        /// <summary>
        /// <description>群简介内容</description>
        /// </summary>
        kTIMGroupInfoFlag_Introduction = 0x01 << 11, // 群简介内容
        /// <summary>
        /// <description>群头像URL</description>
        /// </summary>
        kTIMGroupInfoFlag_FaceUrl = 0x01 << 12, // 群头像URL
        /// <summary>
        /// <description>加群选项</description>
        /// </summary>
        kTIMGroupInfoFlag_AddOpton = 0x01 << 13, // 加群选项
        /// <summary>
        /// <description>群类型</description>
        /// </summary>
        kTIMGroupInfoFlag_GroupType = 0x01 << 14, // 群类型
        /// <summary>
        /// <description>群组内最新一条消息</description>
        /// </summary>
        kTIMGroupInfoFlag_LastMsg = 0x01 << 15, // 群组内最新一条消息
        /// <summary>
        /// <description>群组在线成员数</description>
        /// </summary>
        kTIMGroupInfoFlag_OnlineNum = 0x01 << 16, // 群组在线成员数
        /// <summary>
        /// <description>群组是否可见</description>
        /// </summary>
        kTIMGroupInfoFlag_Visible = 0x01 << 17, // 群组是否可见
        /// <summary>
        /// <description>群组是否可以搜索</description>
        /// </summary>
        kTIMGroupInfoFlag_Searchable = 0x01 << 18, // 群组是否可以搜索
        /// <summary>
        /// <description>群组是否全禁言</description>
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
}