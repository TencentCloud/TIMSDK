/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：V2TIMManager+Message
//
//  消息高级接口，里面包含了所有高级消息的创建、收发逻辑
//
/////////////////////////////////////////////////////////////////////

#import "V2TIMManager.h"

@class V2TIMMessage;
@class V2TIMTextElem;
@class V2TIMCustomElem;
@class V2TIMImageElem;
@class V2TIMVideoElem;
@class V2TIMSoundElem;
@class V2TIMFileElem;
@class V2TIMFaceElem;
@class V2TIMLocationElem;
@class V2TIMMergerElem;
@class V2TIMGroupTipsElem;
@class V2TIMMessageListGetOption;
@class V2TIMMessageSearchParam;
@class V2TIMImage;
@class V2TIMMessageReceipt;
@class V2TIMOfflinePushInfo;
@class V2TIMGroupChangeInfo;
@class V2TIMGroupMemberChangeInfo;
@class V2TIMMessageSearchResult;
@class V2TIMReceiveMessageOptInfo;
@protocol V2TIMAdvancedMsgListener;


@interface V2TIMManager (Message)

/////////////////////////////////////////////////////////////////////////////////
//
//                         异步接口的回调 BLOCK
//
/////////////////////////////////////////////////////////////////////////////////

/// 查询历史消息的结果回调（查询接口会批量地返回从某个时间点之前的历史消息）
typedef void (^V2TIMMessageListSucc)(NSArray<V2TIMMessage *> * msgs);
/// 搜索历史消息的结果回调（查询接口支持模糊匹配）
typedef void (^V2TIMSearchMessageListSucc)(V2TIMMessageSearchResult *searchResult);
/// 文件上传进度回调，取值 0 -100
typedef void (^V2TIMProgress)(uint32_t progress);
/// 文件下载进度回调
typedef void (^V2TIMDownLoadProgress)(NSInteger curSize, NSInteger totalSize);
/// 获取消息接收选项的结果回调
typedef void (^V2TIMReceiveMessageOptListSucc)(NSArray<V2TIMReceiveMessageOptInfo *> *optList);

/// 在接口 createTextAtMessage 中填入 kMesssageAtALL 表示当前消息需要 @ 群里所有人
extern NSString * const kImSDK_MesssageAtALL;

/// 消息状态
typedef NS_ENUM(NSInteger, V2TIMMessageStatus){
    V2TIM_MSG_STATUS_SENDING                  = 1,  ///< 消息发送中
    V2TIM_MSG_STATUS_SEND_SUCC                = 2,  ///< 消息发送成功
    V2TIM_MSG_STATUS_SEND_FAIL                = 3,  ///< 消息发送失败
    V2TIM_MSG_STATUS_HAS_DELETED              = 4,  ///< 消息被删除
    V2TIM_MSG_STATUS_LOCAL_IMPORTED           = 5,  ///< 导入到本地的消息
    V2TIM_MSG_STATUS_LOCAL_REVOKED            = 6,  ///< 被撤销的消息
};

/// 消息类型
typedef NS_ENUM(NSInteger, V2TIMElemType){
    V2TIM_ELEM_TYPE_NONE                      = 0,  ///< 未知消息
    V2TIM_ELEM_TYPE_TEXT                      = 1,  ///< 文本消息
    V2TIM_ELEM_TYPE_CUSTOM                    = 2,  ///< 自定义消息
    V2TIM_ELEM_TYPE_IMAGE                     = 3,  ///< 图片消息
    V2TIM_ELEM_TYPE_SOUND                     = 4,  ///< 语音消息
    V2TIM_ELEM_TYPE_VIDEO                     = 5,  ///< 视频消息
    V2TIM_ELEM_TYPE_FILE                      = 6,  ///< 文件消息
    V2TIM_ELEM_TYPE_LOCATION                  = 7,  ///< 地理位置消息
    V2TIM_ELEM_TYPE_FACE                      = 8,  ///< 表情消息
    V2TIM_ELEM_TYPE_GROUP_TIPS                = 9,  ///< 群 Tips 消息
    V2TIM_ELEM_TYPE_MERGER                    = 10, ///< 合并消息
};

/// 推送规则
typedef NS_ENUM(NSInteger, V2TIMOfflinePushFlag) {
    V2TIM_OFFLINE_PUSH_DEFAULT                = 0,  ///< 按照默认规则进行推送
    V2TIM_OFFLINE_PUSH_NO_PUSH                = 1,  ///< 不进行推送
};

/// 图片类型
typedef NS_ENUM(NSInteger, V2TIMImageType){
    V2TIM_IMAGE_TYPE_ORIGIN                   = 0x01,  ///< 原图
    V2TIM_IMAGE_TYPE_THUMB                    = 0x02,  ///< 缩略图
    V2TIM_IMAGE_TYPE_LARGE                    = 0x04,  ///< 大图
};

/// 群 Tips 类型
typedef NS_ENUM(NSInteger, V2TIMGroupTipsType){
    V2TIM_GROUP_TIPS_TYPE_JOIN                = 0x01,  ///< 主动入群（memberList 加入群组，非 Work 群有效）
    V2TIM_GROUP_TIPS_TYPE_INVITE              = 0x02,  ///< 被邀请入群（opMember 邀请 memberList 入群，Work 群有效）
    V2TIM_GROUP_TIPS_TYPE_QUIT                = 0x03,  ///< 退出群 (opMember 退出群组)
    V2TIM_GROUP_TIPS_TYPE_KICKED              = 0x04,  ///< 踢出群 (opMember 把 memberList 踢出群组)
    V2TIM_GROUP_TIPS_TYPE_SET_ADMIN           = 0x05,  ///< 设置管理员 (opMember 把 memberList 设置为管理员)
    V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN        = 0x06,  ///< 取消管理员 (opMember 取消 memberList 管理员身份)
    V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE   = 0x07,  ///< 群资料变更 (opMember 修改群资料： groupName & introduction & notification & faceUrl & owner & custom)
    V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE  = 0x08,  ///< 群成员资料变更 (opMember 修改群成员资料：muteTime)
};

/// 群变更信息 Tips 类型
typedef NS_ENUM(NSInteger, V2TIMGroupInfoChangeType){
    V2TIM_GROUP_INFO_CHANGE_TYPE_NAME         = 0x01,  ///< 群名修改
    V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION = 0x02,  ///< 群简介修改
    V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION = 0x03,  ///< 群公告修改
    V2TIM_GROUP_INFO_CHANGE_TYPE_FACE         = 0x04,  ///< 群头像修改
    V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER        = 0x05,  ///< 群主变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_CUSTOM       = 0x06,  ///< 群自定义字段变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL  = 0x08,  ///< 全员禁言字段变更
};

/// 消息拉取方式
typedef NS_ENUM(NSInteger, V2TIMMessageGetType){
    V2TIM_GET_CLOUD_OLDER_MSG                 = 1,  ///< 获取云端更老的消息
    V2TIM_GET_CLOUD_NEWER_MSG                 = 2,  ///< 获取云端更新的消息
    V2TIM_GET_LOCAL_OLDER_MSG                 = 3,  ///< 获取本地更老的消息
    V2TIM_GET_LOCAL_NEWER_MSG                 = 4,  ///< 获取本地更新的消息
};

/// 消息接收选项
typedef NS_ENUM(NSInteger, V2TIMReceiveMessageOpt) {
    V2TIM_RECEIVE_MESSAGE                     = 0,  ///< 在线正常接收消息，离线时会进行 APNs 推送
    V2TIM_NOT_RECEIVE_MESSAGE                 = 1,  ///< 不会接收到消息，离线不会有推送通知
    V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE          = 2,  ///< 在线正常接收消息，离线不会有推送通知
};

/// 消息搜索关键字匹配类型
typedef NS_ENUM(NSInteger, V2TIMKeywordListMatchType) {
    V2TIM_KEYWORD_LIST_MATCH_TYPE_OR          = 0,
    V2TIM_KEYWORD_LIST_MATCH_TYPE_AND         = 1
};

/////////////////////////////////////////////////////////////////////////////////
//
//                         监听 - 高级（图片、语音、视频等）消息
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  1.1 添加高级消息的事件监听器
 */
- (void)addAdvancedMsgListener:(id<V2TIMAdvancedMsgListener>)listener NS_SWIFT_NAME(addAdvancedMsgListener(listener:));

/**
 *  1.2 移除高级消息的事件监听器
 */
- (void)removeAdvancedMsgListener:(id<V2TIMAdvancedMsgListener>)listener NS_SWIFT_NAME(removeAdvancedMsgListener(listener:));


/////////////////////////////////////////////////////////////////////////////////
//
//                         创建 - 高级（图片、语音、视频等）消息
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  2.1 创建文本消息（最大支持 8KB）
 */
- (V2TIMMessage *)createTextMessage:(NSString *)text;

/**
 *  2.2 创建文本消息，并且可以附带 @ 提醒功能（最大支持 8KB）
 *
 *  提醒消息仅适用于在群组中发送的消息
 *
 *  @param atUserList 需要 @ 的用户列表，如果需要 @ALL，请传入 kImSDK_MesssageAtALL 常量字符串。
 *  举个例子，假设该条文本消息希望@提醒 denny 和 lucy 两个用户，同时又希望@所有人，atUserList 传 @[@"denny",@"lucy",kImSDK_MesssageAtALL]
 *
 *  @note atUserList 使用注意事项
 *  - 默认情况下，最多支持 @ 30个用户，超过限制后，消息会发送失败。
 *  - atUserList 的总数不能超过默认最大数，包括 @ALL。
 */
- (V2TIMMessage *)createTextAtMessage:(NSString *)text atUserList:(NSMutableArray<NSString *> *)atUserList;

/**
 *  2.3 创建自定义消息（最大支持 8KB）
 */
- (V2TIMMessage *)createCustomMessage:(NSData *)data;

/**
 *  2.4 创建自定义消息（最大支持 8KB）
 *
 *  @param desc 自定义消息描述信息，做离线Push时文本展示。
 *  @param extension 离线Push时扩展字段信息。
 */
- (V2TIMMessage *)createCustomMessage:(NSData *)data desc:(NSString *)desc extension:(NSString *)extension;

/**
 *  2.5 创建图片消息（图片文件最大支持 28 MB）
 *
 *  @note 如果是系统相册拿的图片，需要先把图片导入 APP 的目录下，具体请参考 Demo TUIChatController -> imagePickerController 代码示例
 */
- (V2TIMMessage *)createImageMessage:(NSString *)imagePath;

/**
 *  2.6 创建语音消息（语音文件最大支持 28 MB）
 *
 *  @param duration 音频时长，单位 s
 */
- (V2TIMMessage *)createSoundMessage:(NSString *)audioFilePath duration:(int)duration;

/**
 *  2.7 创建视频消息（视频文件最大支持 100 MB）
 *
 *  @param type 视频类型，如 mp4 mov 等
 *  @param duration 视频时长，单位 s
 *  @param snapshotPath 视频封面文件路径
 *
 *  @note 如果是系统相册拿的视频，需要先把视频导入 APP 的目录下，具体请参考 Demo TUIChatController -> imagePickerController 代码示例
 */
- (V2TIMMessage *)createVideoMessage:(NSString *)videoFilePath
                                type:(NSString *)type
                            duration:(int)duration
                        snapshotPath:(NSString *)snapshotPath;

/**
 *  2.8 创建文件消息（文件最大支持 100 MB）
 */
- (V2TIMMessage *)createFileMessage:(NSString *)filePath fileName:(NSString *)fileName;

/**
 *  2.9 创建地理位置消息
 */
- (V2TIMMessage *)createLocationMessage:(NSString *)desc longitude:(double)longitude latitude:(double)latitude;

/**
 *  2.10 创建表情消息
 *
 *  SDK 并不提供表情包，如果开发者有表情包，可使用 index 存储表情在表情包中的索引，或者使用 data 存储表情映射的字符串 key，这些都由用户自定义，SDK 内部只做透传。
 *
 *  @param index 表情索引
 *  @param data 自定义数据
 */
- (V2TIMMessage *)createFaceMessage:(int)index data:(NSData *)data;

/**
 *  2.11 创建合并消息（5.2.210 及以上版本支持）
 *
 *  <p> 我们在收到一条合并消息的时候，通常会在聊天界面这样显示：
 *  <p> |vinson 和 lynx 的聊天记录                       |        -- title         （标题）
 *  <p> |vinson：新版本 SDK 计划什么时候上线呢？            |        -- abstract1     （摘要信息1）
 *  <p> |lynx：计划下周一，具体时间要看下这两天的系统测试情况.. |        -- abstract2     （摘要信息2）
 *  <p> |vinson：好的.                                  |        -- abstract3     （摘要信息3）
 *  <p> 聊天界面通常只会展示合并消息的标题和摘要信息，完整的转发消息列表，需要用户主动点击转发消息 UI 后再获取。
 *
 *  <p> 多条被转发的消息可以被创建成一条合并消息 V2TIMMessage，然后调用 sendMessage 接口发送，实现步骤如下：
 *  <p> 1. 调用 createMergerMessage 创建一条合并消息 V2TIMMessage。
 *  <p> 2. 调用 sendMessage 发送转发消息 V2TIMMessage。
 *
 *  <p> 收到合并消息解析步骤：
 *  <p> 1. 通过 V2TIMMessage 获取 mergerElem。
 *  <p> 2. 通过 mergerElem 获取 title 和 abstractList UI 展示。
 *  <p> 3. 当用户点击摘要信息 UI 的时候，调用 downloadMessageList 接口获取转发消息列表。
 *
 *  @param messageList 消息列表（最大支持 300 条，消息对象必须是 V2TIM_MSG_STATUS_SEND_SUCC 状态，消息类型不能为 V2TIMGroupTipsElem）
 *  @param title 合并消息的来源，比如 "vinson 和 lynx 的聊天记录"、"xxx 群聊的聊天记录"。
 *  @param abstractList 合并消息的摘要列表(最大支持 5 条摘要，每条摘要的最大长度不超过 100 个字符）,不同的消息类型可以设置不同的摘要信息，比如:
 *  文本消息可以设置为：sender：text，图片消息可以设置为：sender：[图片]，文件消息可以设置为：sender：[文件]。
 *  @param compatibleText 合并消息兼容文本，低版本 SDK 如果不支持合并消息，默认会收到一条文本消息，文本消息的内容为 compatibleText，
 *  该参数不能为 nil。
 *
 */
- (V2TIMMessage *)createMergerMessage:(NSArray<V2TIMMessage *> *)messageList
                                title:(NSString *)title
                         abstractList:(NSArray<NSString *> *)abstractList
                       compatibleText:(NSString *)compatibleText;

/**
 *  2.12 创建转发消息（5.2.210 及以上版本支持）
 *
 *  如果需要转发一条消息，不能直接调用 sendMessage 接口发送原消息，需要先 createForwardMessage 创建一条转发消息再发送。
 *
 *  @param message 待转发的消息对象，消息状态必须为 V2TIM_MSG_STATUS_SEND_SUCC，消息类型不能为 V2TIMGroupTipsElem。
 *  @return 转发消息对象，elem 内容和原消息完全一致。
 */
- (V2TIMMessage *)createForwardMessage:(V2TIMMessage *)message;

/////////////////////////////////////////////////////////////////////////////////
//
//                         发送 - 高级（图片、语音、视频等）消息
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  3.1 发送高级消息（高级版本：可以指定优先级，推送信息等特性）
 *
 *  @param message 待发送的消息对象，需要通过对应的 createXXXMessage 接口进行创建。
 *  @param receiver 消息接收者的 userID, 如果是发送 C2C 单聊消息，只需要指定 receiver 即可。
 *  @param groupID 目标群组 ID，如果是发送群聊消息，只需要指定 groupID 即可。
 *  @param priority 消息优先级，仅针对群聊消息有效。请把重要消息设置为高优先级（比如红包、礼物消息），高频且不重要的消息设置为低优先级（比如点赞消息）。
 *  @param onlineUserOnly 是否只有在线用户才能收到，如果设置为 YES ，接收方历史消息拉取不到，常被用于实现”对方正在输入”或群组里的非重要提示等弱提示功能，该字段不支持 AVChatRoom。
 *  @param offlinePushInfo 苹果 APNS 离线推送时携带的标题和声音。
 *  @param progress 文件上传进度（当发送消息中包含图片、语音、视频、文件等富媒体消息时才有效）。
 *  @return msgID 消息唯一标识
 *
 *  @note
 *  - 如果需要消息离线推送，请先在 V2TIMManager+APNS.h 开启推送，推送开启后，除了自定义消息，其他消息默认都会推送。
 *  - 如果自定义消息也需要推送，请设置 offlinePushInfo 的 desc 字段，设置成功后，推送的时候会默认展示 desc 信息。
 *  - AVChatRoom 群聊不支持 onlineUserOnly 字段，如果是 AVChatRoom 请将该字段设置为 NO。
 *  - 如果设置 onlineUserOnly 为 YES 时，该消息为在线消息且不会被计入未读计数。
 */
- (NSString *)sendMessage:(V2TIMMessage *)message
                 receiver:(NSString *)receiver
                  groupID:(NSString *)groupID
                 priority:(V2TIMMessagePriority)priority
           onlineUserOnly:(BOOL)onlineUserOnly
          offlinePushInfo:(V2TIMOfflinePushInfo *)offlinePushInfo
                 progress:(V2TIMProgress)progress
                     succ:(V2TIMSucc)succ
                     fail:(V2TIMFail)fail;

/////////////////////////////////////////////////////////////////////////////////
//
//                         接收 - 设置消息的接口选项（接收|接收但不提醒|不接收）
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  4.1 设置针对某个用户的 C2C 消息接收选项（支持批量设置）
 *  <p>5.3.425 及以上版本支持
 *
 *  @note
 *  - 该接口支持批量设置，您可以通过参数 userIDList 设置一批用户，但一次最大允许设置 30 个用户。
 *  - 该接口调用频率被限制为1秒内最多调用5次。
 */
- (void)setC2CReceiveMessageOpt:(NSArray<NSString *> *)userIDList
                            opt:(V2TIMReceiveMessageOpt)opt
                           succ:(V2TIMSucc)succ
                           fail:(V2TIMFail)fail;
/**
 *  4.2 查询针对某个用户的 C2C 消息接收选项
 *  <p>5.3.425 及以上版本支持
 */
- (void)getC2CReceiveMessageOpt:(NSArray<NSString *> *)userIDList
                           succ:(V2TIMReceiveMessageOptListSucc)succ
                           fail:(V2TIMFail)fail;

/**
 *  4.3 设置群消息的接收选项
 */
- (void)setGroupReceiveMessageOpt:(NSString*)groupID 
                              opt:(V2TIMReceiveMessageOpt)opt
                             succ:(V2TIMSucc)succ
                             fail:(V2TIMFail)fail;

/////////////////////////////////////////////////////////////////////////////////
//
//                         获取历史消息、撤回、删除、标记已读等高级接口
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  5.1 获取单聊历史消息
 *
 *  @param count 拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
 *  @param lastMsg 获取消息的起始消息，如果传 nil，起始消息为会话的最新消息
 *
 *  @note 如果 SDK 检测到没有网络，默认会直接返回本地数据
 */
- (void)getC2CHistoryMessageList:(NSString *)userID count:(int)count lastMsg:(V2TIMMessage*)lastMsg succ:(V2TIMMessageListSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.2 获取群组历史消息
 *
 *  @param count 拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
 *  @param lastMsg 获取消息的起始消息，如果传 nil，起始消息为会话的最新消息
 *
 *  @note 请注意：
 *  - 如果 SDK 检测到没有网络，默认会直接返回本地数据
 *  - 只有会议群（Meeting）才能拉取到进群前的历史消息，直播群（AVChatRoom）消息不存漫游和本地数据库，调用这个接口无效
 *
 */
- (void)getGroupHistoryMessageList:(NSString *)groupID count:(int)count lastMsg:(V2TIMMessage*)lastMsg succ:(V2TIMMessageListSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.3 获取历史消息高级接口
 *
 *  @param option 拉取消息选项设置，可以设置从云端、本地拉取更老或更新的消息
 *
 *  @note 请注意：
 *  - 如果设置为拉取云端消息，当 SDK 检测到没有网络，默认会直接返回本地数据
 *  - 只有会议群（Meeting）才能拉取到进群前的历史消息，直播群（AVChatRoom）消息不存漫游和本地数据库，调用这个接口无效
 *
 */
- (void)getHistoryMessageList:(V2TIMMessageListGetOption *)option succ:(V2TIMMessageListSucc)succ
                         fail:(V2TIMFail)fail;

/**
 *  5.4 撤回消息
 *
 *  @note 请注意：
    - 撤回消息的时间限制默认 2 minutes，超过 2 minutes 的消息不能撤回，您也可以在 [控制台](https://console.cloud.tencent.com/im)（功能配置 -> 登录与消息 -> 消息撤回设置）自定义撤回时间限制。
 *  - 仅支持单聊和群组中发送的普通消息，无法撤销 onlineUserOnly 为 true 即仅在线用户才能收到的消息，也无法撤销直播群（AVChatRoom）中的消息。
 *  - 如果发送方撤回消息，已经收到消息的一方会收到 V2TIMAdvancedMsgListener -> onRecvMessageRevoked 回调。
 */
- (void)revokeMessage:(V2TIMMessage *)msg succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.5 设置单聊消息已读
 *
 *  @note 从 5.8 版本开始，当 userID 为 nil 时，标记所有单聊消息为已读状态
 */
- (void)markC2CMessageAsRead:(NSString *)userID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.6 设置群组消息已读
 *
 *  @note 从 5.8 版本开始，当 groupID 为 nil 时，标记所有群组消息为已读状态
 */
- (void)markGroupMessageAsRead:(NSString *)groupID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.7 标记所有消息为已读 （5.8 及其以上版本支持）
 */
- (void)markAllMessageAsRead:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.8 删除本地消息
 *
 *  @note 该接口只能删除本地历史，消息删除后，SDK 会在本地把这条消息标记为已删除状态，getHistoryMessage 不能再拉取到，如果程序卸载重装，本地会失去对这条消息的删除标记，getHistoryMessage 还能再拉取到该条消息。
 */
- (void)deleteMessageFromLocalStorage:(V2TIMMessage *)msg succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.9 删除本地及云端的消息
 *
 *  @note 该接口会在 deleteMessageFromLocalStorage 的基础上，同步删除云端存储的消息，且无法恢复。需要注意的是：
 *  - 一次最多只能删除 30 条消息
 *  - 要删除的消息必须属于同一会话
 *  - 一秒钟最多只能调用一次该接口
 *  - 如果该账号在其他设备上拉取过这些消息，那么调用该接口删除后，这些消息仍然会保存在那些设备上，即删除消息不支持多端同步。
 */
- (void)deleteMessages:(NSArray<V2TIMMessage *>*)msgList succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.10 清空单聊本地及云端的消息（不删除会话）
 * <p>5.4.666 及以上版本支持
 *
 * @note 请注意：
 * - 会话内的消息在本地删除的同时，在服务器也会同步删除。
 */
- (void)clearC2CHistoryMessage:(NSString *)userID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.11 清空群聊本地及云端的消息（不删除会话）
 * <p>5.4.666 及以上版本支持
 *
 * @note 请注意：
 * - 会话内的消息在本地删除的同时，在服务器也会同步删除。
 */
- (void)clearGroupHistoryMessage:(NSString *)groupID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.12 向群组消息列表中添加一条消息
 *
 *  该接口主要用于满足向群组聊天会话中插入一些提示性消息的需求，比如“您已经退出该群”，这类消息有展示
 *  在聊天消息区的需求，但并没有发送给其他人的必要。
 *  所以 insertGroupMessageToLocalStorage() 相当于一个被禁用了网络发送能力的 sendMessage() 接口。
 *
 *  @return msgID 消息唯一标识
 *  @note 通过该接口 save 的消息只存本地，程序卸载后会丢失。
 */
- (NSString *)insertGroupMessageToLocalStorage:(V2TIMMessage *)msg to:(NSString *)groupID sender:(NSString *)sender succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.13 向C2C消息列表中添加一条消息
 *
 *  该接口主要用于满足向C2C聊天会话中插入一些提示性消息的需求，比如“您已成功发送消息”，这类消息有展示
 *  在聊天消息区的需求，但并没有发送给对方的必要。
 *  所以 insertC2CMessageToLocalStorage()相当于一个被禁用了网络发送能力的 sendMessage() 接口。
 *
 *  @return msgID 消息唯一标识
 *  @note 通过该接口 save 的消息只存本地，程序卸载后会丢失。
 */
- (NSString *)insertC2CMessageToLocalStorage:(V2TIMMessage *)msg to:(NSString *)userID sender:(NSString *)sender succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  5.14 根据 messageID 查询指定会话中的本地消息
 *  @param messageIDList 消息 ID 列表
 */
- (void)findMessages:(NSArray<NSString *>*)messageIDList succ:(V2TIMMessageListSucc)succ fail:(V2TIMFail)fail;

/**
 * 5.15 搜索本地消息（5.4.666 及以上版本支持，需要您购买旗舰版套餐）
 * @param param 消息搜索参数，详见 V2TIMMessageSearchParam 的定义
*/
 - (void)searchLocalMessages:(V2TIMMessageSearchParam *)param succ:(V2TIMSearchMessageListSucc)succ fail:(V2TIMFail)fail;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//                         高级消息监听器
//
/////////////////////////////////////////////////////////////////////////////////
/// 高级消息监听器
@protocol V2TIMAdvancedMsgListener <NSObject>
@optional
/// 收到新消息
- (void)onRecvNewMessage:(V2TIMMessage *)msg;

/// 收到消息已读回执（仅单聊有效）
- (void)onRecvC2CReadReceipt:(NSArray<V2TIMMessageReceipt *> *)receiptList;

/// 收到消息撤回
- (void)onRecvMessageRevoked:(NSString *)msgID;

/// 消息内容被修改（第三方服务回调修改了消息内容）
- (void)onRecvMessageModified:(V2TIMMessage *)msg;

@end

/// C2C 已读回执
@interface V2TIMMessageReceipt : NSObject

/// C2C 消息接收对象
@property(nonatomic,strong,readonly) NSString * userID;

/// 已读回执时间，这个时间戳之前的消息都可以认为对方已读
@property(nonatomic,assign,readonly) time_t timestamp;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         消息内容详解
/////////////////////////////////////////////////////////////////////////////////
/// 高级消息
@interface V2TIMMessage : NSObject
/// 消息 ID（消息创建的时候为 nil，消息发送的时候会生成）
@property(nonatomic,strong,readonly) NSString *msgID;

/// 消息时间
@property(nonatomic,strong,readonly) NSDate *timestamp;

/// 消息发送者
@property(nonatomic,strong,readonly) NSString *sender;

/// 消息发送者昵称
@property(nonatomic,strong,readonly) NSString *nickName;

/// 消息发送者好友备注
@property(nonatomic,strong,readonly) NSString *friendRemark;

/// 如果是群组消息，nameCard 为发送者的群名片
@property(nonatomic,strong,readonly) NSString *nameCard;

/// 消息发送者头像
@property(nonatomic,strong,readonly) NSString *faceURL;

/// 如果是群组消息，groupID 为会话群组 ID，否则为 nil
@property(nonatomic,strong,readonly) NSString *groupID;

/// 如果是单聊消息，userID 为会话用户 ID，否则为 nil，
/// 假设自己和 userA 聊天，无论是自己发给 userA 的消息还是 userA 发给自己的消息，这里的 userID 均为 userA
@property(nonatomic,strong,readonly) NSString *userID;

/// 群聊中的消息序列号云端生成，在群里是严格递增且唯一的,
/// 单聊中的序列号是本地生成，不能保证严格递增且唯一。
@property(nonatomic,assign,readonly) uint64_t seq;

/// 消息随机码
@property(nonatomic,assign,readonly) uint64_t random;

/// 消息发送状态
@property(nonatomic,assign,readonly) V2TIMMessageStatus status;

/// 消息发送者是否是自己
@property(nonatomic,assign,readonly) BOOL isSelf;

/// 消息自己是否已读
@property(nonatomic,assign,readonly) BOOL isRead;

/// 消息对方是否已读（只有 C2C 消息有效）
@property(nonatomic,assign,readonly) BOOL isPeerRead;

/// 群消息中被 @ 的用户 UserID 列表（即该消息都 @ 了哪些人）
@property(nonatomic,strong,readonly) NSMutableArray<NSString *> *groupAtUserList;

/// 消息类型
@property(nonatomic,assign,readonly) V2TIMElemType elemType;

/// 消息类型 为 V2TIM_ELEM_TYPE_TEXT，textElem 会存储文本消息内容
@property(nonatomic,strong,readonly) V2TIMTextElem *textElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_CUSTOM，customElem 会存储自定义消息内容
@property(nonatomic,strong,readonly) V2TIMCustomElem *customElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_IMAGE，imageElem 会存储图片消息内容
@property(nonatomic,strong,readonly) V2TIMImageElem *imageElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_SOUND，soundElem 会存储语音消息内容
@property(nonatomic,strong,readonly) V2TIMSoundElem *soundElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_VIDEO，videoElem 会存储视频消息内容
@property(nonatomic,strong,readonly) V2TIMVideoElem *videoElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_FILE，fileElem 会存储文件消息内容
@property(nonatomic,strong,readonly) V2TIMFileElem *fileElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_LOCATION，locationElem 会存储地理位置消息内容
@property(nonatomic,strong,readonly) V2TIMLocationElem *locationElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_FACE，faceElem 会存储表情消息内容
@property(nonatomic,strong,readonly) V2TIMFaceElem *faceElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_MERGER，mergerElem 会存储转发消息内容
@property(nonatomic,strong,readonly) V2TIMMergerElem *mergerElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_GROUP_TIPS，groupTipsElem 会存储群 tips 消息内容
@property(nonatomic,strong,readonly) V2TIMGroupTipsElem *groupTipsElem;

/// 消息自定义数据（本地保存，不会发送到对端，程序卸载重装后失效）
@property(nonatomic,strong) NSData* localCustomData;

/// 消息自定义数据,可以用来标记语音、视频消息是否已经播放（本地保存，不会发送到对端，程序卸载重装后失效）
@property(nonatomic,assign) int localCustomInt;

/// 消息自定义数据（云端保存，会发送到对端，程序卸载重装后还能拉取到）
@property(nonatomic,strong) NSData* cloudCustomData;

/// 消息是否不计入会话未读数：默认为 NO，表明需要计入会话未读数，设置为 YES，表明不需要计入会话未读数（5.3.425 及以上版本支持）
@property(nonatomic,assign) BOOL isExcludedFromUnreadCount;

/// 消息是否不计入会话 lastMsg：默认为 NO，表明需要计入会话 lastMsg，设置为 YES，表明不需要计入会话 lastMsg（5.4.666 及以上版本支持）
@property(nonatomic,assign) BOOL isExcludedFromLastMessage;

/// 消息的离线推送信息
@property(nonatomic,strong,readonly) V2TIMOfflinePushInfo *offlinePushInfo;

@end


/////////////////////////////////////////////////////////////////////////////////
//                         
//                         消息元素基类
//                         
/////////////////////////////////////////////////////////////////////////////////
/// 消息元素基类
@interface V2TIMElem : NSObject

/// 获取下一个 Elem，如果您的消息有多个 Elem，可以通过当前 Elem 获取下一个 Elem 对象，如果返回值为 nil，表示 Elem 获取结束。
/// 详细使用方法请参考文档 [消息收发](https://cloud.tencent.com/document/product/269/44490#4.-.E5.A6.82.E4.BD.95.E8.A7.A3.E6.9E.90.E5.A4.9A.E4.B8.AA-elem-.E7.9A.84.E6.B6.88.E6.81.AF.EF.BC.9F)
- (V2TIMElem *)nextElem;

/**
 * 添加下一个 elem 元素
 * <br>
 * 如果您的消息需要多个 elem，可以在创建 Message 对象后，通过 Message 的 Elem 对象添加下一个 elem 对象。
 * 以 V2TIMTextElem 和 V2TIMCustomElem 多 elem 为例，示例代码如下：
 * <pre>
 *     V2TIMMessage *msg = [[V2TIMManager sharedInstance] createTextMessage:@"text"];
 *     V2TIMCustomElem *customElem = [[V2TIMCustomElem alloc] init];
 *     customElem.data = [@"自定义消息" dataUsingEncoding:NSUTF8StringEncoding];
 *     [msg.textElem appendElem:customElem];
 * </pre>
 * 
 * @note
 *  1.该接口只能由 createMessage 创建的 Messsage 对象里的 elem 元素调用。
 *  2.该接口仅支持添加 V2TIMTextElem、V2TIMCustomElem、V2TIMFaceElem 和 V2TIMLocationElem 四类元素。
 */
- (void)appendElem:(V2TIMElem *)elem;
@end

/////////////////////////////////////////////////////////////////////////////////
//                         文本消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 文本消息 Elem
@interface V2TIMTextElem : V2TIMElem

/// 消息文本
@property(nonatomic,strong) NSString * text;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         自定义消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 自定义消息 Elem
@interface V2TIMCustomElem : V2TIMElem

/// 自定义消息二进制数据
@property(nonatomic,strong) NSData * data;

/// 自定义消息描述信息
@property(nonatomic,strong) NSString * desc;

/// 自定义消息扩展字段
@property(nonatomic,strong) NSString * extension;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         图片消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 图片消息Elem
@interface V2TIMImageElem : V2TIMElem

/// 图片路径（只有发送方可以获取到）
@property(nonatomic,strong,readonly) NSString * path;

/// 接收图片消息的时候这个字段会保存图片的所有规格，目前最多包含三种规格：原图、大图、缩略图，每种规格保存在一个 TIMImage 对象中
@property(nonatomic,strong,readonly) NSArray<V2TIMImage *> *imageList;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         图片消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 图片元素
@interface V2TIMImage : NSObject

/// 图片 ID，内部标识，可用于外部缓存 key
@property(nonatomic,strong,readonly) NSString * uuid;

/// 图片类型
@property(nonatomic,assign,readonly) V2TIMImageType type;

/// 图片大小（type == V2TIM_IMAGE_TYPE_ORIGIN 有效）
@property(nonatomic,assign,readonly) int size;

/// 图片宽度
@property(nonatomic,assign,readonly) int width;

/// 图片高度
@property(nonatomic,assign,readonly) int height;

/// 图片 url
@property(nonatomic,strong,readonly) NSString * url;

/**
 *  下载图片
 *
 *  下载的数据需要由开发者缓存，IM SDK 每次调用 downloadImage 都会从服务端重新下载数据。建议通过图片的 uuid 作为 key 进行图片文件的存储。
 *
 *  @param path 图片保存路径，需要外部指定
 */
- (void)downloadImage:(NSString *)path progress:(V2TIMDownLoadProgress)progress succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         语音消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 语音消息 Elem
@interface V2TIMSoundElem : V2TIMElem

/// 语音文件路径（只有发送方才能获取到）
@property(nonatomic,strong,readonly) NSString * path;

/// 语音消息内部 ID
@property(nonatomic,strong,readonly) NSString * uuid;

/// 语音数据大小
@property(nonatomic,assign,readonly) int dataSize;

/// 语音长度（秒）
@property(nonatomic,assign,readonly) int duration;

/// 获取语音的 URL 下载地址
-(void)getUrl:(void (^)(NSString * url))urlCallBack;

/**
 *  下载语音
 *
 *  downloadSound 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 语音保存路径，需要外部指定
 */
- (void)downloadSound:(NSString*)path progress:(V2TIMDownLoadProgress)progress succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         视频消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 视频消息 Elem
@interface V2TIMVideoElem : V2TIMElem

/// 视频文件路径（只有发送方才能获取到）
@property(nonatomic,strong,readonly) NSString * videoPath;

/// 截图文件路径（只有发送方才能获取到）
@property(nonatomic,strong,readonly) NSString * snapshotPath;

/// 视频 ID,内部标识，可用于外部缓存 key
@property(nonatomic,strong,readonly) NSString * videoUUID;

/// 视频大小
@property(nonatomic,assign,readonly) int videoSize;

/// 视频类型
@property(nonatomic,strong,readonly) NSString *videoType;

/// 视频时长
@property(nonatomic,assign,readonly) int duration;

/// 截图 ID,内部标识，可用于外部缓存 key
@property(nonatomic,strong,readonly) NSString * snapshotUUID;

/// 截图 size
@property(nonatomic,assign,readonly) int snapshotSize;

/// 截图宽
@property(nonatomic,assign,readonly) int snapshotWidth;

/// 截图高
@property(nonatomic,assign,readonly) int snapshotHeight;

/// 获取视频的 URL 下载地址
-(void)getVideoUrl:(void (^)(NSString * url))urlCallBack;

/// 获取截图的 URL 下载地址
-(void)getSnapshotUrl:(void (^)(NSString * url))urlCallBack;

/**
 *  下载视频
 *
 *  downloadVideo 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 视频保存路径，需要外部指定
 */
- (void)downloadVideo:(NSString*)path progress:(V2TIMDownLoadProgress)progress succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  下载视频截图
 *
 *  downloadSnapshot 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 截图保存路径，需要外部指定
 */
- (void)downloadSnapshot:(NSString*)path progress:(V2TIMDownLoadProgress)progress succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         文件消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 文件消息 Elem
@interface V2TIMFileElem : V2TIMElem

/// 文件路径（只有发送方才能获取到）
@property(nonatomic,strong,readonly) NSString * path;

/// 文件 ID,内部标识，可用于外部缓存 key
@property(nonatomic,strong,readonly) NSString * uuid;

/// 文件显示名称
@property(nonatomic,strong,readonly) NSString * filename;

/// 文件大小
@property(nonatomic,assign,readonly) int fileSize;

/// 获取文件的 URL 下载地址
-(void)getUrl:(void (^)(NSString * url))urlCallBack;

/**
 *  下载文件
 *
 *  downloadFile 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 文件保存路径，需要外部指定
 */
- (void)downloadFile:(NSString*)path progress:(V2TIMDownLoadProgress)progress succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         地理位置 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 地理位置 Elem
@interface V2TIMLocationElem : V2TIMElem

/// 地理位置描述信息
@property(nonatomic,strong) NSString * desc;

/// 经度，发送消息时设置
@property(nonatomic,assign) double longitude;

/// 纬度，发送消息时设置
@property(nonatomic,assign) double latitude;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         表情消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 表情消息 Elem
@interface V2TIMFaceElem : V2TIMElem
/**
 *  表情索引，用户自定义
 *  1. 表情消息由 TIMFaceElem 定义，SDK 并不提供表情包，如果开发者有表情包，可使用 index 存储表情在表情包中的索引，由用户自定义，或者直接使用 data 存储表情二进制信息以及字符串 key，都由用户自定义，SDK 内部只做透传。
 *  2. index 和 data 只需要传入一个即可，ImSDK 只是透传这两个数据。
 */
@property(nonatomic,assign) int index;

/// 额外数据，用户自定义
@property(nonatomic,strong) NSData * data;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         合并消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 合并消息 Elem
@interface V2TIMMergerElem : V2TIMElem

/// 合并消息里面又包含合并消息我们称之为合并嵌套，合并嵌套层数不能超过 100 层，如果超过限制，layersOverLimit 会返回 YES，title 和 abstractList 会返回 nil，downloadMergerMessage 会返回 ERR_MERGER_MSG_LAYERS_OVER_LIMIT 错误码。
@property(nonatomic,assign,readonly) BOOL layersOverLimit;

/// 合并消息 title
@property(nonatomic,strong,readonly) NSString *title;

/// 合并消息摘要列表
@property(nonatomic,strong,readonly) NSArray<NSString *> *abstractList;

/// 下载被合并的消息列表
- (void)downloadMergerMessage:(V2TIMMessageListSucc)succ fail:(V2TIMFail)fail;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         群 Tips 消息 Elem
/////////////////////////////////////////////////////////////////////////////////

/// 群 tips 消息会存消息列表，群里所有的人都会展示，比如 xxx 进群，xxx 退群，xxx 群资料被修改了等
@interface V2TIMGroupTipsElem : V2TIMElem

/// 群组 ID
@property(nonatomic,strong,readonly) NSString * groupID;

/// 群Tips类型
@property(nonatomic,assign,readonly) V2TIMGroupTipsType type;

/// 操作者群成员资料
@property(nonatomic,strong,readonly) V2TIMGroupMemberInfo * opMember;

/// 被操作人列表
@property(nonatomic,strong,readonly) NSArray<V2TIMGroupMemberInfo *> * memberList;

/// 群信息变更（type = V2TIM_GROUP_TIPS_TYPE_INFO_CHANGE 时有效）
@property(nonatomic,strong,readonly) NSArray<V2TIMGroupChangeInfo *> * groupChangeInfoList;

/// 成员变更（type = V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE 时有效）
@property(nonatomic,strong,readonly) NSArray<V2TIMGroupMemberChangeInfo *> * memberChangeInfoList;

/// 当前群人数（type = V2TIM_GROUP_TIPS_TYPE_INVITE、TIM_GROUP_TIPS_TYPE_QUIT_GRP、TIM_GROUP_TIPS_TYPE_KICKED 时有效）
@property(nonatomic,assign,readonly) uint32_t memberCount;

@end

/// 群 tips，群变更信息
@interface V2TIMGroupChangeInfo : NSObject

/// 变更类型
@property(nonatomic,assign,readonly) V2TIMGroupInfoChangeType type;

/// 根据变更类型表示不同的值,例如 type = V2TIM_GROUP_INFO_CHANGE_TYPE_NAME，value 表示群新的 groupName
@property(nonatomic,strong,readonly) NSString * value;

/// 变更自定义字段的 key 值（type = V2TIM_GROUP_INFO_CHANGE_TYPE_CUSTOM 生效）
/// 因为历史遗留原因，如果只修改了群自定义字段，当前消息不会存漫游和 DB
@property(nonatomic,strong,readonly) NSString * key;

/// 根据变更类型表示不同的值，当前只有 type = V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL 时有效
@property(nonatomic,assign,readonly) BOOL boolValue;

@end

///群tips，成员变更信息
@interface V2TIMGroupMemberChangeInfo : NSObject

/// 变更用户
@property(nonatomic,strong,readonly) NSString * userID;

/// 禁言时间（秒，表示还剩多少秒可以发言）
@property(nonatomic,assign,readonly) uint32_t muteTime;

@end


/////////////////////////////////////////////////////////////////////////////////
//                         苹果 APNS 离线推送
/////////////////////////////////////////////////////////////////////////////////

/// 接收时不会播放声音
extern NSString * const kIOSOfflinePushNoSound;
/// 接收时播放系统声音
extern NSString * const kIOSOfflinePushDefaultSound;

/// 自定义消息 push。
@interface V2TIMOfflinePushInfo : NSObject

/// 离线推送展示的标题。
@property(nonatomic,strong) NSString * title;

/// 离线推送展示的内容。
/// 自定义消息进行离线推送，必须设置此字段内容。
@property(nonatomic,strong) NSString * desc;

/// 离线推送扩展字段，
/// iOS: 收到离线推送的一方可以在 UIApplicationDelegate -> didReceiveRemoteNotification -> userInfo 拿到这个字段，用这个字段可以做 UI 跳转逻辑
@property(nonatomic,strong) NSString * ext;

/// 是否关闭推送（默认开启推送）。
@property(nonatomic,assign) BOOL disablePush;

/// 离线推送声音设置（仅对 iOS 生效），
/// 当 iOSSound = kIOSOfflinePushNoSound，表示接收时不会播放声音。
/// 当 iOSSound = kIOSOfflinePushDefaultSound，表示接收时播放系统声音。
/// 如果要自定义 iOSSound，需要先把语音文件链接进 Xcode 工程，然后把语音文件名（带后缀）设置给 iOSSound。
@property(nonatomic,strong) NSString * iOSSound;

/// 离线推送忽略 badge 计数（仅对 iOS 生效），
/// 如果设置为 YES，在 iOS 接收端，这条消息不会使 APP 的应用图标未读计数增加。
@property(nonatomic,assign) BOOL ignoreIOSBadge;

/// 离线推送设置 OPPO 手机 8.0 系统及以上的渠道 ID（仅对 Android 生效）。
@property(nonatomic,strong) NSString *AndroidOPPOChannelID;

/// 离线推送设置 VIVO 手机 （仅对 Android 生效）。
/// VIVO 手机离线推送消息分类，0：运营消息，1：系统消息。默认取值为 1 。
@property(nonatomic,assign) NSInteger AndroidVIVOClassification;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         用户消息接收选项
//
/////////////////////////////////////////////////////////////////////////////////
@interface V2TIMReceiveMessageOptInfo:NSObject
/// 用户 ID
@property(nonatomic, strong) NSString *userID;

/// 消息接收选项
@property(nonatomic, assign) V2TIMReceiveMessageOpt receiveOpt;
@end

/////////////////////////////////////////////////////////////////////////////////
//                         消息搜索
/////////////////////////////////////////////////////////////////////////////////
/// 消息搜索参数
@interface V2TIMMessageSearchParam : NSObject
/**
 * 关键字列表，最多支持5个。当消息发送者以及消息类型均未指定时，关键字列表必须非空；否则，关键字列表可以为空。
 */
@property(nonatomic,strong) NSArray<NSString *> * keywordList;

/**
 * 指定关键字列表匹配类型，可设置为“或”关系搜索或者“与”关系搜索.
 * 取值分别为 V2TIM_KEYWORD_LIST_MATCH_TYPE_OR 和 V2TIM_KEYWORD_LIST_MATCH_TYPE_AND，默认为“或”关系搜索。
 */
@property(nonatomic,assign) V2TIMKeywordListMatchType keywordListMatchType;

/**
 * 指定 userID 发送的消息，最多支持5个。
 */
@property(nonatomic,strong) NSArray<NSString *> *senderUserIDList;

/// 指定搜索的消息类型集合，传 nil 表示搜索支持的全部类型消息（V2TIMFaceElem 和 V2TIMGroupTipsElem 不支持）取值详见 @V2TIMElemType。
@property(nonatomic,strong) NSArray<NSNumber *> * messageTypeList;

/**
 * 搜索“全部会话”还是搜索“指定的会话”：
 * <p> 如果设置 conversationID == nil，代表搜索全部会话。
 * <p> 如果设置 conversationID != nil，代表搜索指定会话。
 */
@property(nonatomic,strong) NSString *conversationID;

/// 搜索的起始时间点。默认为0即代表从现在开始搜索。UTC 时间戳，单位：秒
@property(nonatomic,assign) NSUInteger searchTimePosition;

/// 从起始时间点开始的过去时间范围，单位秒。默认为0即代表不限制时间范围，传24x60x60代表过去一天。
@property(nonatomic,assign) NSUInteger searchTimePeriod;

/**
 * 分页的页号：用于分页展示查找结果，从零开始起步。
 * 比如：您希望每页展示 10 条结果，请按照如下规则调用：
 * - 首次调用：通过参数 pageSize = 10, pageIndex = 0 调用 searchLocalMessage，从结果回调中的 totalCount 可以获知总共有多少条结果。
 * - 计算页数：可以获知总页数：totalPage = (totalCount % pageSize == 0) ? (totalCount / pageSize) : (totalCount / pageSize + 1) 。
 * - 再次调用：可以通过指定参数 pageIndex （pageIndex < totalPage）返回后续页号的结果。
*/
@property(nonatomic, assign) NSUInteger pageIndex;

/// 每页结果数量：用于分页展示查找结果，如不希望分页可将其设置成 0，但如果结果太多，可能会带来性能问题。
@property(nonatomic, assign) NSUInteger pageSize;

@end

@interface V2TIMMessageSearchResultItem : NSObject

/// 会话ID
@property(nonatomic,copy) NSString *conversationID;

/// 当前会话一共搜索到了多少条符合要求的消息
@property(nonatomic, assign) NSUInteger messageCount;

/**
 * 满足搜索条件的消息列表
 * <p>如果您本次搜索【指定会话】，那么 messageList 中装载的是本会话中所有满足搜索条件的消息列表。
 * <p>如果您本次搜索【全部会话】，那么 messageList 中装载的消息条数会有如下两种可能：
 * - 如果某个会话中匹配到的消息条数 > 1，则 messageList 为空，您可以在 UI 上显示“ messageCount 条相关记录”。
 * - 如果某个会话中匹配到的消息条数 = 1，则 messageList 为匹配到的那条消息，您可以在 UI 上显示之，并高亮匹配关键词。
*/
@property(nonatomic,strong) NSArray<V2TIMMessage *> *messageList;

@end

@interface V2TIMMessageSearchResult : NSObject

/**
 * 如果您本次搜索【指定会话】，那么返回满足搜索条件的消息总数量；
 * 如果您本次搜索【全部会话】，那么返回满足搜索条件的消息所在的所有会话总数量。
 */
@property(nonatomic, assign) NSUInteger totalCount;

/**
 * 如果您本次搜索【指定会话】，那么返回结果列表只包含该会话结果；
 * 如果您本次搜索【全部会话】，那么对满足搜索条件的消息根据会话 ID 分组，分页返回分组结果；
 */
@property(nonatomic, strong) NSArray<V2TIMMessageSearchResultItem *> *messageSearchResultItems;

@end


/////////////////////////////////////////////////////////////////////////////////
//                         消息拉取
/////////////////////////////////////////////////////////////////////////////////

@interface V2TIMMessageListGetOption : NSObject

/**
 * 拉取消息类型，可以设置拉取本地、云端更老或者更新的消息
 *
 * @note 请注意
 * <p>当设置从云端拉取时，会将本地存储消息列表与云端存储消息列表合并后返回。如果无网络，则直接返回本地消息列表。
 * <p>关于 getType、拉取消息的起始消息、拉取消息的时间范围 的使用说明：
 * - getType 可以用来表示拉取的方向：往消息时间更老的方向 或者 往消息时间更新的方向；
 * - lastMsg/lastMsgSeq 用来表示拉取时的起点，第一次拉取时可以不填或者填 0；
 * - getTimeBegin/getTimePeriod 用来表示拉取消息的时间范围，时间范围的起止时间点与拉取方向(getType)有关；
 * - 当起始消息和时间范围都存在时，结果集可理解成：「单独按起始消息拉取的结果」与「单独按时间范围拉取的结果」 取交集；
 * - 当起始消息和时间范围都不存在时，结果集可理解成：从当前会话最新的一条消息开始，按照 getType 所指定的方向和拉取方式拉取。
 */
@property(nonatomic,assign) V2TIMMessageGetType getType;

/// 拉取单聊历史消息
@property(nonatomic,strong) NSString *userID;

/// 拉取群组历史消息
@property(nonatomic,strong) NSString *groupID;

/// 拉取消息数量
@property(nonatomic,assign) NSUInteger count;

/**
 * 拉取消息的起始消息
 *
 * @note 请注意，
 * <p>拉取 C2C 消息，只能使用 lastMsg 作为消息的拉取起点；如果没有指定 lastMsg，默认使用会话的最新消息作为拉取起点。
 * <p>拉取 Group 消息时，除了可以使用 lastMsg 作为消息的拉取起点外，也可以使用 lastMsgSeq 来指定消息的拉取起点，二者的区别在于：
 * - 使用 lastMsg 作为消息的拉取起点时，返回的消息列表里不包含当前设置的 lastMsg；
 * - 使用 lastMsgSeq 作为消息拉取起点时，返回的消息列表里包含当前设置的 lastMsgSeq 所表示的消息。
 *
 * @note 在拉取 Group 消息时，
 * <p>如果同时指定了 lastMsg 和 lastMsgSeq，SDK 优先使用 lastMsg 作为消息的拉取起点。
 * <p>如果 lastMsg 和 lastMsgSeq 都未指定，消息的拉取起点分为如下两种情况：
 * -  如果设置了拉取的时间范围，SDK 会根据 @getTimeBegin 所描述的时间点作为拉取起点；
 * -  如果未设置拉取的时间范围，SDK 默认使用会话的最新消息作为拉取起点。
 */
@property(nonatomic,strong) V2TIMMessage *lastMsg;
@property (nonatomic, assign) NSUInteger lastMsgSeq;

/**
 * 拉取消息的时间范围
 * @getTimeBegin  表示时间范围的起点；默认为 0，表示从现在开始拉取；UTC 时间戳，单位：秒
 * @getTimePeriod 表示时间范围的长度；默认为 0，表示不限制时间范围；单位：秒
 *
 * @note
 * <p> 时间范围的方向由参数 getType 决定
 * <p> 如果 getType 取 V2TIM_GET_CLOUD_OLDER_MSG/V2TIM_GET_LOCAL_OLDER_MSG，表示从 getTimeBegin 开始，过去的一段时间，时间长度由 getTimePeriod 决定
 * <p> 如果 getType 取 V2TIM_GET_CLOUD_NEWER_MSG/V2TIM_GET_LOCAL_NEWER_MSG，表示从 getTimeBegin 开始，未来的一段时间，时间长度由 getTimePeriod 决定
 * <p> 取值范围区间为闭区间，包含起止时间，二者关系如下：
 * - 如果 getType 指定了朝消息时间更老的方向拉取，则时间范围表示为 [getTimeBegin-getTimePeriod, getTimeBegin]
 * - 如果 getType 指定了朝消息时间更新的方向拉取，则时间范围表示为 [getTimeBegin, getTimeBegin+getTimePeriod]
 */
@property (nonatomic, assign) NSUInteger getTimeBegin;
@property (nonatomic, assign) NSUInteger getTimePeriod;



@end

