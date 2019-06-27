#ifndef SDK_TIM_CLOUD_DEF_HEADER_
#define SDK_TIM_CLOUD_DEF_HEADER_
#include "TIMCloudComm.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                      错误码
//
/////////////////////////////////////////////////////////////////////////////////
//详细 [错误码](https://cloud.tencent.com/document/product/269/1671)，请您移步官网查看
enum TIMErrCode {
    ERR_SUCC                             = 0,    // 成功               
    ERR_PARSE_RESPONSE_FAILED            = 6001, // 回包解析失败,内部错误
    ERR_SERIALIZE_REQ_FAILED             = 6002, // 文档未定义
    ERR_NO_SUCC_RESULT                   = 6003, // 批量操作无成功结果,请检查输入列表是否合法（如用户是否存在,传入列表类型是否与 API 匹配）
    ERR_INVALID_CONVERSATION             = 6004, // 会话无效,getConversation 时检查是否已经登录,如未登录获取会话,会有此错误码返回
    ERR_LOADMSG_FAILED                   = 6005, // 加载本地消息存储失败,可能存储文件有损坏
    ERR_FILE_TRANS_AUTH_FAILED           = 6006, // 文件传输-鉴权失败
    ERR_FILE_TRANS_NO_SERVER             = 6007, // 文件传输-获取 Server 列表失败
    ERR_FILE_TRANS_UPLOAD_FAILED         = 6008, // 文件传输-上传失败,请检查网络是否连接
    ERR_FILE_TRANS_DOWNLOAD_FAILED       = 6009, // 文件传输-下载失败,请检查网络,或者文件、语音是否已经过期,目前资源文件存储 7 天
    ERR_HTTP_REQ_FAILED                  = 6010, // HTTP 请求失败
    ERR_TO_USER_INVALID                  = 6011, // 消息接收方无效,对方用户不存在（接收方需登录过 ImSDK 或用帐号导入接口导入）
    ERR_REQUEST_TIMEOUT                  = 6012, // 请求超时,请等网络恢复后重试。（Android SDK 1.8.0 以上需要参考 Android 服务进程配置方式进行配置,否则会出现此错误）
    ERR_SDK_NOT_INITIALIZED              = 6013, // SDK 未初始化或者用户未登录成功,请先登录,成功回调之后重试
    ERR_SDK_NOT_LOGGED_IN                = 6014, // SDK 未登录,请先登录,成功回调之后重试,或者被踢下线,可使用 TIMManager getLoginUser 检查当前是否在线
    ERR_IN_PROGESS                       = 6015, // 请做好接口调用控制,第一次 login 操作回调前,后续的 login 操作会返回该错误码
    ERR_INVALID_MSG_ELEM                 = 6016, // 注册超时,需要重试
    ERR_INVALID_PARAMETERS               = 6017, // API 参数无效,请检查参数是否符合要求,具体可查看错误信息进一步定义哪个字段
    ERR_INIT_CORE_FAIL                   = 6018, // SDK 初始化失败,可能是部分目录无权限
    ERR_DATABASE_OPERATE_FAILED          = 6019, // 本地数据库操作失败,可能是部分目录无权限或者数据库文件已损坏
    ERR_EXPIRED_SESSION_NODE             = 6020, // Session Node 过期
    ERR_INVALID_SDK_OBJECT               = 6021, // 下载资源文件参数错误,如还未上传成功调用接口下载资源,或者用户自己生成 TIMImage 等对象
    ERR_IO_OPERATION_FAILED              = 6022, // 操作本地 IO 错误,检查是否有读写权限,磁盘是否已满
    ERR_LOGGED_OUT_BEFORE_LOGIN_FINISHED = 6023, // 在登录操作没有完成前进行了登出操作（或者被踢下线）
    ERR_TLSSDK_NOT_INITIALIZED           = 6024, // TLSSDK未初始化
    ERR_TLSSDK_FIND_NO_USER              = 6025, // TLSSDK没有找到相应的用户信息

    ERR_REQUEST_NO_NET_ONREQ             = 6200, // 请求时没有网络,请等网络恢复后重试
    ERR_REQUEST_NO_NET_ONRSP             = 6201, // 响应时没有网络,请等网络恢复后重试
    ERR_SERIVCE_NOT_READY                = 6205, // QAL服务未启动
    ERR_USER_SIG_EXPIRED                 = 6206, // 票据过期(imcore)
    ERR_LOGIN_KICKED_OFF_BY_OTHER        = 6208, // 其他终端登录帐号被踢,需重新登录
    ERR_NEVER_CONNECT_AFTER_LAUNCH       = 6209, // 程序启动后没有尝试联网

    ERR_REQUEST_FAILED                   = 6210, // QAL执行失败
    ERR_REQUEST_INVALID_REQ              = 6211, // 请求非法,toMsgService非法
    ERR_REQUEST_OVERLOADED               = 6212, // 请求队列満
    ERR_REQUEST_KICK_OFF                 = 6213, // 已经被其他终端踢了
    ERR_REQUEST_SERVICE_SUSPEND          = 6214, // 服务被暂停
    ERR_REQUEST_INVALID_SIGN             = 6215, // SSO签名错误
    ERR_REQUEST_INVALID_COOKIE           = 6216, // SSO cookie无效
    ERR_LOGIN_TLS_RSP_PARSE_FAILED       = 6217, // 登录时TLS回包校验,包体长度错误
    ERR_LOGIN_OPENMSG_TIMEOUT            = 6218, // 登录时OPENSTATSVC向OPENMSG上报状态时超时
    ERR_LOGIN_OPENMSG_RSP_PARSE_FAILED   = 6219, // 登录时OPENSTATSVC向OPENMSG上报状态时解析回包失败
    ERR_LOGIN_TLS_DECRYPT_FAILED         = 6220, // 登录时TLS解密失败
    ERR_WIFI_NEED_AUTH                   = 6221, // 连接上的wifi需要认证（不认证的情况下,无法连接网络）
    ERR_USER_CANCELED                    = 6222, // 用户已取消
    ERR_REVOKE_TIME_LIMIT_EXCEED         = 6223, // 消息撤回超过了时间限制（默认2分钟）

    ERR_QAL_NO_SHORT_CONN_AVAILABLE      = 6300, // 没有可用的短连接sso
};


/// @name 常用宏和基础配置选项
/// @{
/**
* @brief 调用接口的返回值
*
* @note
* 若接口参数中有回调，只有当接口返回TIM_SUCC时，回调才会被调用
*/
enum TIMResult {
    TIM_SUCC = 0,          // 接口调用成功
    TIM_ERR_SDKUNINIT = -1,// 接口调用失败，ImSDK未初始化
    TIM_ERR_NOTLOGIN = -2, // 接口调用失败，用户未登录
    TIM_ERR_JSON = -3,     // 接口调用失败，错误的Json格式或Json Key
    TIM_ERR_PARAM = -4,    // 接口调用成功，参数错误
    TIM_ERR_CONV = -5,     // 接口调用成功，无效的会话
    TIM_ERR_GROUP = -6,    // 接口调用成功，无效的群组
};

/**
* @brief 日志级别
*/
enum TIMLogLevel {
    kTIMLog_Off,     // 关闭日志输出
    kTIMLog_Verbose, // 开发调试过程中一些详细信息日志
    kTIMLog_Debug,   // 调试日志
    kTIMLog_Info,    // 信息日志
    kTIMLog_Warn,    // 警告日志
    kTIMLog_Error,   // 错误日志
    kTIMLog_Assert,  // 断言日志
};

/**
* @brief 连接事件类型
*/
enum TIMNetworkStatus {
    kTIMConnected,       // 已连接
    kTIMDisconnected,    // 失去连接
    kTIMConnecting,      // 正在连接
    kTIMConnectFailed,   // 连接失败
};

/**
* @brief 会话事件类型
*/
enum TIMConvEvent {
    kTIMConvEvent_Add,    // 会话新增,比如收到一条新消息,产生一个新的会话是事件触发
    kTIMConvEvent_Del,    // 会话删除,比如自己删除某会话时会触发
    kTIMConvEvent_Update, // 会话更新,会话内消息的未读计数变化和收到新消息时触发
};

/**
* @brief 会话类型
*/
enum TIMConvType {
    kTIMConv_Invalid, // 无效会话
    kTIMConv_C2C,     // 个人会话
    kTIMConv_Group,   // 群组会话
    kTIMConv_System,  // 系统会话
};

/**
* @brief 初始化ImSDK的配置
*/
// Struct SdKConfig JsonKey
static const char* kTIMSdkConfigConfigFilePath     = "sdk_config_config_file_path";// string, 只写(选填), 配置文件路径,默认路径为"/"
static const char* kTIMSdkConfigLogFilePath        = "sdk_config_log_file_path";   // string, 只写(选填), 日志文件路径,默认路径为"/"
// EndStruct


/**
* @brief 群组成员信息标识
*/
enum TIMGroupMemberInfoFlag {
    kTIMGroupMemberInfoFlag_None         = 0x00,       // 无
    kTIMGroupMemberInfoFlag_JoinTime     = 0x01,       // 加入时间
    kTIMGroupMemberInfoFlag_MsgFlag      = 0x01 << 1,  // 群消息接收选项
    kTIMGroupMemberInfoFlag_MsgSeq       = 0x01 << 2,  // 成员已读消息seq
    kTIMGroupMemberInfoFlag_MemberRole   = 0x01 << 3,  // 成员角色
    kTIMGroupMemberInfoFlag_ShutupUntill = 0x01 << 4,  // 禁言时间。0: 没有禁言
    kTIMGroupMemberInfoFlag_NameCard     = 0x01 << 5,  // 群名片
};

/**
* @brief 群组成员角色标识
*/
enum TIMGroupMemberRoleFlag {
    kTIMGroupMemberRoleFlag_All    = 0x00,       // 获取全部角色类型
    kTIMGroupMemberRoleFlag_Owner  = 0x01,       // 获取所有者(群主)
    kTIMGroupMemberRoleFlag_Admin  = 0x01 << 1,  // 获取管理员，不包括群主
    kTIMGroupMemberRoleFlag_Member = 0x01 << 2,  // 获取普通群成员，不包括群主和管理员
};

/**
* @brief 获取群组成员信息的选项
*/
// Struct GroupMemberGetInfoOption JsonKey
static const char* kTIMGroupMemberGetInfoOptionInfoFlag    = "group_member_get_info_option_info_flag";     // uint64 [TIMGroupMemberInfoFlag](), 读写(选填), 根据想要获取的信息过滤，默认值为0xffffffff(获取全部信息)
static const char* kTIMGroupMemberGetInfoOptionRoleFlag    = "group_member_get_info_option_role_flag";     // uint64 [TIMGroupMemberRoleFlag](), 读写(选填), 根据成员角色过滤，默认值为kTIMGroupMemberRoleFlag_All，获取所有角色
static const char* kTIMGroupMemberGetInfoOptionCustomArray = "group_member_get_info_option_custom_array";  // array string, 只写(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct


/**
* @brief 群组成员信息标识
*/
enum TIMGroupGetInfoFlag {
    kTIMGroupInfoFlag_None         = 0x00,
    kTIMGroupInfoFlag_Name         = 0x01,       // 群组名称
    kTIMGroupInfoFlag_CreateTime   = 0x01 << 1,  // 群组创建时间
    kTIMGroupInfoFlag_OwnerUin     = 0x01 << 2,  // 群组创建者帐号
    kTIMGroupInfoFlag_Seq          = 0x01 << 3,  
    kTIMGroupInfoFlag_LastTime     = 0x01 << 4,  // 群组信息最后修改时间
    kTIMGroupInfoFlag_NextMsgSeq   = 0x01 << 5,  
    kTIMGroupInfoFlag_LastMsgTime  = 0X01 << 6,  // 最新群组消息时间
    kTIMGroupInfoFlag_AppId        = 0x01 << 7,
    kTIMGroupInfoFlag_MemberNum    = 0x01 << 8,  // 群组成员数量
    kTIMGroupInfoFlag_MaxMemberNum = 0x01 << 9,  // 群组成员最大数量
    kTIMGroupInfoFlag_Notification = 0x01 << 10, // 群公告内容
    kTIMGroupInfoFlag_Introduction = 0x01 << 11, // 群简介内容
    kTIMGroupInfoFlag_FaceUrl      = 0x01 << 12, // 群头像URL
    kTIMGroupInfoFlag_AddOpton     = 0x01 << 13, // 加群选项
    kTIMGroupInfoFlag_GroupType    = 0x01 << 14, // 群类型
    kTIMGroupInfoFlag_LastMsg      = 0x01 << 15, // 群组内最新一条消息
    kTIMGroupInfoFlag_OnlineNum    = 0x01 << 16, // 群组在线成员数
    kTIMGroupInfoFlag_Visible      = 0x01 << 17, // 群组是否可见
    kTIMGroupInfoFlag_Searchable   = 0x01 << 18, // 群组是否可以搜索
    kTIMGroupInfoFlag_ShutupAll    = 0x01 << 19, // 群组是否全禁言
};

/**
* @brief 获取群组信息的选项
*/
// Struct GroupGetInfoOption JsonKey
static const char* kTIMGroupGetInfoOptionInfoFlag    = "group_get_info_option_info_flag";     // uint64 [TIMGroupGetInfoFlag](), 读写(选填), 根据想要获取的信息过滤，默认值为0xffffffff(获取全部信息)
static const char* kTIMGroupGetInfoOptionCustomArray = "group_get_info_option_custom_array";  // array string, 只写(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct

/**
* @brief 用于配置信息
*/
// Struct UserConfig JsonKey
static const char* kTIMUserConfigIsReadReceipt            = "user_config_is_read_receipt";             // bool, 只写(选填), true表示要收已读回执事件
static const char* kTIMUserConfigIsSyncReport             = "user_config_is_sync_report";              // bool, 只写(选填), true表示服务端要删掉已读状态
static const char* kTIMUserConfigIsIngoreGroupTipsUnRead  = "user_config_is_ingore_grouptips_unread";  // bool, 只写(选填), true表示群tips不计入群消息已读计数
static const char* kTIMUserConfigGroupGetInfoOption       = "user_config_group_getinfo_option";        // object [GroupGetInfoOption](),  只写(选填),获取群组信息默认选项
static const char* kTIMUserConfigGroupMemberGetInfoOption = "user_config_group_member_getinfo_option"; // object [GroupMemberGetInfoOption](),  只写(选填),获取群组成员信息默认选项
// EndStruct

/**
* @brief HTTP代理信息
*/
// Struct HttpProxyInfo JsonKey
static const char* kTIMHttpProxyInfoIp      = "http_proxy_info_ip";   // string, 只写(必填), 代理的IP
static const char* kTIMHttpProxyInfoPort    = "http_proxy_info_port"; // int,    只写(必填), 代理的端口
// EndStruct

/**
* @brief SOCKS5代理信息
*/
// Struct Socks5ProxyInfo JsonKey
static const char* kTIMSocks5ProxyInfoIp       = "socks5_proxy_info_ip";       // string, 只写(必填), socks5代理的IP
static const char* kTIMSocks5ProxyInfoPort     = "socks5_proxy_info_port";     // int,    只写(必填), socks5代理的端口
static const char* kTIMSocks5ProxyInfoUserName = "socks5_proxy_info_username"; // string, 只写(选填), 认证的用户名
static const char* kTIMSocks5ProxyInfoPassword = "socks5_proxy_info_password"; // string, 只写(选填), 认证的密码
// EndStruct

/**
* @brief 更新配置
* > 自定义数据
* + 开发者可以自定义的数据(长度限制为64个字节)，ImSDK只负责透传给云通信IM后台后，可以通过第三方回调[状态变更回调](https://cloud.tencent.com/document/product/269/2570)告知开发者业务后台。
* > HTTP代理
* + HTTP代理主要用在发送图片、语音、文件、微视频等消息时，将相关文件上传到COS，以及接收到图片、语音、文件、微视频等消息，将相关文件下载到本地时用到。
*   设置时，设置的IP不能为空，端口不能为0.如果需要取消HTTP代理，只需将代理的IP设置为空字符串，端口设置为0
* > SOCKS5代理
* + SOCKS5代理需要在初始化之前设置。设置之后ImSDK发送的所有协议会通过SOCKS5代理服务器发送的云通信IM后台。
*/
// Struct SetConfig JsonKey
static const char* kTIMSetConfigLogLevel           = "set_config_log_level";             // uint [TIMLogLevel](),  只写(选填), 输出到日志文件的日子级别
static const char* kTIMSetConfigCackBackLogLevel   = "set_config_callback_log_level";    // uint [TIMLogLevel](),  只写(选填), 日子回调的日志级别 
static const char* kTIMSetConfigIsLogOutputConsole = "set_config_is_log_output_console"; // bool,                  只写(选填), 是否输出到控制台 
static const char* kTIMSetConfigUserConfig         = "set_config_user_config";           // object [UserConfig](), 只写(选填), 用户配置
static const char* kTIMSetConfigUserDefineData     = "set_config_user_define_data";      // string,                只写(选填), 自定义数据，如果需要，初始化前设置
static const char* kTIMSetConfigHttpProxyInfo      = "set_config_http_proxy_info";       // object [HttpProxyInfo](),  只写(选填), 设置HTTP代理，如果需要，在发送图片、文件、语音、视频前设置
static const char* kTIMSetConfigSocks5ProxyInfo    = "set_config_socks5_proxy_info";     // object [Socks5ProxyInfo](), 只写(选填), 设置SOCKS5代理，如果需要，初始化前设置
// EndStruct
/// @}

/// @name 消息关键类型
/// @brief 消息相关宏定义，以及相关结构成员存取Json Key定义
/// @{
/**
* @brief 消息当前状态定义
*/
enum TIMMsgStatus {
    kTIMMsg_Sending = 1,        // 消息正在发送
    kTIMMsg_SendSucc = 2,       // 消息发送成功
    kTIMMsg_SendFail = 3,       // 消息发送失败
    kTIMMsg_Deleted = 4,        // 消息已删除
    kTIMMsg_LocalImported = 5,  // 消息导入状态
    kTIMMsg_Revoked = 6,        // 消息撤回状态
};

/**
* @brief 标识消息的优先级，数字越大优先级越低
*/
enum TIMMsgPriority {
    kTIMMsgPriority_High,   // 优先级最高，一般为红包或者礼物消息
    kTIMMsgPriority_Normal, // 表示优先级次之，建议为普通消息
    kTIMMsgPriority_Low,    // 建议为点赞消息等
    kTIMMsgPriority_Lowest, // 优先级最低，一般为成员进退群通知(后台下发)
};

/**
* @brief 消息Json Keys
*
* @note 
* > 对应Elem的顺序
* + 目前文件和语音Elem不一定会按照添加顺序传输，其他Elem按照顺序，不过建议不要过于依赖Elem顺序进行处理，应该逐个按照Elem类型处理，防止异常情况下进程Crash。
* > 针对群组的红包和点赞消息
* + 对于直播场景，会有点赞和发红包功能，点赞相对优先级较低，红包消息优先级较高，具体消息内容可以使用自定义消息[CustomElem]()进行定义，发送消息时，可通过 kTIMMsgPriority 定义消息优先级。
* > 阅后即焚消息
* + 开发者通过设置 kTIMMsgIsOnlineMsg 字段为true时，表示发送阅后即焚消息,该消息有如下特性
* >>C2C会话,当此消息发送时，只有对方在线，对方才会收到。如果当时离线，后续再登录也收不到此消息。
* >>群会话,当此消息发送时，只有群里在线的成员才会收到。如果当时离线，后续再登录也收不到此消息。
* >>此消息服务器不会保存
* >>此消息不计入未读计数
* >>此消息在本地不会存储
* > 消息自定义字段
* + 开发者可以对消息增加自定义字段，如自定义整数(通过 kTIMMsgCustomInt 指定)、自定义二进制数据(通过 kTIMMsgCustomStr 指定，必须转换成String，Json不支持二进制传输)，可以根据这两个字段做出各种不同效果，比如语音消息是否已经播放等等。另外需要注意，此自定义字段仅存储于本地，不会同步到Server，更换终端获取不到。
*/
// Struct Message JsonKey
static const char* kTIMMsgElemArray   = "message_elem_array";    //array [Elem](), 读写(必填), 消息内元素列表
static const char* kTIMMsgConvId      = "message_conv_id";       //string,         读写(选填),       消息所属会话ID
static const char* kTIMMsgConvType    = "message_conv_type";     //uint [TIMConvType](), 读写(选填), 消息所属会话类型
static const char* kTIMMsgSender      = "message_sender";        //string,         读写(选填),       消息的发送者
static const char* kTIMMsgPriority    = "message_priority";      //uint [TIMMsgPriority](), 读写(选填), 消息优先级
static const char* kTIMMsgClientTime  = "message_client_time";   //uint64,         读写(选填),       客户端时间
static const char* kTIMMsgServerTime  = "message_server_time";   //uint64,         读写(选填),       服务端时间
static const char* kTIMMsgIsFormSelf  = "message_is_from_self";  //bool,           读写(选填),       消息是否来自自己
static const char* kTIMMsgIsRead      = "message_is_read";       //bool,           读写(选填),       消息是否已读
static const char* kTIMMsgIsOnlineMsg = "message_is_online_msg"; //bool,           读写(选填),       消息是否是在线消息，默认为false表示普通消息,true表示阅后即焚消息
static const char* kTIMMsgIsPeerRead  = "message_is_peer_read";  //bool,           只读,            消息是否被会话对方已读
static const char* kTIMMsgStatus      = "message_status";        //uint [TIMMsgStatus](), 读写(选填), 消息当前状态
static const char* kTIMMsgUniqueId    = "message_unique_id";     //uint64,         只读,       消息的唯一标识
static const char* kTIMMsgRand        = "message_rand";          //uint64,         只读,       消息的随机码
static const char* kTIMMsgSeq         = "message_seq";           //uint64,         只读,       消息序列
static const char* kTIMMsgCustomInt   = "message_custom_int";    //uint32_t,       读写(选填), 自定义整数值字段
static const char* kTIMMsgCustomStr   = "message_custom_str";    //string,         读写(选填), 自定义数据字段
// EndStruct

/**
* @brief 消息已读回执
*/
// Struct MessageReceipt JsonKey
static const char* kTIMMsgReceiptConvId    = "msg_receipt_conv_id";     //string, 只读, 会话ID
static const char* kTIMMsgReceiptConvType  = "msg_receipt_conv_type";   //uint [TIMConvType](), 只读, 会话类型
static const char* kTIMMsgReceiptTimeStamp = "msg_receipt_time_stamp";  //uint64, 只读, 时间戳
// EndStruct

/**
* @brief 元素的类型
*/
enum TIMElemType {
    kTIMElem_Text,           // 文本元素
    kTIMElem_Image,          // 图片元素
    kTIMElem_Sound,          // 声音元素
    kTIMElem_Custom,         // 自定义元素
    kTIMElem_File,           // 文件元素
    kTIMElem_GroupTips,      // 群组系统消息元素
    kTIMElem_Face,           // 表情元素
    kTIMElem_Location,       // 位置元素
    kTIMElem_GroupReport,    // 群组系统通知元素
    kTIMElem_Video,          // 视频元素
};

/**
* @brief 元素的类型
*/
// Struct Elem JsonKey
static const char* kTIMElemType         = "elem_type";    // uint [TIMElemType](), 读写(必填), 元素类型
// EndStruct

/**
* @brief 文本元素
*/
// Struct TextElem JsonKey
static const char* kTIMTextElemContent  = "text_elem_content"; // string, 读写(必填), 文本内容
// EndStruct

/**
* @brief 表情元素
*
* @note 
* ImSDK并不提供表情包，如果开发者有表情包，可使用 kTIMFaceElemIndex 存储表情在表情包中的索引，由用户自定义。
* 或者直接使用 kTIMFaceElemBuf 存储表情二进制信息(必须转换成String，Json不支持二进制传输)，由用户自定义，ImSDK内部只做透传。
*/
// Struct FaceElem JsonKey
static const char* kTIMFaceElemIndex          = "face_elem_index";  // int,    读写(必填), 表情索引
static const char* kTIMFaceElemBuf            = "face_elem_buf";    // string, 读写(选填), 其他额外数据,可由用户自定义填写。若要传输二进制，麻烦先转码成字符串。Json只支持字符串
// EndStruct

/**
* @brief 位置元素
*/
// Struct LocationElem JsonKey
static const char* kTIMLocationElemDesc       = "location_elem_desc";          // string, 读写(选填), 位置描述
static const char* kTIMLocationElemLongitude  = "location_elem_longitude";     // double, 读写(必填), 经度
static const char* kTIMLocationElemlatitude   = "location_elem_latitude";      // double, 读写(必填), 纬度
// EndStruct


/**
* @brief 图片质量级别
*/
enum TIMImageLevel {
    kTIMImageLevel_Orig,        // 原图发送
    kTIMImageLevel_Compression, // 高压缩率图发送(图片较小,默认值)
    kTIMImageLevel_HD,          // 高清图发送(图片较大)
};

/**
* @brief 图片元素
*
* @note
* >  图片规格说明：每幅图片有三种规格，分别是Original（原图）、Large（大图）、Thumb（缩略图）。
* >> 原图：指用户发送的原始图片，尺寸和大小都保持不变。
* >> 大图：是将原图等比压缩，压缩后宽、高中较小的一个等于720像素。
* >> 缩略图：是将原图等比压缩，压缩后宽、高中较小的一个等于198像素
* >  如果原图尺寸就小于198像素，则三种规格都保持原始尺寸，不需压缩。
* >  如果原图尺寸在198-720之间，则大图和原图一样，不需压缩。
* >  在手机上展示图片时，建议优先展示缩略图，用户单击缩略图时再下载大图，单击大图时再下载原图。当然开发者也可以选择跳过大图，单击缩略图时直接下载原图。
* >  在Pad或PC上展示图片时，由于分辨率较大，且基本都是Wi-Fi或有线网络，建议直接显示大图，用户单击大图时再下载原图。
*/
// Struct ImageElem JsonKey
static const char* kTIMImageElemOrigPath        = "image_elem_orig_path";        // string, 读写(必填), 发送图片的路径
static const char* kTIMImageElemLevel           = "image_elem_level";            // uint[TIMImageLevel](), 读写(必填), 发送图片的质量级别
static const char* kTIMImageElemFormat          = "image_elem_format";           // int,    读写(必填), 发送图片格式
static const char* kTIMImageElemOrigId          = "image_elem_orig_id";          // string, 只读,       原图的uuid
static const char* kTIMImageElemOrigPicHeight   = "image_elem_orig_pic_height";  // int,    只读,       原图的图片高度
static const char* kTIMImageElemOrigPicWidth    = "image_elem_orig_pic_width";   // int,    只读,       原图的图片高度
static const char* kTIMImageElemOrigPicSize     = "image_elem_orig_pic_size";    // int,    只读,       原图的图片高度
static const char* kTIMImageElemThumbId         = "image_elem_thumb_id";         // string, 只读,       略缩图uuid
static const char* kTIMImageElemThumbPicHeight  = "image_elem_thumb_pic_height"; // int,    只读,       略缩图的图片高度
static const char* kTIMImageElemThumbPicWidth   = "image_elem_thumb_pic_width";  // int,    只读,       略缩图的图片高度
static const char* kTIMImageElemThumbPicSize    = "image_elem_thumb_pic_size";   // int,    只读,       略缩图的图片高度
static const char* kTIMImageElemLargeId         = "image_elem_large_id";         // string, 只读,       大图片uuid
static const char* kTIMImageElemLargePicHeight  = "image_elem_large_pic_height"; // int,    只读,       大图片的图片高度
static const char* kTIMImageElemLargePicWidth   = "image_elem_large_pic_width";  // int,    只读,       大图片的图片高度
static const char* kTIMImageElemLargePicSize    = "image_elem_large_pic_size";   // int,    只读,       大图片的图片高度
static const char* kTIMImageElemOrigUrl         = "image_elem_orig_url";         // string, 只读,       原图URL
static const char* kTIMImageElemThumbUrl        = "image_elem_thumb_url";        // string, 只读,       略缩图URL
static const char* kTIMImageElemLargeUrl        = "image_elem_large_url";        // string, 只读,       大图片URL
static const char* kTIMImageElemTaskId          = "image_elem_task_id";          // int,    只读,       任务ID
// EndStruct

/**
* @brief 声音元素
*
* @note
* > 语音是否已经播放，可使用 消息自定义字段 实现，如定义一个字段值0表示未播放，1表示播放，当用户单击播放后可设置改字段的值为1
* > 一条消息只能添加一个声音元素，添加多个声音元素时，发送消息可能失败。
*/
// Struct SoundElem JsonKey
static const char* kTIMSoundElemFilePath        = "sound_elem_file_path";        // string, 读写(必填), 语音文件路径,需要开发者自己先保存语言然后指定路径
static const char* kTIMSoundElemFileSize        = "sound_elem_file_size";        // int,    读写(必填), 语言数据文件大小，以秒为单位
static const char* kTIMSoundElemFileTime        = "sound_elem_file_time";        // int,    读写(必填), 语音时长
static const char* kTIMSoundElemFileId          = "sound_elem_file_id";          // string, 只读,       下载声音文件时的ID
static const char* kTIMSoundElemBusinessId      = "sound_elem_business_id";      // int,    只读,       下载时用到的businessID
static const char* kTIMSoundElemDownloadFlag    = "sound_elem_download_flag";    // int,    只读,       是否需要申请下载地址(0:到架平申请，1:到cos申请，2:不需要申请,直接拿url下载)
static const char* kTIMSoundElemUrl             = "sound_elem_url";              // string, 只读,       下载的URL
static const char* kTIMSoundElemTaskId          = "sound_elem_task_id";          // int,    只读,       任务ID
// EndStruct

/**
* @brief 自定义元素
*
* @note
* 自定义消息是指当内置的消息类型无法满足特殊需求，开发者可以自定义消息格式，内容全部由开发者定义，ImSDK只负责透传。
*/
// Struct CustomElem JsonKey
static const char* kTIMCustomElemData   = "custom_elem_data";   // string,  读写, 数据,支持二进制数据
static const char* kTIMCustomElemDesc   = "custom_elem_desc";   // string,  读写, 自定义描述
static const char* kTIMCustomElemExt    = "custom_elem_ext";    // string,  读写, 后台推送对应的ext字段
static const char* kTIMCustomElemSound  = "custom_elem_sound";  // string,  读写, 自定义声音,这个声音是给谁听的
// EndStruct

/**
* @brief 文件元素
*
* @note
* 一条消息只能添加一个文件元素，添加多个文件时，发送消息可能失败。
*/
// Struct FileElem JsonKey
static const char* kTIMFileElemFilePath      = "file_elem_file_path";      // string,   读写(必填), 文件所在路径（包含文件名）
static const char* kTIMFileElemFileName      = "file_elem_file_name";      // string,   读写(选填), 文件名，显示的名称
static const char* kTIMFileElemFileSize      = "file_elem_file_size";      // int,      读写(必填),  文件大小
static const char* kTIMFileElemFileId        = "file_elem_file_id";        // string,   只读, 下载视频时的uuid
static const char* kTIMFileElemBusinessId    = "file_elem_business_id";    // int,      只读, 下载时用到的businessID
static const char* kTIMFileElemDownloadFlag  = "file_elem_download_flag";  // int,      只读, 文件下载flag
static const char* kTIMFileElemUrl           = "file_elem_url";            // string,   只读, 文件下载的URL
static const char* kTIMFileElemTaskId        = "file_elem_task_id";        // int,      只读, 任务ID 
// EndStruct

/**
* @brief 视频元素
*/
// Struct VideoElem JsonKey
static const char* kTIMVideoElemVideoType          = "video_elem_video_type";           // string, 读写(必填), 视频文件类型，发送消息时进行设置
static const char* kTIMVideoElemVideoSize          = "video_elem_video_size";           // uint,   读写(必填), 视频文件大小
static const char* kTIMVideoElemVideoDuration      = "video_elem_video_duration";       // uint,   读写(必填), 视频时长，发送消息时进行设置
static const char* kTIMVideoElemVideoPath          = "video_elem_video_path";           // string, 读写(必填), 适配文件路径 
static const char* kTIMVideoElemVideoId            = "video_elem_video_id";             // string, 只读, 下载视频时的uuid
static const char* kTIMVideoElemBusinessId         = "video_elem_business_id";          // int,    只读, 下载时用到的businessID
static const char* kTIMVideoElemVideoDownloadFlag  = "video_elem_video_download_flag";  // int,    只读, 视频文件下载flag 
static const char* kTIMVideoElemVideoUrl           = "video_elem_video_url";            // string, 只读, 视频文件下载的URL 
static const char* kTIMVideoElemImageType          = "video_elem_image_type";           // string, 读写(必填), 截图文件类型，发送消息时进行设置
static const char* kTIMVideoElemImageSize          = "video_elem_image_size";           // uint,   读写(必填), 截图文件大小
static const char* kTIMVideoElemImageWidth         = "video_elem_image_width";          // uint,   读写(必填), 截图高度，发送消息时进行设置
static const char* kTIMVideoElemImageHeight        = "video_elem_image_height";         // uint,   读写(必填), 截图宽度，发送消息时进行设置
static const char* kTIMVideoElemImagePath          = "video_elem_image_path";           // string, 读写(必填), 保存截图的路径
static const char* kTIMVideoElemImageId            = "video_elem_image_id";             // string, 只读, 下载视频截图时的ID
static const char* kTIMVideoElemImageDownloadFlag  = "video_elem_image_download_flag";  // int,    只读, 截图文件下载flag 
static const char* kTIMVideoElemImageUrl           = "video_elem_image_url";            // string, 只读, 截图文件下载的URL 
static const char* kTIMVideoElemTaskId             = "video_elem_task_id";              // uint,   只读, 任务ID
// EndStruct

/**
* @brief 群组信息修改的类型
*/
enum TIMGroupTipGroupChangeFlag {
    kTIMGroupTipChangeFlag_Name = 0xa,   // 修改群组名称
    kTIMGroupTipChangeFlag_Introduction, // 修改群简介
    kTIMGroupTipChangeFlag_Notification, // 修改群公告
    kTIMGroupTipChangeFlag_FaceUrl,      // 修改群头像URL
    kTIMGroupTipChangeFlag_Owner,        // 修改群所有者
};

/**
* @brief 群组系统消息-群组信息修改
*/
// Struct GroupTipGroupChangeInfo JsonKey
static const char* kTIMGroupTipGroupChangeInfoFlag        = "group_tips_group_change_info_flag";         // uint [TIMGroupTipGroupChangeFlag](), 只读, 群消息修改群信息标志
static const char* kTIMGroupTipGroupChangeInfoValue       = "group_tips_group_change_info_value";        // string, 只读, 修改的后值,不同的 info_flag 字段,具有不同的含义
// EndStruct

/**
* @brief 群组系统消息-群组成员禁言
*/
// Struct GroupTipMemberChangeInfo JsonKey
static const char* kTIMGroupTipMemberChangeInfoIdentifier  = "group_tips_member_change_info_identifier";     // string, 只读, 群组成员ID
static const char* kTIMGroupTipMemberChangeInfoShutupTime  = "group_tips_member_change_info_shutupTime";     // uint,   只读, 禁言时间
// EndStruct

/**
* @brief 用户个人资料
*/
// Struct UserProfile JsonKey
static const char* kTIMUserProfileIdentifier    = "user_profile_identifier";      // string, 只读, 用户ID
static const char* kTIMUserProfileNickName      = "user_profile_nick_name";       // string, 只读, 用户的昵称
static const char* kTIMUserProfileFaceURL       = "user_profile_face_url";        // string, 只读, 用户头像URL
static const char* kTIMUserProfileSelfSignature = "user_profile_self_signature";  // string, 只读, 用户个人签名
static const char* kTIMUserProfileRemark        = "user_profile_remark";          // string, 只读, 用户备注
// EndStruct

/**
* @brief 群组系统消息类型
*/
enum TIMGroupTipType {
    kTIMGroupTip_None,              // 无效的群提示
    kTIMGroupTip_Invite,            // 邀请加入提示
    kTIMGroupTip_Quit,              // 退群提示
    kTIMGroupTip_Kick,              // 踢人提示
    kTIMGroupTip_SetAdmin,          // 设置管理员提示
    kTIMGroupTip_CancelAdmin,       // 取消管理员提示
    kTIMGroupTip_GroupInfoChange,   // 群信息修改提示
    kTIMGroupTip_MemberInfoChange,  // 群成员信息修改提示
};

/**
* @brief 群组系统消息元素(针对所有群成员)
*/
// Struct GroupTipsElem JsonKey
static const char* kTIMGroupTipsElemTipType                     = "group_tips_elem_tip_type";                       // uint [TIMGroupTipType](), 只读, 群消息类型
static const char* kTIMGroupTipsElemOpUser                      = "group_tips_elem_op_user";                        // string,   只读, 操作者ID
static const char* kTIMGroupTipsElemGroupName                   = "group_tips_elem_group_name";                     // string,   只读, 群组名称
static const char* kTIMGroupTipsElemGroupId                     = "group_tips_elem_group_id";                       // string,   只读, 群组ID
static const char* kTIMGroupTipsElemTime                        = "group_tips_elem_time";                           // uint,     只读, 群消息时间
static const char* kTIMGroupTipsElemUserArray                   = "group_tips_elem_user_array";                     // array string, 只读, 被操作的帐号列表
static const char* kTIMGroupTipsElemGroupChangeInfoArray        = "group_tips_elem_group_change_info_array";        // array [GroupTipGroupChangeInfo](),  只读, 群资料变更信息列表,仅当 tips_type 值为 kTIMGroupTip_GroupInfoChange 时有效
static const char* kTIMGroupTipsElemMemberChangeInfoArray       = "group_tips_elem_member_change_info_array";       // array [GroupTipMemberChangeInfo](), 只读, 群成员变更信息列表,仅当 tips_type 值为 kTIMGroupTip_MemberInfoChange 时有效
static const char* kTIMGroupTipsElemOpUserInfo                  = "group_tips_elem_op_user_info";                   // object [UserProfile](),              只读, 操作者个人资料
static const char* kTIMGroupTipsElemOpGroupMemberInfo           = "group_tips_elem_op_group_memberinfo";            // object [GroupMemberInfo](),          只读, 群成员信息
static const char* kTIMGroupTipsElemChangedUserInfoArray        = "group_tips_elem_changed_user_info_array";        // array [UserProfile](),               只读, 被操作者列表资料
static const char* kTIMGroupTipsElemChangedGroupMemberInfoArray = "group_tips_elem_changed_group_memberinfo_array"; // array [GroupMemberInfo](),       只读, 群成员信息列表
static const char* kTIMGroupTipsElemMemberNum                   = "group_tips_elem_member_num";                     // uint,   只读, 当前群成员数,只有当事件消息类型为 kTIMGroupTip_Invite 、 kTIMGroupTip_Quit 、 kTIMGroupTip_Kick 时有效
static const char* kTIMGroupTipsElemPlatform                    = "group_tips_elem_platform";                       // string, 只读, 操作方平台信息
// EndStruct

/**
* @brief 群组系统通知类型
*/
enum TIMGroupReportType {
    kTIMGroupReport_None,         // 未知类型
    kTIMGroupReport_AddRequest,   // 申请加群(只有管理员会接收到)
    kTIMGroupReport_AddAccept,    // 申请加群被同意(只有申请人自己接收到)
    kTIMGroupReport_AddRefuse,    // 申请加群被拒绝(只有申请人自己接收到)
    kTIMGroupReport_BeKicked,     // 被管理员踢出群(只有被踢者接收到)
    kTIMGroupReport_Delete,       // 群被解散(全员接收)
    kTIMGroupReport_Create,       // 创建群(创建者接收, 不展示)
    kTIMGroupReport_Invite,       // 邀请加群(被邀请者接收)
    kTIMGroupReport_Quit,         // 主动退群(主动退出者接收, 不展示)
    kTIMGroupReport_GrantAdmin,   // 设置管理员(被设置者接收)
    kTIMGroupReport_CancelAdmin,  // 取消管理员(被取消者接收)
    kTIMGroupReport_RevokeAdmin,  // 群已被回收(全员接收, 不展示)
    kTIMGroupReport_InviteReq,    // 邀请加群(只有被邀请者会接收到)
    kTIMGroupReport_InviteAccept, // 邀请加群被同意(只有发出邀请者会接收到)
    kTIMGroupReport_InviteRefuse, // 邀请加群被拒绝(只有发出邀请者会接收到)
    kTIMGroupReport_ReadedSync,   // 已读上报多终端同步通知(只有上报人自己收到)
    kTIMGroupReport_UserDefine,   // 用户自定义通知(默认全员接收)
};

/**
* @brief 群组系统通知元素(针对个人)
*/
// Struct GroupReportElem JsonKey
static const char* kTIMGroupReportElemReportType        = "group_report_elem_report_type";          // uint [TIMGroupReportType](), 只读, 类型
static const char* kTIMGroupReportElemGroupId           = "group_report_elem_group_id";             // string, 只读, 群组ID
static const char* kTIMGroupReportElemGroupName         = "group_report_elem_group_name";           // string, 只读, 群组名称
static const char* kTIMGroupReportElemOpUser            = "group_report_elem_op_user";              // string, 只读, 操作者ID
static const char* kTIMGroupReportElemMsg               = "group_report_elem_msg";                  // string, 只读, 操作理由
static const char* kTIMGroupReportElemUserData          = "group_report_elem_user_data";            // string, 只读, 操作者填的自定义数据
static const char* kTIMGroupReportElemOpUserInfo        = "group_report_elem_op_user_info";         // object [UserProfile](), 只读, 操作者个人资料
static const char* kTIMGroupReportElemOpGroupMemberInfo = "group_report_elem_op_group_memberinfo";  // object [GroupMemberInfo](), 只读,操作者群内资料
static const char* kTIMGroupReportElemPlatform          = "group_report_elem_platform";             // string, 只读, 操作方平台信息
// EndStruct

/**
* @brief 消息群发接口的参数
*/
// Struct MsgBatchSendParam JsonKey
static const char* kTIMMsgBatchSendParamIdentifierArray = "msg_batch_send_param_identifier_array"; // array string,       只写(必填), 群发的ID列表
static const char* kTIMMsgBatchSendParamMsg             = "msg_batch_send_param_msg";              // object [Message](), 只写(必填), 群发的消息
// EndStruct

/**
* @brief 消息群发接口的返回
*/
// Struct MsgBatchSendResult JsonKey
static const char* kTIMMsgBatchSendResultIdentifier = "msg_batch_send_result_identifier";  // string, 只读, 群发的单个ID
static const char* kTIMMsgBatchSendResultCode       = "msg_batch_send_result_code";        // int [错误码](https://cloud.tencent.com/document/product/269/1671), 只读, 消息发送结果
static const char* kTIMMsgBatchSendResultDesc       = "msg_batch_send_result_desc";        // string, 只读, 消息发送的描述
static const char* kTIMMsgBatchSendResultMsg        = "msg_batch_send_result_msg";         // object [Message](), 只读, 发送的消息
// EndStruct

/**
* @brief 消息定位符
*/
// Struct MsgLocator JsonKey
static const char* kTIMMsgLocatorConvId    = "message_locator_conv_id";    // bool,   读写,       要查找的消息是否是被撤回。true被撤回的，false非撤回的。默认值为false
static const char* kTIMMsgLocatorConvType  = "message_locator_conv_type";  // bool,   读写,       要查找的消息是否是被撤回。true被撤回的，false非撤回的。默认值为false
static const char* kTIMMsgLocatorIsRevoked = "message_locator_is_revoked"; // bool,   读写(必填), 要查找的消息是否是被撤回。true被撤回的，false非撤回的。默认值为false
static const char* kTIMMsgLocatorTime      = "message_locator_time";       // uint64, 读写(必填), 要查找的消息的时间戳
static const char* kTIMMsgLocatorSeq       = "message_locator_seq";        // uint64, 读写(必填), 要查找的消息的序列号
static const char* kTIMMsgLocatorIsSelf    = "message_locator_is_self";    // bool,   读写(必填), 要查找的消息的发送者是否是自己。true发送者是自己，false发送者不是自己。默认值为false
static const char* kTIMMsgLocatorRand      = "message_locator_rand";       // uint64, 读写(必填), 要查找的消息随机码
// EndStruct


/**
* @brief 消息获取接口的参数
*/
// Struct MsgGetMsgListParam JsonKey
static const char* kTIMMsgGetMsgListParamLastMsg   = "msg_getmsglist_param_last_msg";   // object [Message](), 只写(选填), 指定的消息，不允许为null
static const char* kTIMMsgGetMsgListParamCount     = "msg_getmsglist_param_count";      // uint,               只写(选填), 从指定消息往后的消息数
static const char* kTIMMsgGetMsgListParamIsRamble  = "msg_getmsglist_param_is_remble";  // bool,               只写(选填), 是否漫游消息
static const char* kTIMMsgGetMsgListParamIsForward = "msg_getmsglist_param_is_forward"; // bool,               只写(选填), 是否向前排序
// EndStruct



/**
* @brief 消息删除接口的参数
*/
// Struct MsgDeleteParam JsonKey
static const char* kTIMMsgDeleteParamMsg       = "msg_delete_param_msg";        // object [Message](), 只写(选填), 指定在会话中要删除的消息
static const char* kTIMMsgDeleteParamIsRamble  = "msg_delete_param_is_remble";  // bool, 只写(选填), 是否删除本地/漫游所有消息。true删除漫游消息，false删除本地消息，默认值false
// EndStruct

/**
* @brief UUID类型
*/
enum TIMDownloadType {
    kTIMDownload_VideoThumb = 0, // 视频缩略图
    kTIMDownload_File,           // 文件
    kTIMDownload_Video,          // 视频
    kTIMDownload_Sound,          // 声音
};

/**
* @brief 下载元素接口的参数
*/
// Struct DownloadElemParam JsonKey
static const char* kTIMMsgDownloadElemParamFlag       = "msg_download_elem_param_flag";         // uint,   只写, 从消息元素里面取出来,元素的下载类型
static const char* kTIMMsgDownloadElemParamType       = "msg_download_elem_param_type";         // uint [TIMDownladType](), 只写, 从消息元素里面取出来,元素的类型
static const char* kTIMMsgDownloadElemParamId         = "msg_download_elem_param_id";           // string, 只写, 从消息元素里面取出来,元素的ID
static const char* kTIMMsgDownloadElemParamBusinessId = "msg_download_elem_param_business_id";  // uint,   只写, 从消息元素里面取出来,元素的BusinessID
static const char* kTIMMsgDownloadElemParamUrl        = "msg_download_elem_param_url";          // string, 只写, 从消息元素里面取出来,元素URL
// EndStruct

/**
* @brief 下载元素接口的返回
*/
// Struct MsgDownloadElemResult JsonKey
static const char* kTIMMsgDownloadElemResultCurrentSize = "msg_download_elem_result_current_size";       // uint, 只读, 当前已下载的大小
static const char* kTIMMsgDownloadElemResultTotalSize   = "msg_download_elem_result_total_size";         // uint, 只读, 需要下载的文件总大小
// EndStruct

/// @}


/// @name 会话关键类型
/// @brief 会话相关宏定义，以及相关结构成员存取Json Key定义
/// @{
/**
* @brief 草稿信息
*/
// Struct Draft JsonKey
static const char* kTIMDraftMsg              = "draft_msg";         // object [Message](), 只读, 草稿内的消息
static const char* kTIMDraftUserDefine       = "draft_user_define"; // string, 只读, 用户自定义数据
static const char* kTIMDraftEditTime         = "draft_edit_time";   // uint, 只读, 草稿最新编辑时间
// EndStruct

/**
* @brief 草稿信息
*/
// Struct ConvInfo JsonKey
static const char* kTIMConvId           = "conv_id";             // string, 只读, 会话ID
static const char* kTIMConvType         = "conv_type";           // uint [TIMConvType](), 只读, 会话类型
static const char* kTIMConvOwner        = "conv_owner";          // string, 只读, 会话所有者
static const char* kTIMConvUnReadNum    = "conv_unread_num";     // uint64, 只读, 会话未读计数
static const char* kTIMConvActiveTime   = "conv_active_time";    // uint64, 只读, 会话的激活时间
static const char* kTIMConvIsHasLastMsg = "conv_is_has_lastmsg"; // bool, 只读, 会话是否有最后一条消息
static const char* kTIMConvLastMsg      = "conv_last_msg";       // object [Message](), 只读, 会话最后一条消息
static const char* kTIMConvIsHasDraft   = "conv_is_has_draft";   // bool, 只读, 会话草稿
static const char* kTIMConvDraft        = "conv_draft";          // object [Draft](), 只读(选填), 会话草稿
// EndStruct
/// @}

/// @name 群组关键类型
/// @brief 群组相关宏定义，以及相关结构成员存取Json Key定义
/// @{
/**
* @brief 群组加群选项
*/
enum TIMGroupAddOption {
    kTIMGroupAddOpt_Forbid = 0,  // 禁止加群
    kTIMGroupAddOpt_Auth = 1,    // 需要管理员审批
    kTIMGroupAddOpt_Any = 2,     // 任何人都可以加群
};

/**
* @brief 群组类型
*/
enum TIMGroupType {
    kTIMGroup_Public,     // 公开群
    kTIMGroup_Private,    // 私有群
    kTIMGroup_ChatRoom,   // 聊天室
    kTIMGroup_BChatRoom,  // 在线成员广播大群
    kTIMGroup_AVChatRoom, // 互动直播聊天室
};

/**
* @brief 群组成员角色类型
*/
enum TIMGroupMemberRole {
    kTIMMemberRole_Normal,     // 群成员
    kTIMMemberRole_Admin,      // 管理员
    kTIMMemberRole_SuperAdmin, // 超级管理员
};

/**
* @brief 群组成员信息
*/
// Struct GroupMemberInfo JsonKey
static const char* kTIMGroupMemberInfoIdentifier = "group_member_info_identifier";   // string, 读写(必填), 群组成员ID
static const char* kTIMGroupMemberInfoJoinTime   = "group_member_info_join_time";    // uint,  只读, 群组成员加入时间
static const char* kTIMGroupMemberInfoMemberRole = "group_member_info_member_role";  // uint [TIMGroupMemberRole](), 读写(选填), 群组成员角色
static const char* kTIMGroupMemberInfoMsgFlag    = "group_member_info_msg_flag";     // uint,  只读, 成员接收消息的选项
static const char* kTIMGroupMemberInfoMsgSeq     = "group_member_info_msg_seq";      // uint,  只读, 
static const char* kTIMGroupMemberInfoShutupTime = "group_member_info_shutup_time";  // uint,  只读, 成员禁言时间
static const char* kTIMGroupMemberInfoNameCard   = "group_member_info_name_card";    // string, 只读, 成员群名片
static const char* kTIMGroupMemberInfoCustomInfo = "group_member_info_custom_info";  // object key string value string, 只读, 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct

/**
* @brief 创建群组接口的参数
*/
// Struct CreateGroupParam JsonKey
static const char* kTIMCreateGroupParamGroupName        = "create_group_param_group_name";          //string, 只写(必填), 群组名称
static const char* kTIMCreateGroupParamGroupId          = "create_group_param_group_id";            //string, 只写(选填), 群组ID,不填时创建成功回调会返回一个后台分配的群ID
static const char* kTIMCreateGroupParamGroupType        = "create_group_param_group_type";          //uint[TIMGroupType](), 只写(选填), 群组类型,默认为Public
static const char* kTIMCreateGroupParamGroupMemberArray = "create_group_param_group_member_array";  //array [GroupMemberInfo](), 只写(选填), 群组初始成员数组
static const char* kTIMCreateGroupParamNotification     = "create_group_param_notification";        //string, 只写(选填), 群组公告,
static const char* kTIMCreateGroupParamIntroduction     = "create_group_param_introduction";        //string, 只写(选填), 群组简介,
static const char* kTIMCreateGroupParamFaceUrl          = "create_group_param_face_url";            //string, 只写(选填), 群组头像URL
static const char* kTIMCreateGroupParamAddOption        = "create_group_param_add_option";          //uint [TIMGroupAddOption](),   只写(选填), 加群选项，默认为Any
static const char* kTIMCreateGroupParamMaxMemberCount   = "create_group_param_max_member_num";      //uint,   只写(选填), 群组最大成员数
static const char* kTIMCreateGroupParamCustomInfo       = "create_group_param_custom_info";         //object key string value string, 只读(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct

/**
* @brief 创建群组接口的返回
*/
// Struct CreateGroupResult JsonKey
static const char* kTIMCreateGroupResultGroupId         = "create_group_result_groupid"; // string, 只读, 创建的群ID
// EndStruct

/**
* @brief 邀请成员接口的参数
*/
// Struct GroupInviteMemberParam JsonKey
static const char* kTIMGroupInviteMemberParamGroupId         = "group_invite_member_param_group_id";         // string, 只写(必填), 群组ID
static const char* kTIMGroupInviteMemberParamIdentifierArray = "group_invite_member_param_identifier_array"; // array string, 只写(必填), 被邀请加入群组用户ID数组
static const char* kTIMGroupInviteMemberParamUserData        = "group_invite_member_param_user_data";        // string, 只写(选填), 用于自定义数据
// EndStruct


/**
* @brief 群组基础信息
*/
enum HandleGroupMemberResult {
    kTIMGroupMember_HandledErr, // 失败
    kTIMGroupMember_HandledSuc, // 成功
    kTIMGroupMember_Included,   // 已是群成员
    kTIMGroupMember_Invited,    // 已发送邀请
};


/**
* @brief 邀请成员接口的返回
*/
// Struct GroupInviteMemberResult JsonKey
static const char* kTIMGroupInviteMemberResultIdentifier = "group_invite_member_result_identifier"; // string, 只读, 被邀请加入群组的用户ID
static const char* kTIMGroupInviteMemberResultResult     = "group_invite_member_result_result";     // uint [HandleGroupMemberResult](), 只读, 邀请结果
// EndStruct

/**
* @brief 删除成员接口的参数
*/
// Struct GroupDeleteMemberParam JsonKey
static const char* kTIMGroupDeleteMemberParamGroupId         = "group_delete_member_param_group_id";          // string, 只写(必填), 群组ID
static const char* kTIMGroupDeleteMemberParamIdentifierArray = "group_delete_member_param_identifier_array";  // array string, 只写(必填), 被删除群组成员数组
static const char* kTIMGroupDeleteMemberParamUserData        = "group_delete_member_param_user_data";         // string, 只写(选填), 用于自定义数据
// EndStruct

/**
* @brief 删除成员接口的返回
*/
// Struct GroupDeleteMemberResult JsonKey
static const char* kTIMGroupDeleteMemberResultIdentifier  = "group_delete_member_result_identifier"; // string, 只读, 删除的成员ID
static const char* kTIMGroupDeleteMemberResultResult      = "group_delete_member_result_result";     // uint [HandleGroupMemberResult](), 只读, 删除结果
// EndStruct


/**
* @brief 群组消息接收选项
*/    
enum TIMGroupReceiveMessageOpt {
    kTIMRecvGroupMsgOpt_ReceiveAndNotify,  // 接收群消息 并提示
    kTIMRecvGroupMsgOpt_NotReceive,        // 不接收群消息, 服务器不会进行转发
    kTIMRecvGroupMsgOpt_ReceiveNotNotify,  // 接收群消息,不提示
};

/**
* @brief 群组内本人的信息
*/
// Struct GroupSelfInfo JsonKey
static const char* kTIMGroupSelfInfoJoinTime   = "group_self_info_join_time";   // uint, 只读, 加入群组时间
static const char* kTIMGroupSelfInfoRole       = "group_self_info_role";        // uint, 只读, 用户在群组中的角色
static const char* kTIMGroupSelfInfoUnReadNum  = "group_self_info_unread_num";  // uint, 只读, 消息未读计数
static const char* kTIMGroupSelfInfoMsgFlag    = "group_self_info_msg_flag";    // uint [TIMGroupReceiveMessageOpt](), 只读, 群消息接收选项
// EndStruct

/**
* @brief 获取已加入群组列表接口的返回(群组基础信息)
*/
// Struct GroupBaseInfo JsonKey
static const char* kTIMGroupBaseInfoGroupId      = "group_base_info_group_id";       // string, 只读, 群组ID
static const char* kTIMGroupBaseInfoGroupName    = "group_base_info_group_name";     // string, 只读, 群组名称
static const char* kTIMGroupBaseInfoGroupType    = "group_base_info_group_type";     // string [TIMGroupType](), 只读, 群组类型
static const char* kTIMGroupBaseInfoFaceUrl      = "group_base_info_face_url";       // string, 只读, 群组头像URL
static const char* kTIMGroupBaseInfoInfoSeq      = "group_base_info_info_seq";       // uint,   只读, 
static const char* kTIMGroupBaseInfoLastestSeq   = "group_base_info_lastest_seq";    // uint,   只读, 
static const char* kTIMGroupBaseInfoReadedSeq    = "group_base_info_readed_seq";     // uint,   只读, 
static const char* kTIMGroupBaseInfoMsgFlag      = "group_base_info_msg_flag";       // uint,   只读, 
static const char* kTIMGroupBaseInfoIsShutupAll  = "group_base_info_is_shutup_all";   // bool,   只读, 当前群组是否设置了全员禁言
static const char* kTIMGroupBaseInfoSelfInfo     = "group_base_info_self_info";      // object [GroupSelfInfo](), 只读, 用户所在群的个人信息
// EndStruct

/**
* @brief 群组详细信息
*/
// Struct GroupDetailInfo JsonKey
static const char* kTIMGroupDetialInfoGroupId          = "group_detial_info_group_id";           // string, 只读, 群组ID
static const char* kTIMGroupDetialInfoGroupType        = "group_detial_info_group_type";         // uint [TIMGroupType](), 只读, 群组类型
static const char* kTIMGroupDetialInfoGroupName        = "group_detial_info_group_name";         // string, 只读, 群组名称
static const char* kTIMGroupDetialInfoNotification     = "group_detial_info_notification";       // string, 只读, 群组公告
static const char* kTIMGroupDetialInfoIntroduction     = "group_detial_info_introduction";       // string, 只读, 群组简介
static const char* kTIMGroupDetialInfoFaceUrl          = "group_detial_info_face_url";           // string, 只读, 群组头像URL
static const char* kTIMGroupDetialInfoCreateTime       = "group_detial_info_create_time";        // uint,   只读, 群组创建时间
static const char* kTIMGroupDetialInfoInfoSeq          = "group_detial_info_info_seq";           // uint,   只读, 
static const char* kTIMGroupDetialInfoLastInfoTime     = "group_detial_info_last_info_time";     // uint,   只读, 群组信息最后修改时间
static const char* kTIMGroupDetialInfoNextMsgSeq       = "group_detial_info_next_msg_seq";       // uint,   只读,
static const char* kTIMGroupDetialInfoLastMsgTime      = "group_detial_info_last_msg_time";      // uint,   只读, 最新群组消息时间
static const char* kTIMGroupDetialInfoMemberNum        = "group_detial_info_member_num";         // uint,   只读, 群组当前成员数量
static const char* kTIMGroupDetialInfoMaxMemberNum     = "group_detial_info_max_member_num";     // uint,   只读, 群组最大成员数量
static const char* kTIMGroupDetialInfoAddOption        = "group_detial_info_add_option";         // uint [TIMGroupAddOption](), 只读, 群组加群选项
static const char* kTIMGroupDetialInfoOnlineMemberNum  = "group_detial_info_online_member_num";  // uint,   只读, 群组在线成员数量
static const char* kTIMGroupDetialInfoVisible          = "group_detial_info_visible";            // uint,   只读, 群组成员是否对外可见
static const char* kTIMGroupDetialInfoSearchable       = "group_detial_info_searchable";         // uint,   只读, 群组是否能被搜索
static const char* kTIMGroupDetialInfoIsShutupAll      = "group_detial_info_is_shutup_all";      // bool,   只读, 群组是否被设置了全员禁言
static const char* kTIMGroupDetialInfoOwnerIdentifier  = "group_detial_info_owener_identifier";  // string, 只读, 群组所有者ID
static const char* kTIMGroupDetialInfoCustomInfo       = "group_detial_info_custom_info";        // object key string value string, 只读, 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct

/**
* @brief 获取群组信息列表接口的返回
*/
// Struct GetGroupInfoResult JsonKey
static const char* kTIMGetGroupInfoResultCode  = "get_groups_info_result_code";    // int [错误码](https://cloud.tencent.com/document/product/269/1671),   只读, 获取群组详细信息的结果
static const char* kTIMGetGroupInfoResultDesc  = "get_groups_info_result_desc";    // string, 只读,获取群组详细失败的描述信息
static const char* kTIMGetGroupInfoResultInfo  = "get_groups_info_result_info";    // json object [GroupDetailInfo](), 只读, 群组详细信息
// EndStruct

/**
* @brief 设置(修改)群组信息的类型
*/
enum TIMGroupModifyInfoFlag {
    kTIMGroupModifyInfoFlag_None         = 0x00,
    kTIMGroupModifyInfoFlag_Name         = 0x01,       // 修改群组名称,      
    kTIMGroupModifyInfoFlag_Notification = 0x01 << 1,  // 修改群公告,        
    kTIMGroupModifyInfoFlag_Introduction = 0x01 << 2,  // 修改群简介         
    kTIMGroupModifyInfoFlag_FaceUrl      = 0x01 << 3,  // 修改群头像URL      
    kTIMGroupModifyInfoFlag_AddOption    = 0x01 << 4,  // 修改群组添加选项,  
    kTIMGroupModifyInfoFlag_MaxMmeberNum = 0x01 << 5,  // 修改群最大成员数,  
    kTIMGroupModifyInfoFlag_Visible      = 0x01 << 6,  // 修改群是否可见,    
    kTIMGroupModifyInfoFlag_Searchable   = 0x01 << 7,  // 修改群是否被搜索,  
    kTIMGroupModifyInfoFlag_ShutupAll    = 0x01 << 8,  // 修改群是否全体禁言,
    kTIMGroupModifyInfoFlag_Owner        = 0x01 << 31, // 修改群主
};

/**
* @brief 设置群信息接口的参数
*/
// Struct GroupModifyInfoParam JsonKey
static const char* kTIMGroupModifyInfoParamGroupId           = "group_modify_info_param_group_id";        // string, 只写(必填), 群组ID
static const char* kTIMGroupModifyInfoParamModifyFlag        = "group_modify_info_param_modify_flag";     // uint [TIMGroupSetInfoFlag](),  只写(必填), 修改标识,可设置多个值按位或
static const char* kTIMGroupModifyInfoParamGroupName         = "group_modify_info_param_group_name";      // string, 只写(选填), 修改群组名称,       当 modify_flag 包含 kTIMGroupModifyInfoFlag_Name 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamNotification      = "group_modify_info_param_notification";    // string, 只写(选填), 修改群公告,         当 modify_flag 包含 kTIMGroupModifyInfoFlag_Notification 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamIntroduction      = "group_modify_info_param_introduction";    // string, 只写(选填), 修改群简介,         当 modify_flag 包含 kTIMGroupModifyInfoFlag_Introduction 时必填,其他情况不用填  
static const char* kTIMGroupModifyInfoParamFaceUrl           = "group_modify_info_param_face_url";        // string, 只写(选填), 修改群头像URL,      当 modify_flag 包含 kTIMGroupModifyInfoFlag_FaceUrl 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamAddOption         = "group_modify_info_param_add_option";      // uint,  只写(选填), 修改群组添加选项,    当 modify_flag 包含 kTIMGroupModifyInfoFlag_AddOption 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamMaxMemberNum      = "group_modify_info_param_max_member_num";  // uint,  只写(选填), 修改群最大成员数,    当 modify_flag 包含 kTIMGroupModifyInfoFlag_MaxMmeberNum 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamVisible           = "group_modify_info_param_visible";         // uint,  只写(选填), 修改群是否可见,      当 modify_flag 包含 kTIMGroupModifyInfoFlag_Visible 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamSearchAble        = "group_modify_info_param_searchable";      // uint,  只写(选填), 修改群是否被搜索,    当 modify_flag 包含 kTIMGroupModifyInfoFlag_Searchable 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamIsShutupAll       = "group_modify_info_param_is_shutup_all";   // bool,   只写(选填), 修改群是否全体禁言, 当 modify_flag 包含 kTIMGroupModifyInfoFlag_ShutupAll 时必填,其他情况不用填
static const char* kTIMGroupModifyInfoParamOwner             = "group_modify_info_param_owner";           // string, 只写(选填), 修改群主所有者,     当 modify_flag 包含 kTIMGroupModifyInfoFlag_Owner 时必填,其他情况不用填。此时 modify_flag 不能包含其他值，当修改群主时，同时修改其他信息已无意义
static const char* kTIMGroupModifyInfoParamCustomInfo        = "group_modify_info_param_custom_info";     // object key string value string, 只写(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct

/**
* @brief 获取群成员列表接口的参数
*/
// Struct GroupGetMemberInfoListParam JsonKey
static const char* kTIMGroupGetMemberInfoListParamGroupId         = "group_get_members_info_list_param_group_id";          // string,       只写(必填), 群组ID
static const char* kTIMGroupGetMemberInfoListParamIdentifierArray = "group_get_members_info_list_param_identifier_array";  // array string, 只写(选填), 群成员ID列表
static const char* kTIMGroupGetMemberInfoListParamOption          = "group_get_members_info_list_param_option";            // object [GroupMemberGetInfoOption](), 只写(选填), 获取群成员信息的选项
static const char* kTIMGroupGetMemberInfoListParamNextSeq         = "group_get_members_info_list_param_next_seq";          // uint64, 只写(选填), 分页拉取标志,第一次拉取填0,回调成功如果不为零,需要分页,传入再次拉取,直至为0
// EndStruct

/**
* @brief 获取群成员列表接口的返回
*/
// Struct GroupGetMemberInfoListResult JsonKey
static const char* kTIMGroupGetMemberInfoListResultNexSeq     = "group_get_memeber_info_list_result_next_seq";   // uint64, 只读, 下一次拉取的标志,server返回0表示没有更多的数据,否则在下次获取数据时填入这个标志
static const char* kTIMGroupGetMemberInfoListResultInfoArray  = "group_get_memeber_info_list_result_info_array"; // array [GroupMemberInfo](), 只读, 成员信息列表
// EndStruct


/**
* @brief 设置(修改)群成员信息的类型
*/
enum TIMGroupMemberModifyInfoFlag {
    kTIMGroupMemberModifyFlag_None       = 0x00,      // 
    kTIMGroupMemberModifyFlag_MsgFlag    = 0x01,      // 修改消息接收选项
    kTIMGroupMemberModifyFlag_MemberRole = 0x01 << 1, // 修改成员角色
    kTIMGroupMemberModifyFlag_ShutupTime = 0x01 << 2, // 修改禁言时间
    kTIMGroupMemberModifyFlag_NameCard   = 0x01 << 3, // 修改群名片
};


/**
* @brief 设置群成员信息接口的参数
*/
// Struct GroupModifyMemberInfoParam JsonKey
static const char* kTIMGroupModifyMemberInfoParamGroupId     = "group_modify_member_info_group_id";       // string, 只写(必填), 群组ID
static const char* kTIMGroupModifyMemberInfoParamIdentifier  = "group_modify_member_info_identifier";     // string, 只写(必填), 被设置信息的成员ID
static const char* kTIMGroupModifyMemberInfoParamModifyFlag  = "group_modify_member_info_modify_flag";    // uint [TIMGroupMemberModifyInfoFlag](), 只写(必填), 修改类型,可设置多个值按位或
static const char* kTIMGroupModifyMemberInfoParamMsgFlag     = "group_modify_member_info_msg_flag";       // uint,   只写(选填), 修改消息接收选项,                  当 modify_flag 包含 kTIMGroupMemberModifyFlag_MsgFlag 时必填,其他情况不用填
static const char* kTIMGroupModifyMemberInfoParamMemberRole  = "group_modify_member_info_member_role";    // uint [TIMGroupMemberRole](), 只写(选填), 修改成员角色, 当 modify_flag 包含 kTIMGroupMemberModifyFlag_MemberRole 时必填,其他情况不用填
static const char* kTIMGroupModifyMemberInfoParamShutupTime  = "group_modify_member_info_shutup_time";    // uint,   只写(选填), 修改禁言时间,                      当 modify_flag 包含 kTIMGroupMemberModifyFlag_ShutupTime 时必填,其他情况不用填
static const char* kTIMGroupModifyMemberInfoParamNameCard    = "group_modify_member_info_name_card";      // string, 只写(选填), 修改群名片,                        当 modify_flag 包含 kTIMGroupMemberModifyFlag_NameCard 时必填,其他情况不用填
static const char* kTIMGroupModifyMemberInfoParamCustomInfo  = "group_modify_member_info_custom_info";    // object key string value string, 只写(选填), 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
// EndStruct

/**
* @brief 获取群未决信息列表的参数
*/
// Struct GroupPendencyOption JsonKey
static const char* kTIMGroupPendencyOptionStartTime     = "group_pendency_option_start_time";       // uint64, 只写(必填), 设置拉取时间戳,第一次请求填0,后边根据server返回的[GroupPendencyResult]()键kTIMGroupPendencyResultNextStartTime指定的时间戳进行填写
static const char* kTIMGroupPendencyOptionMaxLimited    = "group_pendency_option_max_limited";      // uint,   只写(选填), 拉取的建议数量,server可根据需要返回或多或少,不能作为完成与否的标志
// EndStruct


/**
* @brief 未决请求类型
*/
enum TIMGroupPendencyType {
    kTIMGroupPendency_RequestJoin = 0,  // 请求加群
    kTIMGroupPendency_InviteJoin = 1,   // 邀请加群
    kTIMGroupPendency_ReqAndInvite = 2, // 邀请和请求的
};

/**
* @brief 群未决处理状态
*/
enum TIMGroupPendencyHandle {
    kTIMGroupPendency_NotHandle = 0,      // 未处理
    kTIMGroupPendency_OtherHandle = 1,    // 他人处理
    kTIMGroupPendency_OperatorHandle = 2, // 操作方处理
};

/**
* @brief 群未决处理操作类型
*/
enum TIMGroupPendencyHandleResult {
    kTIMGroupPendency_Refuse = 0,  // 拒绝
    kTIMGroupPendency_Accept = 1,  // 同意
};

/**
* @brief 群未决信息定义
*/
// Struct GroupPendency JsonKey
static const char* kTIMGroupPendencyGroupId             = "group_pendency_group_id";                //string,  读写, 群组ID
static const char* kTIMGroupPendencyFromIdentifier      = "group_pendency_form_identifier";         //string,  读写, 请求者的ID,比如：请求加群:请求者,邀请加群:邀请人。
static const char* kTIMGroupPendencyToIdentifier        = "group_pendency_to_identifier";           //string,  读写, 判决者的ID,请求加群:"",邀请加群:被邀请人。
static const char* kTIMGroupPendencyAddTime             = "group_pendency_add_time";                //uint64,  只读, 未决信息添加时间
static const char* kTIMGroupPendencyPendencyType        = "group_pendency_pendency_type";           //uint [TIMGroupPendencyType](),  只读, 未决请求类型
static const char* kTIMGroupPendencyHandled             = "group_pendency_handled";                 //uint [TIMGroupPendencyHandle](),只读, 群未决处理状态
static const char* kTIMGroupPendencyHandleResult        = "group_pendency_handle_result";           //uint [TIMGroupPendencyHandleResult](), 只读, 群未决处理操作类型
static const char* kTIMGroupPendencyApplyInviteMsg      = "group_pendency_apply_invite_msg";        //string, 只读, 申请或邀请附加信息
static const char* kTIMGroupPendencyFromUserDefinedData = "group_pendency_form_user_defined_data";  //string, 只读, 申请或邀请者自定义字段
static const char* kTIMGroupPendencyApprovalMsg         = "group_pendency_approval_msg";            //string, 只读, 审批信息：同意或拒绝信息
static const char* kTIMGroupPendencyToUserDefinedData   = "group_pendency_to_user_defined_data";    //string, 只读, 审批者自定义字段
// EndStruct

/**
* @brief 获取群未决信息列表的返回
*/
// Struct GroupPendencyResult JsonKey
static const char* kTIMGroupPendencyResultNextStartTime = "group_pendency_result_next_start_time";  // uint64, 只读, 下一次拉取的起始时戳,server返回0表示没有更多的数据,否则在下次获取数据时以这个时间戳作为开始时间戳
static const char* kTIMGroupPendencyResultReadTimeSeq   = "group_pendency_result_read_time_seq";    // uint64, 只读, 已读上报的时间戳
static const char* kTIMGroupPendencyResultUnReadNum     = "group_pendency_result_unread_num";       // uint,   只读, 未决请求的未读数 ?
static const char* kTIMGroupPendencyResultPendencyArray = "group_pendency_result_pendency_array";   // array [GroupPendency](), 只读, 群未决信息列表
// EndStruct

/**
* @brief 处理群未决消息接口的参数
*/
// Struct GroupHandlePendencyParam JsonKey
static const char* kTIMGroupHandlePendencyParamIsAccept   = "group_handle_pendency_param_is_accept";  // bool,   只写(选填), true表示接受，false表示拒绝。默认为false
static const char* kTIMGroupHandlePendencyParamHandleMsg  = "group_handle_pendency_param_handle_msg"; // string, 只写(选填), 同意或拒绝信息,默认为空字符串
static const char* kTIMGroupHandlePendencyParamPendency   = "group_handle_pendency_param_pendency";   // object [GroupPendency](), 只写(必填), 未决信息详情
// EndStruct

/// @}

#endif //SDK_TIM_CLOUD_DEF_HEADER_
