/**
 * 事件名称
 */
declare type EventName =
    "APPLY_ADD_FRIEND_FAIL" |
    "APPLY_ADD_FRIEND_SUCCESS" |
    "BLACKLIST_ADD_FAIL" |
    "BLACKLIST_ADD_SUCCESS" |
    "BLACKLIST_DELETE_FAIL" |
    "BLACKLIST_GET_FAIL" |
    "BLACKLIST_GET_SUCCESS" |
    "BLACKLIST_UPDATED" |
    "CONVERSATION_LIST_UPDATED" | /* IMEvent<Conversation[]> */
    "DELETE_PENDENCY_FAIL" |
    "DELETE_PENDENCY_SUCCESS" |
    "ERROR" |
    "FRIENDLIST_GET_FAIL" |
    "FRIENDLIST_GET_SUCCESS" |
    "FRIEND_DELETE_FAIL" |
    "FRIEND_DELETE_SUCCESS" |
    "GET_PENDENCY_FAIL" |
    "GET_PENDENCY_SUCCESS" |
    "GROUP_LIST_UPDATED" |
    "GROUP_SYSTEM_NOTICE_RECERIVED" |
    "KICKED_OUT" |
    "LOGIN_CHANGE" |
    "LOGOUT_SUCCESS" |
    "MESSAGE_RECEIVED" |
    "MESSAGE_SENDING" |
    "MESSAGE_SEND_FAIL" |
    "MESSAGE_SEND_SUCCESS" |
    "PROFILE_GET_FAIL" |
    "PROFILE_GET_SUCCESS" |
    "PROFILE_UPDATED" |
    "PROFILE_UPDATE_MY_PROFILE_FAIL" |
    "REPLY_PENDENCY_FAIL" |
    "REPLY_PENDENCY_SUCCESS" |
    "SDK_DESTROY" |
    "SDK_NOT_READY" |
    "SDK_READY";

/**
 * 类型名称
 */
declare type TypeName =
    "ALLOW_TYPE_ALLOW_ANY" |
    "ALLOW_TYPE_DENY_ANY" |
    "CONV_C2C" |
    "CONV_GROUP" |
    "CONV_SYSTEM" |
    "FORBID_TYPE_NONE" |
    "FORBID_TYPE_SEND_OUT" |
    "GENDER_FEMALE" |
    "GENDER_MALE" |
    "GENDER_UNKNOWN" |
    "GRP_AVCHATROOM" |
    "GRP_CHATROOM" |
    "GRP_MBR_ROLE_ADMIN" |
    "GRP_MBR_ROLE_MEMBER" |
    "GRP_MBR_ROLE_OWNER" |
    "GRP_PRIVATE" |
    "GRP_PUBLIC" |
    "GRP_TIP_GRP_PROFILE_UPDATED" |
    "GRP_TIP_MBR_CANCELED_ADMIN" |
    "GRP_TIP_MBR_JOIN" |
    "GRP_TIP_MBR_KICKED_OUT" |
    "GRP_TIP_MBR_PROFILE_UPDATED" |
    "GRP_TIP_MBR_QUIT" |
    "GRP_TIP_MBR_SET_ADMIN" |
    "JOIN_OPTIONS_DISABLE_APPLY" |
    "JOIN_OPTIONS_FREE_ACCESS" |
    "JOIN_OPTIONS_NEED_PERMISSION" |
    "JOIN_STATUS_SUCCESS" |
    "JOIN_STATUS_WAIT_APPROVAL" |
    "KICKED_OUT_MULT_ACCOUNT" |
    "KICKED_OUT_MULT_DEVICE" |
    "MSG_CUSTOM" |
    "MSG_FACE" |
    "MSG_FILE" |
    "MSG_GEO" |
    "MSG_GRP_SYS_NOTICE" |
    "MSG_GRP_TIP" |
    "MSG_IMAGE" |
    "MSG_REMIND_ACPT_AND_NOTE" |
    "MSG_REMIND_ACPT_NOT_NOTE" |
    "MSG_REMIND_DISCARD" |
    "MSG_SOUND" |
    "MSG_TEXT" |
    "MSG_VIDEO";

/**
 * IMPromise
 */
declare interface IMPromise<T> extends Promise<IMResponse<T>> {
}
/**
 * 响应
 */
declare interface IMResponse<T> {
    /**
     * 返回码, 值为0
     */
    code: string;
    /**
     * API 相关数据
     */
    data: T;
}
/**
 * 错误
 */
declare interface IMError {
    /**
     * 返回码, 值为0
     */
    code: string;
    /**
     * 错误信息
     */
    message: string;
    /**
     * 错误堆栈信息
     */
    stack: object;
}
/**
 * 事件定义
 */
declare interface IMEvent<T> {
    /**
     * 事件名称
     */
    name: EventName;
    /**
     * 数据内容
     */
    data: T;
}

/**
 * TIM创建参数
 */
declare interface TIMCreateOptions {
    /**
     * SDKAppID
     */
    SDKAppID: number;
}

/* 登录结构体 start */
/**
 * 登录信息
 */
declare interface TIMLoginOptions {
    /**
     * 用户ID
     */
    userID: string;
    /**
     * 用户登录即时通信 IM 时使用的密码，其本质是 App Server 用密钥对 UserID 等信息加密后的数据。
     */
    userSig: string;
}
/**
 * 登录响应
 */
declare interface TIMLoginResponse {
    a2Key: string;
    actionStatus: string;
    errorCode: number;
    errorInfo: string;
    tinyID: string;
}
/* 登录结构体 end */

/* 消息结构体 start */
/**
 * 消息
 */
declare interface Message {
    /**
     * 消息 ID
     */
    ID: string;
    /**
     * 消息类型，具体如下：
     * TIM.TYPES.MSG_TEXT	文本消息
     * TIM.TYPES.MSG_IMAGE	图片消息
     * TIM.TYPES.MSG_SOUND	音频消息
     * TIM.TYPES.MSG_FILE	文件消息
     * TIM.TYPES.MSG_GRP_TIP	群提示消息
     * TIM.TYPES.MSG_GRP_SYS_NOTICE	群系统通知消息
     */
    type: string;
    /**
     * 消息的内容
     */
    payload: TextPayload | ImagePayload | SoundPayload | FilePayload |
        CustomPayload | GroupTipPayload | GroupSystemNoticePayload;
    /**
     * 消息所属的会话 ID
     */
    conversationID: string;
    /**
     * 消息所属会话的类型，具体如下：
     * TIM.TYPES.CONV_C2C	C2C(Client to Client, 端到端) 会话
     * TIM.TYPES.CONV_GROUP	GROUP(群组) 会话
     * TIM.TYPES.CONV_SYSTEM	SYSTEM(系统) 会话
     */
    conversationType: string;
    /**
     * 接收方的 userID
     */
    to: string;
    /**
     * 发送方的 userID，在消息发送时，会默认设置为当前登录的用户
     */
    from: string;
    /**
     * 消息的流向, in 为收到的消息, out 为发出的消息
     */
    flow: string;
    /**
     * 消息时间戳。单位：秒
     */
    time: number;
    /**
     * 消息状态
     * unSend(未发送)
     * success(发送成功)
     * fail(发送失败)
     */
    status: string;
    /**
     * 是否已读
     */
    isRead: boolean;
    /**
     * 是否为重发消息
     */
    isResend: boolean;
}
/**
 * 文本消息
 */
declare interface TextPayload {
    /**
     * 文本消息内容
     */
    text: string;
}
/**
 * 图片消息
 */
declare interface ImagePayload {
    /**
     * 唯一标识
     */
    uuid: string;
    /**
     * 图片格式类型
     */
    imageFormat: string;
    /**
     * 图片信息
     */
    imageInfoArray: ImageInfo[];
}
/**
 * 图片消息创建
 */
declare interface ImageCreatePayload {
    /**
     * 用于选择图片的 DOM 节点（Web）或者微信小程序 wx.chooseImage 接口的 success 回调参数或者 uniApp的uni.chooseImage接口的 success 回调参数。
     * SDK 会读取其中的数据并上传图片。
     * 元素类型
     * HTML: HTMLInputElement
     * wx原生: Object
     * uniApp: ChooseImageSuccessCallbackResult
     */
    file: HTMLInputElement;
}
/**
 * 图片信息
 */
declare interface ImageInfo {
    /**
     * 宽度
     */
    width: number;
    /**
     * 高度
     */
    height: number;
    /**
     * 图片地址，可用于渲染。
     */
    url: string;
    /**
     * 图片大小，单位字节。
     */
    size: number;
    /**
     * 图片大小类型。值为 1 时表示原图，数值越大表示压缩比率越高。
     */
    sizeType: number;
}
/**
 * 音频消息
 */
declare interface SoundPayload {
    /**
     * 唯一标识
     */
    uuid: string;
    /**
     * 音频地址
     */
    url: string;
    /**
     * 文件大小，单位字节
     */
    size: number;
    /**
     * 音频时长，单位：秒
     */
    second: number;
}
/**
 * 文件消息
 */
declare interface FilePayload {
    /**
     * 唯一标识
     */
    uuid: string;
    /**
     * 文件名
     */
    fileName: string;
    /**
     * 文件地址
     */
    fileUrl: string;
    /**
     * 文件大小，单位字节
     */
    fileSize: number;
}
/**
 * 图片消息创建
 */
declare interface FileCreatePayload {
    /**
     * 用于选择文件的 DOM 节点，SDK 会读取其中的数据并上传文件。
     * HTML: HTMLInputElement
     */
    file: HTMLInputElement;
}
/**
 * 自定义消息
 */
declare interface CustomPayload {
    /**
     * 自定义消息的 data 字段
     */
    data: string;
    /**
     * 自定义消息的 description 字段
     */
    description: string;
    /**
     * 自定义消息的 extension 字段
     */
    extension: string;
}
/**
 * 群提示消息
 */
declare interface GroupTipPayload {
    /**
     * 执行该操作的用户 ID
     */
    operatorID: string;
    /**
     * 操作类型，具体如下:
     * 操作类型	                                值	含义
     * TIM.TYPES.GRP_TIP_MBR_JOIN	            1	有成员加群
     * TIM.TYPES.GRP_TIP_MBR_QUIT	            2	有群成员退群
     * TIM.TYPES.GRP_TIP_MBR_KICKED_OUT	        3	有群成员被踢出群
     * TIM.TYPES.GRP_TIP_MBR_SET_ADMIN	        4	有群成员被设为管理员
     * TIM.TYPES.GRP_TIP_MBR_CANCELED_ADMIN	    5	有群成员被撤销管理员
     * TIM.TYPES.GRP_TIP_GRP_PROFILE_UPDATED	6	群组资料变更
     * TIM.TYPES.GRP_TIP_MBR_PROFILE_UPDATED	7	群成员资料变更
     */
    operationType: number;
    /**
     * 相关的 userID 列表
     */
    userIDList: string[];
    /**
     * 若是群资料变更，该字段存放变更的群资料
     */
    newGroupProfile?: Group;
}
/**
 * 群系统通知消息
 */
declare interface GroupSystemNoticePayload {
    /**
     * 执行该操作的用户 ID
     */
    operatorID: string;
    /**
     * 操作类型，具体如下：
     * 值	描述	接收对象
     * 1	有用户申请加群	群管理员/群主接收
     * 2	申请加群被同意	申请加群的用户接收
     * 3	申请加群被拒绝	申请加群的用户接收
     * 4	被踢出群组	被踢出的用户接收
     * 5	群组被解散	全体群成员接收
     * 6	创建群组	创建者接收
     * 7	邀请加群	被邀请者接收
     * 8	退群	退群者接收
     * 9	设置管理员	被设置方接收
     * 10	取消管理员	被取消方接收
     * 255	用户自定义通知	默认全员接收
     */
    operationType: number;
    /**
     * 相关的群组资料
     */
    groupProfile: Group;
    /**
     * 处理的附言
     */
    handleMessage: any;
}
/**
 * 消息选项
 */
declare interface MessageOptions {
    /**
     * 消息接收方的 userID 或 groupID
     */
    to: string;
    /**
     * 会话类型。TIM.TYPES.CONV_C2C(端到端会话) 或者 TIM.TYPES.CONV_GROUP(群组会话)
     */
    conversationType: string | number;
    /**
     * 消息载体
     */
    payload: TextPayload | ImageCreatePayload | FileCreatePayload;
    /**
     * 获取上传进度的回调函数
     * @param event 事件
     */
    onProgress?: (event: any) => void;
}
/**
 * 拉取指定会话的消息列表参数
 */
declare interface GetMessageListOptions {
    /**
     * 会话 ID
     */
    conversationID: string;
    /**
     * 用于分页续拉的消息 ID。第一次拉取时该字段可不填，每次调用该接口会返回该字段，续拉时将返回字段填入即可。
     */
    nextReqMessageID?: string;
    /**
     * 最大值 15。表示需要拉几条消息
     */
    count: number;
}
/**
 * 获取消息列表响应
 */
declare interface GetMessageListResponse {
    /**
     * 消息列表
     */
    messageList: Message[];
    /**
     * 用于续拉，分页续拉时需传入该字段。
     */
    nextReqMessageID: string;
    /**
     * 表示是否已经拉完所有消息
     */
    isCompleted: boolean;
}
/**
 * 设置消息已读选项
 */
declare interface SetMessageReadOptions {
    /**
     * 会话ID
     */
    conversationID: string;
}
/**
 * 最新的消息
 */
declare interface LastMessage {
    /**
     * 当前会话最新消息的时间戳，单位：秒
     */
    lastTime: number;

    /**
     *  当前会话的最新消息的 Sequence
     */
    lastSequence: number;

    /**
     *  最新消息来自于那个用户
     */
    fromAccount: string;

    /**
     * 最新消息的内容，用于展示。可能值：文本消息内容、"[图片]"、"[语音]"、"[位置]"、"[表情]"、"[文件]"、"[其他]"
     */
    messageForShow: string;
}
/* 消息结构体 start */

/* 会话结构体 start */
/**
 * 会话对象，用于描述会话具有的属性，如类型、消息未读计数、最新消息等。
 */
declare interface Conversation {
    /**
     * 会话 ID。会话ID组成方式：
     *
     * C2C+userID（单聊）
     * GROUP+groupID（群聊）
     * @TIM#SYSTEM（系统通知会话）
     */
    conversationID: string;
    /**
     * 会话类型，具体如下：
     * TIM.TYPES.CONV_C2C	    C2C（Client to Client, 端到端）会话
     * TIM.TYPES.CONV_GROUP	    GROUP（群组）会话
     * TIM.TYPES.CONV_SYSTEM	SYSTEM（系统）会话
     */
    type: string;
    /**
     * 群组会话的群组类型，具体如下：
     * TIM.TYPES.GRP_PRIVATE	私有群
     * TIM.TYPES.GRP_PUBLIC	    公开群
     * TIM.TYPES.GRP_CHATROOM	聊天室
     * TIM.TYPES.GRP_AVCHATROOM	音视频聊天室
     */
    subType: string;
    /**
     * 未读计数。TIM.TYPES.GRP_CHATROOM / TIM.TYPES.GRP_AVCHATROOM 类型的群组会话不记录未读计数，该字段值为0
     */
    unreadCount: number;
    /**
     * 最新的消息
     */
    lastMessage: LastMessage;
    /**
     * 群组会话的群组资料
     */
    groupProfile: object;
    /**
     * C2C会话的用户资料
     */
    userProfile: Profile;
}

/**
 * 获取会话列表响应
 */
declare interface GetConversationListResponse {
    /**
     * 会话列表
     */
    conversationList: Conversation[];
}

/**
 * 获取会话资料响应
 */
declare interface GetConversationProfileResponse {
    /**
     * 会话
     */
    conversation: Conversation;
}

/**
 * 删除会话响应
 */
declare interface DeleteConversationResponse {
    /**
     * 会话ID
     */
    conversationID: string;
}
/* 会话结构体 start */

/* 资料结构体 start */
/**
 * 用户资料对象，用于描述用户具有的属性，如昵称、头像地址、个性签名、性别等。
 */
declare interface Profile {

    /**
     * 用户账号
     */
    userID: string;
    /**
     * 昵称，长度不得超过500个字节
     */
    nick: string;

    /**
     * 性别
     *
     * TIM.TYPES.GENDER_UNKNOWN（未设置性别）
     * TIM.TYPES.GENDER_FEMALE（女）
     * TIM.TYPES.GENDER_MALE（男）
     */
    gender: string;

    /**
     * 生日 uint32 推荐用法：20000101
     */
    birthday: number;

    /**
     * 所在地
     * 长度不得超过16个字节，推荐用法如下：App 本地定义一套数字到地名的映射关系 后台实际保存的是4个 uint32_t 类型的数字：
     * 第一个 uint32_t 表示国家
     * 第二个 uint32_t 用于表示省份
     * 第三个 uint32_t 用于表示城市
     * 第四个 uint32_t 用于表示区县
     */
    location: string;

    /**
     * 个性签名 长度不得超过500个字节
     */
    selfSignature: string;

    /**
     * 加好友验证方式
     * TIM.TYPES.ALLOW_TYPE_ALLOW_ANY（允许任何人添加自己为好友）
     * TIM.TYPES.ALLOW_TYPE_NEED_CONFIRM（需要经过自己确认才能添加自己为好友）
     * TIM.TYPES.ALLOW_TYPE_DENY_ANY（不允许任何人添加自己为好友）
     */
    allowType: string;
    /**
     * 语言 uint32
     */
    language: number;

    /**
     * 头像URL，长度不得超过500个字节
     */
    avatar: string;

    /**
     * 消息设置 uint32 标志位：Bit0：置0表示接收消息，置1则不接收消息
     */
    messageSettings: number;
    /**
     * 管理员禁止加好友标识
     * TIM.TYPES.FORBID_TYPE_NONE（默认值，允许加好友）
     * TIM.TYPES.FORBID_TYPE_SEND_OUT（禁止该用户发起加好友请求）
     */
    adminForbidType: string;

    /**
     * 等级 uint32 建议拆分以保存多种角色的等级信息
     */
    level: number;

    /**
     * 角色 uint32 建议拆分以保存多种角色信息
     */
    role: number;

    /**
     * 上次更新时间，用户本地时间
     */
    lastUpdatedTime: number;
}

/**
 * 用户ID列表参数
 */
declare interface UserIDListOptions {
    /**
     * 用户的账号列表
     */
    userIDList: string[];
}
/* 资料结构体 end */

/* 群组结构体 start */
/**
 * 群组对象，用于描述群组具有的属性，如类型、群组公告、创建时间等。
 */
declare interface Group {
    /**
     * 群组的唯一标识，群组 ID，App 内保证唯一，其格式前缀为 @TGS#。另外，App 亦可自定义群组 ID
     */
    groupID: string;
    /**
     * 群组名称，最长30字节，不可调整
     */
    name: string;
    /**
     * 群组头像 URL，最长100字节，不可调整
     */
    avatar: string;
    /**
     * 群组类型，当前 SDK 支持的类型如下：
     * TIM.TYPES.GRP_PRIVATE	私有群
     * TIM.TYPES.GRP_PUBLIC	    公开群
     * TIM.TYPES.GRP_CHATROOM	聊天室
     * TIM.TYPES.GRP_AVCHATROOM	音视频聊天室
     */
    type: string;
    /**
     * 群组简介，最长120字节，不可调整
     */
    introduction: string;
    /**
     * 群组公告，最长150字节，不可调整
     */
    notification: string;
    /**
     * 群主 ID
     */
    ownerID: string;
    /**
     * 群组的创建时间
     */
    createTime: number;
    /**
     * 群资料的每次变都会增加该值
     */
    infoSequence: number;
    /**
     * 群组最后一次信息变更时间
     */
    lastInfoTime: number;
    /**
     * 当前用户在群组中的信息
     */
    selfInfo: GroupSelfInfo;
    /**
     * 群组最后一条消息
     */
    lastMessage: LastMessage;
    /**
     * 群内下一条消息的 Seq，群组内每一条消息都有一条唯一的消息 Seq，且该 Seq 是按照发消息顺序而连续的。从 1 开始，群内每增加一条消息，nextMessageSeq 就会增加 1
     */
    nextMessageSeq: number;
    /**
     * 当前成员数量
     */
    memberNum: number;
    /**
     * 最大成员数量
     */
    maxMemberNum: number;
    /**
     * 群成员列表
     */
    memberList: GroupMember[];
    /**
     * 申请加群选项。
     * TIM.TYPES.JOIN_OPTIONS_FREE_ACCESS（自由加入，音视频聊天室固定为该值）
     * TIM.TYPES.JOIN_OPTIONS_NEED_PERMISSION（需要验证）
     * TIM.TYPES.JOIN_OPTIONS_DISABLE_APPLY（禁止加群，私有群固定为该值）
     */
    joinOption: string;
    /**
     * 群组自定义字段。默认情况是没有的。
     */
    groupCustomField: {[key: string]: string};
}
/**
 * 当前用户在群组中的信息
 */
declare interface GroupSelfInfo {
    /**
     * 角色
     */
    role: string;
    /**
     * 消息接收选项
     * TIM.TYPES.MSG_REMIND_ACPT_AND_NOTE - SDK 接收消息并通知接入侧（抛出 收到消息事件），接入侧做提示
     * TIM.TYPES.MSG_REMIND_ACPT_NOT_NOTE - SDK 接收消息并通知接入侧（抛出 收到消息事件），接入侧不做提示
     * TIM.TYPES.MSG_REMIND_DISCARD - SDK 拒收消息
     */
    messageRemindType: string;
    /**
     * 入群时间
     */
    joinTime: number;
    /**
     * 群名片
     */
    nameCard: string;
}
/**
 * 获取群组列表响应
 */
declare interface GetGroupListResponse {
    /**
     * 群组列表
     */
    groupList: Group[];
}
/**
 * 获取群详细资料参数
 */
declare interface GetGroupProfileOptions {
    /**
     * 群组ID
     */
    groupID: string;
    /**
     * 群组维度的自定义字段过滤器，指定需要获取的群组维度的自定义字段
     */
    groupCustomFieldFilter: string[];
    /**
     * 群成员维度的自定义字段过滤器，指定需要获取的群成员维度的自定义字段
     */
    memberCustomFieldFilter: string[];
}
/**
 * 群详细资料响应
 */
declare interface GroupProfileResponse {
    /**
     * 群组
     */
    group: Group;
}
/**
 * 群组ID响应
 */
declare interface GroupIdResponse {
    /**
     * 群组 ID
     */
    groupID: string;
}
/**
 * 申请加群参数
 */
declare interface JoinGroupOptions {
    /**
     * 群组ID
     */
    groupID: string;
    /**
     * 附言
     */
    applyMessage: string;
    /**
     * 要加入群组的类型，加入音视频聊天室时该字段必填。可选值：
     * TIM.TYPES.GRP_PUBLIC（公开群）
     * TIM.TYPES.GRP_CHATROOM （聊天室）
     * TIM.TYPES.GRP_AVCHATROOM （音视频聊天室）
     */
    type?: string;
}
/**
 * 申请加群响应
 */
declare interface JoinGroupResponse {
    /**
     * 加入状态
     */
    status: string;
    /**
     * 加入的群组资料
     */
    group: Group;
}
/**
 * 转让群参数
 */
declare interface ChangeGroupOwnerOptions {
    /**
     * 待转让的群组 ID
     */
    groupID: string;
    /**
     * 新群主的 ID
     */
    newOwnerID: string;
}
/**
 * 处理申请加群（同意或拒绝）参数
 */
declare interface HandleGroupApplicationOptions {
    /**
     * 处理结果 Agree(同意) / Reject(拒绝)
     */
    handleAction: string;
    /**
     * 附言
     */
    handleMessage?: string;
    /**
     * 对应【群系统通知】的消息实例
     */
    message: Message;
}
/**
 * 设置自己的群消息提示类型参数
 */
declare interface SetMessageRemindTypeOptions {
    /**
     * 群ID
     */
    groupID: string;
    /**
     * 群消息提示类型。详细如下：
     * TIM.TYPES.MSG_REMIND_ACPT_AND_NOTE（SDK 接收消息并通知接入侧(抛出 收到消息事件)，接入侧做提示）
     * TIM.TYPES.MSG_REMIND_ACPT_NOT_NOTE（SDK 接收消息并通知接入侧(抛出 收到消息事件)，接入侧不做提示）
     * TIM.TYPES.MSG_REMIND_DISCARD（SDK 拒收消息）
     */
    messageRemindType: string;
}
/* 群组结构体 end */

/* 群成员结构体 start */
/**
 * 群成员对象，用于描述群成员具有的属性，如 ID、昵称、群内身份、入群时间等。
 */
declare interface GroupMember {
    /**
     * 群成员 ID
     */
    userID: string;
    /**
     * 群成员头像 URL
     */
    avatar: string;
    /**
     * 群成员昵称
     */
    nick: string;
    /**
     * 群内身份
     * TIM.TYPES.GRP_MBR_ROLE_OWNER（群主）
     * TIM.TYPES.GRP_MBR_ROLE_ADMIN（群管理员）
     * TIM.TYPES.GRP_MBR_ROLE_MEMBER（群普通成员）
     */
    role: string;
    /**
     * 入群时间
     */
    joinTime: number;
    /**
     * 最后发送消息的时间
     */
    lastSendMsgTime: number;
    /**
     * 群名片
     */
    nameCard: string;
    /**
     * 禁言时间，值是时间戳，单位: 秒。
     */
    muteUntil: number;
    /**
     * 群成员自定义字段
     */
    memberCustomField: {[key: string]: string};
}
/**
 * 添加群成员参数
 */
declare interface AddGroupMemberOptions {
    /**
     * 群组ID
     */
    groupID: string;
    /**
     * 待添加的群成员 ID 数组。单次最多添加500个成员
     */
    userIDList: string[];
}
/**
 * 添加群成员响应
 */
declare interface AddGroupMemberResponse {
    /**
     * 添加成功的群成员
     */
    successUserIDList: string[];
    /**
     * 添加失败的群成员
     */
    failureUserIDList: string[];
    /**
     * 已在群中的群成员
     */
    existedUserIDList: string[];
    /**
     * 添加后的群组信息
     */
    group: Group;
}
/**
 * 删除群成员参数
 */
declare interface DeleteGroupMemberOptions {
    /**
     * 群组ID
     */
    groupID: string;
    /**
     * 待删除的群成员的 ID 列表
     */
    userIDList: string[];
    /**
     * 踢人的原因
     */
    reason?: string;
}
/**
 * 删除群成员响应
 */
declare interface DeleteGroupMemberResponse {
    /**
     * 群组
     */
    group: Group;
    /**
     * 被删除的群成员的 userID 列表
     */
    userIDList: string[];
}
/**
 * 设置群成员的禁言时间参数
 */
declare interface SetGroupMemberMuteTimeOptions {
    /**
     * 群组ID
     */
    groupID: string;
    /**
     * 用户ID
     */
    userID: string;
    /**
     * 禁言时长，单位秒。如设为1000，则表示从现在起禁言该用户1000秒；设为0，则表示取消禁言。
     */
    muteTime: number;
}
/**
 * 修改群成员角色参数
 */
declare interface SetGroupMemberRoleOptions {
    /**
     * 群组ID
     */
    groupID: string;
    /**
     * 用户ID
     */
    userID: string;
    /**
     * 角色，可选值：TIM.TYPES.GRP_MBR_ROLE_ADMIN（群管理员） 或 TIM.TYPES.GRP_MBR_ROLE_MEMBER（群普通成员）
     */
    role: string;
}
/**
 * 设置群成员名片参数
 */
declare interface SetGroupMemberNameCardOptions {
    /**
     * 群组ID
     */
    groupID: string;
    /**
     * 用户ID
     */
    userID: string;
    /**
     * 名片
     */
    nameCard: string;
}
/**
 * 设置群成员自定义字段参数
 */
declare interface SetGroupMemberCustomFieldOptions {
    /**
     * 群组ID
     */
    groupID: string;
    /**
     * 用户ID, 可选，默认修改自身的群名片
     */
    userID?: string;
    /**
     * 群成员自定义字段列表
     */
    memberCustomField: MemberCustomField[];
}
/**
 * 群成员自定义字段
 */
declare interface MemberCustomField {
    /**
     * 自定义字段的 Key
     */
    key: string;
    /**
     * 自定义字段的 Value
     */
    value: string;
}
/* 群成员结构体 end */

/**
 * TIM SDK
 */
declare class TIM {
    /**
     * 事件定义
     */
    public static EVENT: {[key in EventName]: string};
    /**
     * 类型定义
     */
    public static TYPES: {[key in TypeName]: string | number};
    /**
     * 版本号
     */
    public static VERSION: string;

    /**
     * 创建SDK 实例
     * @param options
     * @return tim实例
     */
    public static create(options: TIMCreateOptions): TIM;

    /* 基础 start */
    /**
     * 使用 用户ID(userID) 和 签名串(userSig) 登录即时通信 IM，登录流程有若干个异步执行的步骤，使用返回的 Promise 对象处理登录成功或失败
     * @param options 登录配置
     * @return IMPromise<TIMLoginResponse>
     */
    public login(options: TIMLoginOptions): IMPromise<TIMLoginResponse>;
    /**
     * 登出即时通信 IM，通常在切换帐号的时候调用，清除登录态以及内存中的所有数据
     * @return IMPromise<any>
     */
    public logout(): IMPromise<any>;
    /**
     * 取消事件监听
     * @param eventName 事件名称
     * @param handler 处理事件的方法，当事件触发时，会调用此handler进行处理
     */
    public off(eventName: string, handler: (event: IMEvent<any>) => void): void;
    /**
     * 事件监听
     * @param eventName 事件名称
     * @param handler 处理事件的方法，当事件触发时，会调用此handler进行处理
     */
    public on(eventName: string, handler: (event: IMEvent<any>) => void): void;
    /**
     * 事件监听,只执行一次
     * @param eventName 事件名称
     * @param handler 处理事件的方法，当事件触发时，会调用此handler进行处理
     */
    public once(eventName: string, handler: (event: IMEvent<any>) => void): void;
    /**
     * 注册插件
     * @param pluginMap 插件名：插件对象
     */
    public registerPlugin(pluginMap: { [key: string]: any }): void;
    /**
     * 设置 SDK 日志输出级别
     * @param level 日志级别
     *           0 普通级别，日志量较多，接入时建议使用
     *           1 release级别，SDK 输出关键信息，生产环境时建议使用
     *           2 告警级别，SDK 只输出告警和错误级别的日志
     *           3 错误级别，SDK 只输出错误级别的日志
     *           4 无日志级别，SDK 将不打印任何日志
     */
    public setLogLevel(level: number): void;
    /* 基础 end */

    /* 消息 start */
    /**
     * 创建文本消息。此接口返回一个消息实例，可以调用发送消息 接口发送消息。
     * @param options 消息选项
     * @return 消息实例
     */
    public createTextMessage(options: MessageOptions): Message;
    /**
     * 创建图片消息。此接口返回一个消息实例，可以调用发送消息 接口发送消息。
     * @param options 消息选项
     * @return 消息实例
     */
    public createImageMessage(options: MessageOptions): Message;
    /**
     * 创建文件消息。此接口返回一个消息实例，可以调用发送消息 接口发送消息。
     * @param options 消息选项
     * @return 消息实例
     */
    public createFileMessage(options: MessageOptions): Message;
    /**
     * 创建自定义消息。此接口返回一个消息实例，可以调用发送消息 接口发送消息。
     * @param options 消息选项
     * @return 消息实例
     */
    public createCustomMessage(options: MessageOptions): Message;
    /**
     * 发送消息
     * @param message 消息实例
     * @return IMPromise<Message>
     */
    public sendMessage(message: Message): IMPromise<Message>;
    /**
     * 重发消息
     * 调用时机：消息发送失败时，调用该接口进行重发。
     * 注意：目前暂不支持图片和文件消息重发。
     * @param message 消息实例
     * @return IMPromise<Message>
     */
    public resendMessage(message: Message): IMPromise<Message>;
    /**
     * 分页拉取指定会话的消息列表
     * @param options 拉取指定会话的消息列表参数
     * @return IMPromise<GetMessageListResponse>
     */
    public getMessageList(options: GetMessageListOptions): IMPromise<GetMessageListResponse>;
    /**
     * 将某会话下的未读消息状态设置为已读，置为已读的消息不会计入到未读统计。
     * @param options 参数
     */
    public setMessageRead(options: SetMessageReadOptions): void;
    /* 消息 end */

    /* 会话 start */
    /**
     * 获取会话列表，该接口拉取最近的100条会话
     * 使用时机：需要刷新会话列表时调用该接口
     * @return IMPromise<GetConversationListResponse>
     */
    public getConversationList(): IMPromise<GetConversationListResponse>;
    /**
     * 获取会话资料
     * 使用时机：点击会话列表中的某个会话时，调用该接口获取会话的详细信息
     * @param conversationID 会话 ID
     * @return IMPromise<GetConversationProfileResponse>
     */
    public getConversationProfile(conversationID: string): IMPromise<GetConversationProfileResponse>;
    /**
     * 根据会话 ID 删除会话
     * @param conversationID 会话 ID
     * @return IMPromise<DeleteConversationResponse>
     */
    public deleteConversation(conversationID: string): IMPromise<DeleteConversationResponse>;
    /* 会话 end */

    /* 资料 start */
    /**
     * 获取个人资料
     * @return IMPromise<Profile>
     */
    public getMyProfile(): IMPromise<Profile>;
    /**
     * 获取其他用户资料
     * @param options 用户ID列表参数
     * @return IMPromise<Profile[]>
     */
    public getUserProfile(options: UserIDListOptions): IMPromise<Profile[]>;
    /**
     * 更新个人资料
     * @param options 资料参数
     * @return IMPromise<Profile>
     */
    public updateMyProfile(options: Profile): IMPromise<Profile>;
    /**
     * 获取我的黑名单列表
     * @return IMPromise<string[]>
     */
    public getBlacklist(): IMPromise<string[]>;
    /**
     * 添加用户到黑名单列表。将用户加入黑名单后可以屏蔽来自 TA 的所有消息，因此该接口可以实现“屏蔽该用户消息”的功能。
     * 如果用户 A 与用户 B 之间存在好友关系，拉黑时会解除双向好友关系。
     * 如果用户 A 与用户 B 之间存在黑名单关系，二者之间无法发起会话。
     * 如果用户 A 与用户 B 之间存在黑名单关系，二者之间无法发起加好友请求。
     * @param options 用户ID列表参数
     * @return IMPromise<string[]>
     */
    public addToBlacklist(options: UserIDListOptions): IMPromise<string[]>;
    /**
     * 将用户从黑名单中移除。移除后，可以接收来自 TA 的所有消息。
     * @param options 用户ID列表参数
     * @return IMPromise<string[]>
     */
    public removeFromBlacklist(options: UserIDListOptions): IMPromise<string[]>;
    /* 资料 end */

    /* 群组 start */
    /**
     * 获取群组列表
     * @return IMPromise<GetGroupListResponse>
     */
    public getGroupList(): IMPromise<GetGroupListResponse>;
    /**
     * 获取群详细资料
     * @param options 获取群详细资料参数
     * @return IMPromise<GroupProfileResponse>
     */
    public getGroupProfile(options: GetGroupProfileOptions): IMPromise<GroupProfileResponse>;
    /**
     * 创建群组
     * @param options 参数集
     * @return IMPromise<GroupProfileResponse>
     */
    public createGroup(options: Group): IMPromise<GroupProfileResponse>;
    /**
     * 解散群组
     * @param groupID 群组 ID
     * @return IMPromise<GroupIdResponse>
     */
    public dismissGroup(groupID: string): IMPromise<GroupIdResponse>;
    /**
     * 修改群组资料
     * @param options 参数集
     * @return IMPromise<GroupProfileResponse>
     */
    public updateGroupProfile(options: Group): IMPromise<GroupProfileResponse>;
    /**
     * 申请加群
     * @param options 参数集
     * @return IMPromise<JoinGroupResponse>
     */
    public joinGroup(options: JoinGroupOptions): IMPromise<JoinGroupResponse>;
    /**
     * 退出群组
     * @param groupID 群组 ID
     * @return IMPromise<JoinGroupResponse>
     */
    public quitGroup(groupID: string): IMPromise<GroupIdResponse>;
    /**
     * 通过 groupID 搜索群组
     * @param groupID 群组 ID
     * @return IMPromise<GroupProfileResponse>
     */
    public searchGroupByID(groupID: string): IMPromise<GroupProfileResponse>;
    /**
     * 转让群组。只有群主有权限操作。
     * 注意：只有群主拥有转让的权限。TIM.TYPES.GRP_AVCHATROOM（音视频聊天室）类型的群组不能转让。
     * @param options 参数集
     * @return IMPromise<GroupProfileResponse>
     */
    public changeGroupOwner(options: ChangeGroupOwnerOptions): IMPromise<GroupProfileResponse>;
    /**
     * 处理申请加群（同意或拒绝）
     * @param options 参数集
     * @return IMPromise<GroupProfileResponse>
     */
    public handleGroupApplication(options: HandleGroupApplicationOptions): IMPromise<GroupProfileResponse>;
    /**
     * 设置自己的群消息提示类型。
     * @param options 参数集
     * @return IMPromise<GroupProfileResponse>
     */
    public setMessageRemindType(options: SetMessageRemindTypeOptions): IMPromise<GroupProfileResponse>;
    /* 群组 end */

    /* 群成员 start */
    /**
     * 添加群成员
     * @param options 参数集
     * @return IMPromise<AddGroupMemberResponse>
     */
    public addGroupMember(options: AddGroupMemberOptions): IMPromise<AddGroupMemberResponse>;
    /**
     * 删除群成员
     * @param options 参数集
     * @return IMPromise<DeleteGroupMemberResponse>
     */
    public deleteGroupMember(options: DeleteGroupMemberOptions): IMPromise<DeleteGroupMemberResponse>;
    /**
     * 设置群成员的禁言时间，可以禁言群成员，也可取消禁言。TIM.TYPES.GRP_PRIVATE 类型的群组（即私有群）不能禁言。
     * @param options 参数集
     * @return IMPromise<GroupProfileResponse>
     */
    public setGroupMemberMuteTime(options: SetGroupMemberMuteTimeOptions): IMPromise<GroupProfileResponse>;
    /**
     * 修改群成员角色。只有群主拥有操作的权限。
     * @param options 参数集
     * @return IMPromise<GroupProfileResponse>
     */
    public setGroupMemberRole(options: SetGroupMemberRoleOptions): IMPromise<GroupProfileResponse>;
    /**
     * 设置群成员名片。
     * @param options 参数集
     * @return IMPromise<GroupProfileResponse>
     */
    public setGroupMemberNameCard(options: SetGroupMemberNameCardOptions): IMPromise<GroupProfileResponse>;
    /**
     * 设置群成员自定义字段。
     * @param options 参数集
     * @return IMPromise<GroupProfileResponse>
     */
    public setGroupMemberCustomField(options: SetGroupMemberCustomFieldOptions): IMPromise<GroupProfileResponse>;
    /* 群成员 end */
}

declare module "tim-js-sdk" {
    export default TIM;
}
