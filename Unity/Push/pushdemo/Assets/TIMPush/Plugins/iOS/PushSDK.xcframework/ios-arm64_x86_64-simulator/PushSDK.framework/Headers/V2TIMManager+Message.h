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
@class V2TIMMessageExtension;
@class V2TIMMessageExtensionResult;
@class V2TIMMessageReaction;
@class V2TIMMessageReactionResult;
@class V2TIMMessageReactionChangeInfo;
V2TIM_EXPORT @protocol V2TIMAdvancedMsgListener;

V2TIM_EXPORT @interface V2TIMManager (Message)

/////////////////////////////////////////////////////////////////////////////////
//
//                         异步接口的回调 BLOCK
//
/////////////////////////////////////////////////////////////////////////////////

/// 查询历史消息的结果回调（查询接口会批量地返回从某个时间点之前的历史消息）
typedef void (^V2TIMMessageListSucc)(NSArray<V2TIMMessage *> *msgs);
/// 搜索历史消息的结果回调（查询接口支持模糊匹配）
typedef void (^V2TIMSearchMessageListSucc)(V2TIMMessageSearchResult *searchResult);
/// 文件上传进度回调，取值 0 -100
typedef void (^V2TIMProgress)(uint32_t progress);
/// 文件下载进度回调
typedef void (^V2TIMDownLoadProgress)(NSInteger curSize, NSInteger totalSize);
/// 获取消息接收选项的结果回调
typedef void (^V2TIMReceiveMessageOptListSucc)(NSArray<V2TIMReceiveMessageOptInfo *> *optList);
/// 获取全局消息接收选项的结果回调
typedef void (^V2TIMReceiveMessageOptSucc)(V2TIMReceiveMessageOptInfo *optInfo);
/// 获取群消息已读回执的结果回调
typedef void (^V2TIMMessageReadReceiptsSucc)(NSArray<V2TIMMessageReceipt*> *receiptList);
/// 获取群消息已读或未读群成员列表
typedef void (^V2TIMGroupMessageReadMemberListSucc)(NSMutableArray<V2TIMGroupMemberInfo*>* members, uint64_t nextSeq, BOOL isFinished);
/// 消息修改完成回调
typedef void (^V2TIMMessageModifyCompletion)(int code, NSString * desc, V2TIMMessage *msg);
/// 设置消息扩展成功回调
typedef void (^V2TIMMessageExtensionsSetSucc)(NSArray<V2TIMMessageExtensionResult*> *extensionResultList);
/// 获取消息扩展成功回调
typedef void (^V2TIMMessageExtensionsGetSucc)(NSArray<V2TIMMessageExtension*> *extensionList);
/// 删除消息扩展成功回调
typedef void (^V2TIMMessageExtensionsDeleteSucc)(NSArray<V2TIMMessageExtensionResult*> *extensionResultList);
/// 批量拉取消息回应列表成功回调
typedef void (^V2TIMGetMessageReactionsSucc)(NSArray<V2TIMMessageReactionResult *> *resultList);
/// 分页拉取指定消息回应用户列表成功回调（userList：用户列表，只包含昵称、头像信息 nextSeq：下一次分页拉取的游标 isFinished：用户列表是否已经拉取完毕）
typedef void (^V2TIMGetMessageReactionUserListSucc)(NSArray<V2TIMUserInfo *> *userList, uint32_t nextSeq, BOOL isFinished);
/// 获取置顶消息列表成功的回调
typedef void (^V2TIMPinnedMessageListSucc)(NSArray<V2TIMMessage *> * messageList);

/// 在接口 createTextAtMessage 中填入 kMesssageAtALL 表示当前消息需要 @ 群里所有人
V2TIM_EXTERN NSString * const kImSDK_MesssageAtALL;

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
    V2TIM_GROUP_TIPS_TYPE_INVITE              = 0x02,  ///< 被邀请入群（opMember 邀请 memberList 入群，从 8.0 版本开始支持除 AVChatRoom 之外的所有群类型）
    V2TIM_GROUP_TIPS_TYPE_QUIT                = 0x03,  ///< 退出群 (opMember 退出群组)
    V2TIM_GROUP_TIPS_TYPE_KICKED              = 0x04,  ///< 踢出群 (opMember 把 memberList 踢出群组)
    V2TIM_GROUP_TIPS_TYPE_SET_ADMIN           = 0x05,  ///< 设置管理员 (opMember 把 memberList 设置为管理员)
    V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN        = 0x06,  ///< 取消管理员 (opMember 取消 memberList 管理员身份)
    V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE   = 0x07,  ///< 群资料变更 (opMember 修改群资料： groupName & introduction & notification & faceUrl & owner & allMute & custom)
    V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE  = 0x08,  ///< 群成员资料变更 (opMember 修改群成员资料：muteTime)
    V2TIM_GROUP_TIPS_TYPE_TOPIC_INFO_CHANGE   = 0x09,  ///< 话题资料变更 (opMember 修改话题资料：topicName & introduction & notification & faceUrl & allMute & topicCustomData)
    V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_ADDED = 0x0A,  ///< 置顶群消息
    V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_DELETED = 0x0B,///< 取消置顶群消息
};

/// 群变更信息 Tips 类型
typedef NS_ENUM(NSInteger, V2TIMGroupInfoChangeType){
    V2TIM_GROUP_INFO_CHANGE_TYPE_NAME                       = 0x01,  ///< 群名修改
    V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION               = 0x02,  ///< 群简介修改
    V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION               = 0x03,  ///< 群公告修改
    V2TIM_GROUP_INFO_CHANGE_TYPE_FACE                       = 0x04,  ///< 群头像修改
    V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER                      = 0x05,  ///< 群主变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_CUSTOM                     = 0x06,  ///< 群自定义字段变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL                = 0x08,  ///< 全员禁言字段变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_TOPIC_CUSTOM_DATA          = 0x09,  ///< 话题自定义字段变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_RECEIVE_MESSAGE_OPT        = 0x0A,  ///< 消息接收选项变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_ADD_OPT              = 0x0B,  ///< 申请加群方式下管理员审批选项变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_APPROVE_OPT          = 0x0C,  ///< 邀请进群方式下管理员审批选项变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_ENABLE_PERMISSION_GROUP    = 0x0D,  ///< 是否开启权限组功能变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_DEFAULT_PERMISSIONS        = 0x0E,  ///< 群默认权限变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_TOPIC_ADD_OPT              = 0x0F,  ///< 申请加入私密话题时管理员的审批选项变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_TOPIC_APPROVE_OPT          = 0x10,  ///< 邀请进入私密话题时管理员的审批选项变更
    V2TIM_GROUP_INFO_CHANGE_TYPE_TOPIC_MEMBER_MAX_COUNT     = 0x11,  ///< 私密话题最大成员数量
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
    V2TIM_RECEIVE_MESSAGE                      = 0,  ///< 在线正常接收消息，离线时会进行 APNs 推送
    V2TIM_NOT_RECEIVE_MESSAGE                  = 1,  ///< 在线不会接收到消息，离线不会有推送通知
    V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE           = 2,  ///< 在线正常接收消息，离线不会有推送通知
    V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE_EXCEPT_AT = 3,  ///< 在线接收消息，离线只接收 @ 消息的推送
    V2TIM_NOT_RECEIVE_MESSAGE_EXCEPT_AT        = 4,  ///< 在线和离线都只接收 @ 消息
};

/// 群消息已读成员列表过滤类型
typedef NS_ENUM(NSInteger, V2TIMGroupMessageReadMembersFilter) {
    V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ   = 0,  ///< 群消息已读成员列表
    V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_UNREAD = 1,  ///< 群消息未读成员列表
};

/// iOS 离线推送的类型
typedef NS_ENUM(NSInteger, V2TIMIOSOfflinePushType) {
    V2TIM_IOS_OFFLINE_PUSH_TYPE_APNS               = 0,  ///< 普通的 APNs 推送
    V2TIM_IOS_OFFLINE_PUSH_TYPE_VOIP               = 1,  ///< VoIP 推送
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
 *  2.1 创建文本消息（最大支持 12KB）
 */
- (V2TIMMessage *)createTextMessage:(NSString *)text NS_SWIFT_NAME(createTextMessage(text:));

/**
 *  2.2 创建文本消息，并且可以附带 @ 提醒功能（最大支持 12KB）
 *
 *  提醒消息仅适用于在群组中发送的消息
 *
 *  @param atUserList 需要 @ 的用户列表，如果需要 @ALL，请传入 kImSDK_MesssageAtALL 常量字符串。
 *  举个例子，假设该条文本消息希望@提醒 denny 和 lucy 两个用户，同时又希望@所有人，atUserList 传 @[@"denny",@"lucy",kImSDK_MesssageAtALL]
 *
 *  @note atUserList 使用注意事项
 *  - 默认情况下，最多支持 @ 30个用户，超过限制后，消息会发送失败。
 *  - atUserList 的总数不能超过默认最大数，包括 @ALL。
 *  - 直播群（AVChatRoom）不支持发送 @ 消息。
 */
- (V2TIMMessage *)createTextAtMessage:(NSString *)text atUserList:(NSMutableArray<NSString *> *)atUserList NS_SWIFT_NAME(createTextAtMessage(text:atUserList:)) __attribute__((deprecated("use createAtSignedGroupMessage:atUserList: instead")));

/**
 *  2.3 创建自定义消息（最大支持 12KB）
 */
- (V2TIMMessage *)createCustomMessage:(NSData *)data NS_SWIFT_NAME(createCustomMessage(data:));

/**
 *  2.4 创建自定义消息（最大支持 12KB）
 *
 *  @param desc 自定义消息描述信息，做离线Push时文本展示。
 *  @param extension 离线Push时扩展字段信息。
 */
- (V2TIMMessage *)createCustomMessage:(NSData *)data desc:(NSString * _Nullable)desc extension:(NSString * _Nullable)extension NS_SWIFT_NAME(createCustomMessage(data:desc:ext:));

/**
 *  2.5 创建图片消息（图片文件最大支持 28 MB）
 *
 *  @note 如果是系统相册拿的图片，需要先把图片导入 APP 的目录下，具体请参考 Demo TUIChatController -> imagePickerController 代码示例
 */
- (V2TIMMessage *)createImageMessage:(NSString *)imagePath NS_SWIFT_NAME(createImageMessage(imagePath:));

/**
 *  2.6 创建语音消息（语音文件最大支持 28 MB）
 *
 *  @param duration 音频时长，单位 s
 */
- (V2TIMMessage *)createSoundMessage:(NSString *)audioFilePath duration:(int)duration NS_SWIFT_NAME(createSoundMessage(audioFilePath:duration:));

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
                        snapshotPath:(NSString *)snapshotPath NS_SWIFT_NAME(createVideoMessage(videoFilePath:type:duration:snapshotPath:));

/**
 *  2.8 创建文件消息（文件最大支持 100 MB）
 */
- (V2TIMMessage *)createFileMessage:(NSString *)filePath fileName:(NSString *)fileName NS_SWIFT_NAME(createFileMessage(filePath:fileName:));

/**
 *  2.9 创建地理位置消息
 */
- (V2TIMMessage *)createLocationMessage:(NSString * _Nullable)desc longitude:(double)longitude latitude:(double)latitude NS_SWIFT_NAME(createLocationMessage(desc:longitude:latitude:));

/**
 *  2.10 创建表情消息
 *
 *  SDK 并不提供表情包，如果开发者有表情包，可使用 index 存储表情在表情包中的索引，或者使用 data 存储表情映射的字符串 key，这些都由用户自定义，SDK 内部只做透传。
 *
 *  @param index 表情索引
 *  @param data 自定义数据
 */
- (V2TIMMessage *)createFaceMessage:(int)index data:(NSData * _Nullable)data NS_SWIFT_NAME(createFaceMessage(index:data:));

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
- (V2TIMMessage * _Nullable)createMergerMessage:(NSArray<V2TIMMessage *> *)messageList
                                title:(NSString * _Nullable)title
                         abstractList:(NSArray<NSString *> *)abstractList
                       compatibleText:(NSString *)compatibleText NS_SWIFT_NAME(createMergerMessage(messageList:title:abstractList:compatibleText:));

/**
 *  2.12 创建转发消息（5.2.210 及以上版本支持）
 *
 *  如果需要转发一条消息，不能直接调用 sendMessage 接口发送原消息，需要先 createForwardMessage 创建一条转发消息再发送。
 *
 *  @param message 待转发的消息对象，消息状态必须为 V2TIM_MSG_STATUS_SEND_SUCC，消息类型不能为 V2TIMGroupTipsElem。
 *  @return 转发消息对象，elem 内容和原消息完全一致。
 */
- (V2TIMMessage * _Nullable)createForwardMessage:(V2TIMMessage *)message NS_SWIFT_NAME(createForwardMessage(message:));

/**
 *  2.13 创建定向群消息（6.0 及以上版本支持）
 *
 *  如果您需要在群内给指定群成员列表发消息，可以创建一条定向群消息，定向群消息只有指定群成员才能收到。
 *
 *  @param message 原始消息对象
 *  @param receiverList 消息接收者列表
 *  @return 定向群消息对象
 *
 * @note
 * - 原始消息对象不支持群 @ 消息。
 * - 消息接收者列表最大支持 50 个。
 * - 直播群（AVChatRoom）不支持发送定向群消息。
 * - 定向群消息默认不计入群会话的未读计数。
 */
- (V2TIMMessage * _Nullable)createTargetedGroupMessage:(V2TIMMessage *)message receiverList:(NSMutableArray<NSString *> *)receiverList NS_SWIFT_NAME(createTargetedGroupMessage(message:receiverList:));

/**
 *  2.14 创建带 @ 标记的群消息（7.0 及以上版本支持）
 *
 *  如果您需要发送的群消息附带 @ 提醒功能，可以创建一条带 @ 标记的群消息。
 *
 *  @param message 原始消息对象
 *  @param atUserList 需要 @ 的用户列表，如果需要 @ALL，请传入 kImSDK_MesssageAtALL 常量字符串。
 *  举个例子，假设该条消息希望@提醒 denny 和 lucy 两个用户，同时又希望@所有人，atUserList 传 @[@"denny",@"lucy",kImSDK_MesssageAtALL]
 *  @return 群 @ 消息对象
 *
 *  @note atUserList 使用注意事项
 *  - 默认情况下，最多支持 @ 30个用户，超过限制后，消息会发送失败。
 *  - atUserList 的总数不能超过默认最大数，包括 @ALL。
 *  - 直播群（AVChatRoom）不支持发送 @ 消息。
 */
- (V2TIMMessage *)createAtSignedGroupMessage:(V2TIMMessage *)message atUserList:(NSMutableArray<NSString *> *)atUserList NS_SWIFT_NAME(createAtSignedGroupMessage(message:atUserList:));

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
 *  - 6.0 及以上版本支持定向群消息，如果 groupID 和 receiver 同时设置，表示给 receiver 发送定向群消息，如果要给多个 receiver 发送定向群消息，需要先调用 createTargetedGroupMessage 接口创建定向群消息后再发送。
 *  - 如果需要消息离线推送，请先在 V2TIMManager+APNS.h 开启推送，推送开启后，除了自定义消息，其他消息默认都会推送。
 *  - 如果自定义消息也需要推送，请设置 offlinePushInfo 的 desc 字段，设置成功后，推送的时候会默认展示 desc 信息。
 *  - AVChatRoom 群聊不支持 onlineUserOnly 字段，如果是 AVChatRoom 请将该字段设置为 NO。
 *  - 如果设置 onlineUserOnly 为 YES 时，该消息为在线消息且不会被计入未读计数。
 */
- (NSString * _Nullable)sendMessage:(V2TIMMessage *)message
                 receiver:(NSString * _Nullable)receiver
                  groupID:(NSString * _Nullable)groupID
                 priority:(V2TIMMessagePriority)priority
           onlineUserOnly:(BOOL)onlineUserOnly
          offlinePushInfo:(V2TIMOfflinePushInfo * _Nullable)offlinePushInfo
                 progress:(_Nullable V2TIMProgress)progress
                     succ:(_Nullable V2TIMSucc)succ
                     fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(sendMessage(message:receiver:groupID:priority:onlineUserOnly:offlinePushInfo:progress:succ:fail:));

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
                           succ:(_Nullable V2TIMSucc)succ
                           fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setC2CReceiveMessageOpt(userIDList:opt:succ:fail:));

/**
 *  4.2 查询针对某个用户的 C2C 消息接收选项
 *  <p>5.3.425 及以上版本支持
 */
- (void)getC2CReceiveMessageOpt:(NSArray<NSString *> *)userIDList
                           succ:(V2TIMReceiveMessageOptListSucc)succ
                           fail:(V2TIMFail)fail NS_SWIFT_NAME(getC2CReceiveMessageOpt(userIDList:succ:fail:));

/**
 *  4.3 设置群消息的接收选项
 */
- (void)setGroupReceiveMessageOpt:(NSString*)groupID 
                              opt:(V2TIMReceiveMessageOpt)opt
                             succ:(_Nullable V2TIMSucc)succ
                             fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setGroupReceiveMessageOpt(groupID:opt:succ:fail:));

/**
 * 4.4 设置全局消息接收选项，从 7.4 版本开始支持。
 *
 * @param opt 全局消息接收选项，支持两种取值：
 *              V2TIMReceiveMessageOpt.V2TIM_RECEIVE_MESSAGE：在线正常接收消息，离线时会有厂商的离线推送通知，默认为该选项
 *              V2TIMReceiveMessageOpt.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE：在线正常接收消息，离线不会有推送通知，可用于实现消息免打扰功能
 * @param startHour   免打扰开始时间：小时，取值范围[0 - 23]
 * @param startMinute 免打扰开始时间：分钟，取值范围[0 - 59]
 * @param startSecond 免打扰开始时间：秒，取值范围[0 - 59]
 * @param duration    免打扰持续时长：单位：秒，取值范围 [0 - 24*60*60].
 *
 * @note
 *  - 当 duration 的取值小于 24*60*60 时，可用于实现重复免打扰，即消息免打扰从每天的 startHour:startMinute:startSecond 表示的时间点开始，持续时长为 druation 秒
 *  - 当 duration 取值不小于 24*60*60 时，可用于实现永久免打扰，即从调用该 API 当天 startHour:startMinute:startSecond 表示的时间点开始永久消息免打扰
 */
- (void)setAllReceiveMessageOpt:(V2TIMReceiveMessageOpt) opt
                      startHour:(int32_t)startHour
                    startMinute:(int32_t) startMinute
                    startSecond:(int32_t) startSecond
                       duration:(uint32_t) duration
                           succ:(_Nullable V2TIMSucc)succ
                           fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setAllReceiveMessageOpt(opt:startHour:startMinute:startSecond:duration:succ:fail:));

/**
 * 4.5 设置全局消息接收选项，从 7.4 版本开始支持。
 *
 * @param opt 全局消息接收选项，支持两种取值：
 *              V2TIMReceiveMessageOpt.V2TIM_RECEIVE_MESSAGE：在线正常接收消息，离线时会有厂商的离线推送通知，默认为该选项
 *              V2TIMReceiveMessageOpt.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE：在线正常接收消息，离线不会有推送通知，可用于实现消息免打扰功能
 * @param startTimeStamp 免打扰开始时间，UTC 时间戳，单位：秒
 * @param duration       免打扰持续时长，单位：秒
 *
 */
- (void)setAllReceiveMessageOpt:(V2TIMReceiveMessageOpt) opt
                 startTimeStamp:(uint32_t) startTimeStamp
                       duration:(uint32_t) duration
                           succ:(_Nullable V2TIMSucc)succ
                           fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setAllReceiveMessageOpt(opt:startTimeStamp:duration:succ:fail:));

/**
 *  4.6 获取登录用户全局消息接收选项，从 7.3 版本开始支持
 *
 */
- (void)getAllReceiveMessageOpt:(V2TIMReceiveMessageOptSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getAllReceiveMessageOpt(succ:fail:));

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
 *  @note 
 *  - 如果没有触发登录，调用该接口不会返回历史消息
 *  - 如果登录失败，调用该接口会返回本地历史消息
 *  - 如果 SDK 检测到没有网络，调用该接口会返回本地历史消息
 *  - 如果登录成功且网络正常，调用该接口会先请求云端历史消息，然后再和本地历史消息合并后返回
 */
- (void)getC2CHistoryMessageList:(NSString *)userID count:(int)count lastMsg:(V2TIMMessage * _Nullable)lastMsg succ:(V2TIMMessageListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getC2CHistoryMessageList(userID:count:lastMsg:succ:fail:));

/**
 *  5.2 获取群组历史消息
 *
 *  @param count 拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
 *  @param lastMsg 获取消息的起始消息，如果传 nil，起始消息为会话的最新消息
 *
 *  @note
 *  - 如果没有触发登录，调用该接口不会返回历史消息
 *  - 如果登录失败，调用该接口会返回本地历史消息
 *  - 如果 SDK 检测到没有网络，调用该接口会返回本地历史消息
 *  - 如果登录成功且网络正常，调用该接口会先请求云端历史消息，然后再和本地历史消息合并后返回
 *  - 只有会议群（Meeting）才能拉取到进群前的历史消息，直播群（AVChatRoom）消息不存漫游和本地数据库，调用这个接口无效
 */
- (void)getGroupHistoryMessageList:(NSString *)groupID count:(int)count lastMsg:(V2TIMMessage * _Nullable)lastMsg succ:(V2TIMMessageListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getGroupHistoryMessageList(groupID:count:lastMsg:succ:fail:));

/**
 *  5.3 获取历史消息高级接口
 *
 *  @param option 拉取消息选项设置，可以设置从云端、本地拉取更老或更新的消息
 *
 *  @note
 *  - 如果没有触发登录，调用该接口不会返回历史消息
 *  - 如果登录失败，调用该接口会返回本地历史消息
 *  - 如果 SDK 检测到没有网络，调用该接口会返回本地历史消息
 *  - 如果登录成功且网络正常，当 option 设置为拉取云端历史消息，调用该接口会先请求云端历史消息，然后再和本地历史消息合并后返回
 *  - 只有会议群（Meeting）才能拉取到进群前的历史消息，直播群（AVChatRoom）消息不存漫游和本地数据库，调用这个接口无效
 */
- (void)getHistoryMessageList:(V2TIMMessageListGetOption *)option succ:(V2TIMMessageListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getHistoryMessageList(option:succ:fail:));

/**
 *  5.4 撤回消息
 *
 *  @note
    - 撤回消息的时间限制默认 2 minutes，超过 2 minutes 的消息不能撤回，您也可以在 [控制台](https://console.cloud.tencent.com/im)（功能配置 -> 登录与消息 -> 消息撤回设置）自定义撤回时间限制。
 *  - 仅支持单聊和群组中发送的普通消息，无法撤销 onlineUserOnly 为 true 即仅在线用户才能收到的消息。
 *  - 如果发送方撤回消息，已经收到消息的一方会收到 V2TIMAdvancedMsgListener -> onRecvMessageRevoked 回调。
 *  - 从 IMSDK 7.4 版本开始，支持撤回包括直播群（AVChatRoom）、社群在内的所有群类型的消息。
 *  - 在单聊场景中，仅能撤回自己的消息；在群聊场景中，除了可以撤回自己的消息外，管理员或者群主也可以撤回其他群成员的消息。
 */
- (void)revokeMessage:(V2TIMMessage *)msg succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(revokeMessage(msg:succ:fail:));

/**
 *  5.5 消息变更
 *
 *  @note
 *  - 如果消息修改成功，自己和对端用户（C2C）或群组成员（Group）都会收到 onRecvMessageModified 回调。
 *  - 如果在修改消息过程中，消息已经被其他人修改，completion 会返回 ERR_SDK_MSG_MODIFY_CONFLICT 错误。
 *  - 消息无论修改成功或则失败，completion 都会返回最新的消息对象。
 */
- (void)modifyMessage:(V2TIMMessage *)msg completion:(V2TIMMessageModifyCompletion)completion NS_SWIFT_NAME(modifyMessage(msg:completion:));

/**
 *  5.6 删除本地消息
 *
 *  @note 该接口只能删除本地历史，消息删除后，SDK 会在本地把这条消息标记为已删除状态，getHistoryMessage 不能再拉取到，如果程序卸载重装，本地会失去对这条消息的删除标记，getHistoryMessage 还能再拉取到该条消息。
 */
- (void)deleteMessageFromLocalStorage:(V2TIMMessage *)msg succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(deleteMessageFromLocalStorage(msg:succ:fail:));

/**
 *  5.7 删除本地及云端的消息
 *
 *  @note 该接口会在 deleteMessageFromLocalStorage 的基础上，同步删除云端存储的消息，且无法恢复。需要注意的是：
 *  - 一次最多只能删除 50 条消息
 *  - 要删除的消息必须属于同一会话
 *  - 一秒钟最多只能调用一次该接口
 *  - 如果该账号在其他设备上拉取过这些消息，那么调用该接口删除后，这些消息仍然会保存在那些设备上，即删除消息不支持多端同步。
 */
- (void)deleteMessages:(NSArray<V2TIMMessage *>*)msgList succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(deleteMessages(msgList:succ:fail:));

/**
 *  5.8 清空单聊本地及云端的消息（不删除会话）
 * <p>5.4.666 及以上版本支持
 *
 * @note
 * - 会话内的消息在本地删除的同时，在服务器也会同步删除。
 */
- (void)clearC2CHistoryMessage:(NSString *)userID succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(clearC2CHistoryMessage(userID:succ:fail:));

/**
 *  5.9 清空群聊本地及云端的消息（不删除会话）
 * <p>5.4.666 及以上版本支持
 *
 * @note
 * - 会话内的消息在本地删除的同时，在服务器也会同步删除。
 */
- (void)clearGroupHistoryMessage:(NSString *)groupID succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(clearGroupHistoryMessage(groupID:succ:fail:));

/**
 *  5.10 向群组消息列表中添加一条消息
 *
 *  该接口主要用于满足向群组聊天会话中插入一些提示性消息的需求，比如“您已经退出该群”，这类消息有展示
 *  在聊天消息区的需求，但并没有发送给其他人的必要。
 *  所以 insertGroupMessageToLocalStorage() 相当于一个被禁用了网络发送能力的 sendMessage() 接口。
 *
 *  @return msgID 消息唯一标识
 *  @note 通过该接口 save 的消息只存本地，程序卸载后会丢失。
 */
- (NSString *)insertGroupMessageToLocalStorage:(V2TIMMessage *)msg to:(NSString *)groupID sender:(NSString *)sender succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(insertGroupMessageToLocalStorage(msg:to:sender:succ:fail:));

/**
 *  5.11 向C2C消息列表中添加一条消息
 *
 *  该接口主要用于满足向C2C聊天会话中插入一些提示性消息的需求，比如“您已成功发送消息”，这类消息有展示
 *  在聊天消息区的需求，但并没有发送给对方的必要。
 *  所以 insertC2CMessageToLocalStorage()相当于一个被禁用了网络发送能力的 sendMessage() 接口。
 *
 *  @return msgID 消息唯一标识
 *  @note 通过该接口 save 的消息只存本地，程序卸载后会丢失。
 */
- (NSString *)insertC2CMessageToLocalStorage:(V2TIMMessage *)msg to:(NSString *)userID sender:(NSString *)sender succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(insertC2CMessageToLocalStorage(msg:to:sender:succ:fail:));

/**
 *  5.12 根据 messageID 查询指定会话中的本地消息，包括状态 status 为 V2TIM_MSG_STATUS_LOCAL_REVOKED（已撤回）和 V2TIM_MSG_STATUS_HAS_DELETED（已删除）的消息
 *  @param messageIDList 消息 ID 列表
 *  @note 通过 V2TIMMessage 的 status 来区分消息的状态
 */
- (void)findMessages:(NSArray<NSString *>*)messageIDList succ:(V2TIMMessageListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(findMessages(messageIDList:succ:fail:));

/**
 * 5.13 搜索本地消息（5.4.666 及以上版本支持，需要您购买旗舰版套餐）
 * @param param 消息搜索参数，详见 V2TIMMessageSearchParam 的定义
 * @note 返回的列表不包含消息状态 status 为 V2TIM_MSG_STATUS_LOCAL_REVOKED（已撤回）和 V2TIM_MSG_STATUS_HAS_DELETED（已删除）的消息
 */
- (void)searchLocalMessages:(V2TIMMessageSearchParam *)param succ:(V2TIMSearchMessageListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(searchLocalMessages(param:succ:fail:));

/**
 * 5.14 搜索云端消息（7.3 及以上版本支持）
 * @param param 消息搜索参数，详见 V2TIMMessageSearchParam 的定义
 * @note
 * - 该功能为 IM 增值功能，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17176#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)
 * - 如果您没有开通该服务，调用接口会返回 60020 错误码
 * -返回的列表不包含消息状态 status 为 V2TIM_MSG_STATUS_LOCAL_REVOKED（已撤回）和 V2TIM_MSG_STATUS_HAS_DELETED（已删除）的消息
 */
- (void)searchCloudMessages:(V2TIMMessageSearchParam *)param succ:(V2TIMSearchMessageListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(searchCloudMessages(param:succ:fail:));

/**
 * 5.15 发送消息已读回执 （6.1 及其以上版本支持）
 *
 * @note
 * - 该功能为旗舰版功能，[购买旗舰版套餐包](https://buy.cloud.tencent.com/avc?from=17485)后可使用，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17221#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)。
 * - 向群消息发送已读回执，需要您先到控制台打开对应的开关，详情参考文档 [群消息已读回执](https://cloud.tencent.com/document/product/269/75343#.E8.AE.BE.E7.BD.AE.E6.94.AF.E6.8C.81.E5.B7.B2.E8.AF.BB.E5.9B.9E.E6.89.A7.E7.9A.84.E7.BE.A4.E7.B1.BB.E5.9E.8B) 。
 * - messageList 里的消息必须在同一个会话中。
 * - 该接口调用成功后，会话未读数不会变化，消息发送者会收到 onRecvMessageReadReceipts 回调，回调里面会携带消息的最新已读信息。
 */
- (void)sendMessageReadReceipts:(NSArray<V2TIMMessage *>*)messageList succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(sendMessageReadReceipts(messageList:succ:fail:));

/**
 * 5.16 获取消息已读回执（6.1 及其以上版本支持）
 * @param messageList 消息列表
 *
 * @note ：
 * - 该功能为旗舰版功能，[购买旗舰版套餐包](https://buy.cloud.tencent.com/avc?from=17485)后可使用，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17221#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)。
 * - 获取群消息已读回执，需要您先到控制台打开对应的开关，详情参考文档 [群消息已读回执](https://cloud.tencent.com/document/product/269/75343#.E8.AE.BE.E7.BD.AE.E6.94.AF.E6.8C.81.E5.B7.B2.E8.AF.BB.E5.9B.9E.E6.89.A7.E7.9A.84.E7.BE.A4.E7.B1.BB.E5.9E.8B) 。
 * - messageList 里的消息必须在同一个会话中。
 */
- (void)getMessageReadReceipts:(NSArray<V2TIMMessage *>*)messageList succ:(V2TIMMessageReadReceiptsSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getMessageReadReceipts(messageList:succ:fail:));

/**
 * 5.17 获取群消息已读群成员列表（6.1 及其以上版本支持）
 * @param message 群消息
 * @param filter  指定拉取已读或未读群成员列表。
 * @param nextSeq 分页拉取的游标，第一次默认取传 0，后续分页拉传上一次分页拉取成功回调里的 nextSeq。
 * @param count   分页拉取的个数，最大支持 100 个。
 *
 * @note
 * - 该功能为旗舰版功能，[购买旗舰版套餐包](https://buy.cloud.tencent.com/avc?from=17485)后可使用，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17221#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)。
 * - 使用该功能之前，请您先到控制台打开对应的开关，详情参考文档 [群消息已读回执](https://cloud.tencent.com/document/product/269/75343#.E8.AE.BE.E7.BD.AE.E6.94.AF.E6.8C.81.E5.B7.B2.E8.AF.BB.E5.9B.9E.E6.89.A7.E7.9A.84.E7.BE.A4.E7.B1.BB.E5.9E.8B) 。
 */
- (void)getGroupMessageReadMemberList:(V2TIMMessage*)message filter:(V2TIMGroupMessageReadMembersFilter)filter nextSeq:(uint64_t)nextSeq count:(uint32_t)count succ:(V2TIMGroupMessageReadMemberListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getGroupMessageReadMemberList(message:filter:nextSeq:count:succ:fail:));

/**
 * 5.18 设置消息扩展（6.7 及其以上版本支持，需要您购买旗舰版套餐）
 * @param message 消息对象，消息需满足三个条件：1、消息发送前需设置 supportMessageExtension 为 YES，2、消息必须是发送成功的状态，3、消息不能是直播群（AVChatRoom）消息。
 * @param extensions 扩展信息，如果扩展 key 已经存在，则修改扩展的 value 信息，如果扩展 key 不存在，则新增扩展。
 *
 * @note
 * - 扩展 key 最大支持 100 字节，扩展 value 最大支持 1KB，单次最多支持设置 20 个扩展，单条消息最多可设置 300 个扩展。
 * - 当多个用户同时设置或删除同一个扩展 key 时，只有第一个用户可以执行成功，其它用户会收到 23001 错误码和最新的扩展信息，在收到错误码和扩展信息后，请按需重新发起设置操作。
 * - 我们强烈建议不同的用户设置不同的扩展 key，这样大部分场景都不会冲突，比如投票、接龙、问卷调查，都可以把自己的 userID 作为扩展 key。
 */
- (void)setMessageExtensions:(V2TIMMessage*)message extensions:(NSArray<V2TIMMessageExtension *> *)extensions succ:(V2TIMMessageExtensionsSetSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(setMessageExtensions(message:extensions:succ:fail:));

/**
 * 5.19 获取消息扩展（6.7 及其以上版本支持，需要您购买旗舰版套餐）
 */
- (void)getMessageExtensions:(V2TIMMessage*)message succ:(V2TIMMessageExtensionsGetSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getMessageExtensions(message:succ:fail:));

/**
 * 5.20 删除消息扩展（6.7 及其以上版本支持，需要您购买旗舰版套餐）
 * @param keys 消息扩展 key 列表, 单次最大支持删除 20 个消息扩展，如果设置为 nil ，表示删除所有消息扩展
 *
 * @note
 * - 当多个用户同时设置或删除同一个扩展 key 时，只有第一个用户可以执行成功，其它用户会收到 23001 错误码和最新的扩展信息，在收到错误码和扩展信息后，请按需重新发起删除操作。
 */
- (void)deleteMessageExtensions:(V2TIMMessage*)message keys:(NSArray<NSString *> * _Nullable)keys succ:(V2TIMMessageExtensionsDeleteSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(deleteMessageExtensions(message:keys:succ:fail:));

/**
 * 5.21 添加消息回应（可以用于实现表情回应）（7.4 及其以上版本支持，需要您购买旗舰版套餐）
 *
 *  <p> 表情回应功能是指对某条消息通过表情符号进行互动回应，我们可以看到每种表情的回应人数和回应人列表。
 *  <p> 目前常见的消息回应展示方式会有如下两种风格：
 *  <p> 风格一：
 *  <p>  ----------------------------
 *  <p> |   lucy, happy birthday!    |
 *  <p>  ----------------------------
 *  <p> |   😄 1  💐 2  👍🏻 10        |
 *  <p>  ----------------------------
 *  <p> 风格二：
 *  <p>  ------------------------------------------------
 *  <p> |   lucy, happy birthday!                        |
 *  <p>  ------------------------------------------------
 *  <p> |  😁 bob 💐olivia 🎂david                       |
 *  <p> |  👍🏻 denny、james、lucy、linda、thomas 等10人     |
 *  <p>  ------------------------------------------------
 *  <p>
 *  <p> 当用户点击某个表情后，会跳转到表情回应详情界面：
 *  <p>  |  😄   |   💐    |   👍🏻   |
 *  <p>  |  bob  |  olivia |  lucy   |
 *  <p>  |  ...  |   ...   |  denny  |
 *  <p>  |  ...  |   ...   |  ...    |
 *  <p> 用户可以根据某个表情分页拉取使用该表情的用户信息。
 *  <p>
 *  <p> 您可以基于 SDK API 实现表情回应能力:
 *  <p> 1、调用 addMessageReaction    接口为一条消息添加一个 emoji，添加成功后，emoji 下就会存储当前操作用户。
 *  <p> 2、调用 removeMessageReaction 接口删除已经添加的 emoji，删除成功后，emoji 下就不再存储当前操作用户。
 *  <p> 3、调用 getMessageReactions   接口批量拉取多条消息的 emoji 列表，其中每个 emoji 都包含了当前使用者总人数以及前 N（默认 10）个使用者用户资料。
 *  <p> 4、调用 getAllUserListOfMessageReaction 接口分页拉取消息 emoji 的全量使用者用户资料。
 *  <p> 5、监听 onRecvMessageReactionsChanged 回调，感知 emoji 的使用者信息变更，该回调会携带 emoji 最新的使用者信息（包含使用者总人数以及前 N 个使用者用户资料）。
 *  <p>
 *
 * @param reactionID 消息回应 ID，在表情回应场景，reactionID 为表情 ID，单条消息最大支持 10 个 Reaction，单个 Reaction 最大支持 100 个用户。
 *
 * @note
 * - 该功能为旗舰版功能，需要您购买旗舰版套餐。
 * - 如果单条消息 Reaction 数量超过最大限制，调用接口会报 ERR_SVR_MSG_REACTION_COUNT_LIMIT 错误。
 * - 如果单个 Reaction 用户数量超过最大限制，调用接口会报 ERR_SVR_MSG_REACTION_USER_COUNT_LIMIT 错误。
 * - 如果 Reaction 已经包含当前用户，调用接口会报 ERR_SVR_MSG_REACTION_ALREADY_CONTAIN_USER 错误。
 */
- (void)addMessageReaction:(V2TIMMessage *)message reactionID:(NSString *)reactionID succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(addMessageReaction(message:reactionID:succ:fail:));

/**
 * 5.22 删除消息回应（7.4 及其以上版本支持，需要您购买旗舰版套餐）
 *
 * @note
 * - 如果 Reaction 不存在，调用接口会报 ERR_SVR_MSG_REACTION_NOT_EXISTS 错误。
 * - 如果 Reaction 不包含当前用户，调用接口会报 ERR_SVR_MSG_REACTION_NOT_CONTAIN_USER 错误。
 *
 */
- (void)removeMessageReaction:(V2TIMMessage *)message reactionID:(NSString *)reactionID succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(removeMessageReaction(message:reactionID:succ:fail:));

/**
 * 5.23 批量拉取多条消息回应信息（7.4 及其以上版本支持，需要您购买旗舰版套餐）
 *
 * @param messageList 消息列表，一次最大支持 20 条消息，消息必须属于同一个会话。
 * @param maxUserCountPerReaction 取值范围 【0,10】，每个 Reaction 最多只返回前 10 个用户信息，如需更多用户信息，可以按需调用 getAllUserListOfMessageReaction 接口分页拉取。
 *
 */
- (void)getMessageReactions:(NSArray<V2TIMMessage *> *)messageList maxUserCountPerReaction:(uint32_t)maxUserCountPerReaction succ:(V2TIMGetMessageReactionsSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getMessageReactions(messageList:maxUserCountPerReaction:succ:fail:));

/**
 * 5.24 分页拉取使用指定消息回应用户信息（7.4 及其以上版本支持，需要您购买旗舰版套餐）
 *
 * @param message 消息对象
 * @param reactionID 消息回应 ID
 * @param nextSeq 分页拉取的游标，第一次传 0，后续分页传 succ 返回的 nextSeq。
 * @param count 一次分页最大拉取个数，最大支持 100 个。
 *
 */
- (void)getAllUserListOfMessageReaction:(V2TIMMessage *)message reactionID:(NSString *)reactionID nextSeq:(uint32_t)nextSeq count:(uint32_t)count succ:(V2TIMGetMessageReactionUserListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getAllUserListOfMessageReaction(message:reactionID:nextSeq:count:succ:fail:));

/**
 *  5.25 翻译文本消息
 *
 *  @param sourceTextList 待翻译文本数组。
 *  @param source 源语言。可以设置为特定语言或 ”auto“。“auto“ 表示自动识别源语言。传空默认为 ”auto“。
 *  @param target 目标语言。支持的目标语言有多种，例如：英语-“en“，简体中文-”zh“，法语-”fr“，德语-”de“等。详情请参考文档：[文本翻译语言支持](https://cloud.tencent.com/document/product/269/85380#.E6.96.87.E6.9C.AC.E7.BF.BB.E8.AF.91.E8.AF.AD.E8.A8.80.E6.94.AF.E6.8C.81)。
 *  @param callback 翻译结果回调。其中 result 的 key 为待翻译文本, value 为翻译后文本。
 */
- (void)translateText:(NSArray<NSString *> *)sourceTextList
       sourceLanguage:(NSString *)source
       targetLanguage:(NSString *)target
           completion:(void (^)(int code, NSString *desc, NSDictionary<NSString *, NSString *> *result))callback NS_SWIFT_NAME(translateText(sourceTextList:sourceLanguage:targetLanguage:completion:));

/**
 * 5.26 设置群消息置顶（7.9 及以上版本支持，需要您购买旗舰版套餐）
 * @param groupID 群 ID
 * @param isPinned 是否置顶
 *
 * @note
 * - 最多支持置顶10条消息。
 * - 此接口用于置顶和取消置顶对应的群消息，如果置顶消息数量超出限制sdk会返回错误码10070。
 */
- (void)pinGroupMessage:(NSString *)groupID message:(V2TIMMessage *)message isPinned:(BOOL)isPinned succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(pinGroupMessage(groupID:message:isPinned:succ:fail:));

/**
 * 5.27 获取已置顶的群消息列表（7.9 及以上版本支持，需要您购买旗舰版套餐）
 * @param groupID 群 ID
 *
 * @note
 * - 此接口用于获取置顶消息列表，如果置顶消息已过期不会返回
 */
- (void)getPinnedGroupMessageList:(NSString *)groupID succ:(V2TIMPinnedMessageListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getPinnedGroupMessageList(groupID:succ:fail:));

/**
 *  5.28 标记单聊会话已读（待废弃接口，请使用 cleanConversationUnreadMessageCount 接口）
 *
 *  @note
 *  - 该接口调用成功后，自己的未读数会清 0，对端用户会收到 onRecvC2CReadReceipt 回调，回调里面会携带标记会话已读的时间。
 *  - 从 5.8 版本开始，当 userID 为 nil 时，标记所有单聊会话为已读状态。
 */
- (void)markC2CMessageAsRead:(NSString *)userID succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail __attribute__((deprecated("use cleanConversationUnreadMessageCount: instead")));

/**
 *  5.29 标记群组会话已读（待废弃接口，请使用 cleanConversationUnreadMessageCount 接口）
 *
 *  @note
 *  - 该接口调用成功后，自己的未读数会清 0。
 *  - 从 5.8 版本开始，当 groupID 为 nil 时，标记所有群组会话为已读状态。
 */
- (void)markGroupMessageAsRead:(NSString *)groupID succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail __attribute__((deprecated("use cleanConversationUnreadMessageCount: instead")));

/**
 *  5.30 标记所有会话为已读（待废弃接口，请使用 cleanConversationUnreadMessageCount 接口）
 */
- (void)markAllMessageAsRead:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail __attribute__((deprecated("use cleanConversationUnreadMessageCount: instead")));

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         高级消息监听器
//
/////////////////////////////////////////////////////////////////////////////////
/// 高级消息监听器
V2TIM_EXPORT @protocol V2TIMAdvancedMsgListener <NSObject>
@optional
/// 收到新消息
- (void)onRecvNewMessage:(V2TIMMessage *)msg NS_SWIFT_NAME(onRecvNewMessage(msg:));

/// 消息已读回执通知（如果自己发的消息支持已读回执，消息接收端调用了 sendMessageReadReceipts 接口，自己会收到该回调）
- (void)onRecvMessageReadReceipts:(NSArray<V2TIMMessageReceipt *> *)receiptList NS_SWIFT_NAME(onRecvMessageReadReceipts(receiptList:));

/// 如果对端用户调用 cleanConversationUnreadMessageCount 接口清理 C2C 未读消息数，自己会收到该回调，回调只会携带对端 userID 和对端清理 C2C 未读数的时间
- (void)onRecvC2CReadReceipt:(NSArray<V2TIMMessageReceipt *> *)receiptList NS_SWIFT_NAME(onRecvC2CReadReceipt(receiptList:));

/// 收到消息撤回（从 IMSDK 7.4 版本开始支持）
- (void)onRecvMessageRevoked:(NSString *)msgID operateUser:(V2TIMUserFullInfo *)operateUser reason:(NSString * _Nullable)reason NS_SWIFT_NAME(onRecvMessageRevoked(msgID:operateUser:reason:));

/// 消息内容被修改
- (void)onRecvMessageModified:(V2TIMMessage *)msg NS_SWIFT_NAME(onRecvMessageModified(msg:));

/// 消息扩展信息更新
- (void)onRecvMessageExtensionsChanged:(NSString *)msgID extensions:(NSArray<V2TIMMessageExtension *> *)extensions NS_SWIFT_NAME(onRecvMessageExtensionsChanged(msgID:extensions:));

/// 消息扩展信息被删除
- (void)onRecvMessageExtensionsDeleted:(NSString *)msgID extensionKeys:(NSArray<NSString *> *)extensionKeys NS_SWIFT_NAME(onRecvMessageExtensionsDeleted(msgID:extensionKeys:));

/// 消息回应信息更新
/// 该回调是消息 Reaction 的增量回调，只会携带变更的 Reaction 信息。
/// 当变更的 Reaction 信息里的 totalUserCount 字段值为 0 时，表明该 Reaction 已经没有用户在使用，您可以在 UI 上移除该 Reaction 的展示。
- (void)onRecvMessageReactionsChanged:(NSArray<V2TIMMessageReactionChangeInfo *> *)changeList NS_SWIFT_NAME(onRecvMessageReactionsChanged(changeList:));

/// 置顶群消息列表变更通知
/// 如果变更类型为取消置顶，message 参数中只有消息的 key，不包含完整的消息体。
- (void)onGroupMessagePinned:(NSString * _Nullable)groupID message:(V2TIMMessage *)message isPinned:(BOOL)isPinned opUser:(V2TIMGroupMemberInfo *)opUser NS_SWIFT_NAME(onGroupMessagePinned(groupID:message:isPinned:opUser:));

/// 收到消息撤回（待废弃接口，请使用 onRecvMessageRevoked:operateUser:reason: 接口）
- (void)onRecvMessageRevoked:(NSString *)msgID __attribute__((deprecated("use onRecvMessageRevoked:operateUser:reason: instead"))); 
@end

/////////////////////////////////////////////////////////////////////////////////
//                         消息内容详解
/////////////////////////////////////////////////////////////////////////////////
/// 高级消息
V2TIM_EXPORT @interface V2TIMMessage : NSObject
/// 消息 ID（消息创建的时候为 nil，消息发送的时候会生成）
@property(nonatomic,strong,readonly,nullable) NSString *msgID;

/// 消息的 UTC 时间戳
@property(nonatomic,strong,readonly,nullable) NSDate *timestamp;

/// 消息发送者
@property(nonatomic,strong,readonly,nullable) NSString *sender;

/// 消息发送者昵称
@property(nonatomic,strong,readonly,nullable) NSString *nickName;

/// 消息发送者好友备注
@property(nonatomic,strong,readonly,nullable) NSString *friendRemark;

/// 如果是群组消息，nameCard 为发送者的群名片
@property(nonatomic,strong,readonly,nullable) NSString *nameCard;

/// 消息发送者头像
@property(nonatomic,strong,readonly,nullable) NSString *faceURL;

/// 如果是群组消息，groupID 为会话群组 ID，否则为 nil
@property(nonatomic,strong,readonly,nullable) NSString *groupID;

/// 如果是单聊消息，userID 为会话用户 ID，否则为 nil，
/// 假设自己和 userA 聊天，无论是自己发给 userA 的消息还是 userA 发给自己的消息，这里的 userID 均为 userA
@property(nonatomic,strong,readonly,nullable) NSString *userID;

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
/// 该字段为 YES 的条件是消息 timestamp <= 对端标记会话已读的时间
@property(nonatomic,assign,readonly) BOOL isPeerRead;

/// 消息是否需要已读回执
/// @note
/// <p> 群聊消息 6.1 及以上版本支持该特性，需要您先到 IM 控制台配置支持已读回执的群类型。
/// <p> 单聊消息 6.2 及以上版本支持该特性。
/// <p> 群聊消息和单聊消息都需要购买旗舰版套餐包。
@property(nonatomic,assign) BOOL needReadReceipt;

/// 是否支持消息扩展（6.7 及其以上版本支持，需要您购买旗舰版套餐）
/// 直播群（AVChatRoom）消息不支持该功能。
/// 您需要先到 IM 控制台配置该功能。
@property(nonatomic,assign) BOOL supportMessageExtension;

/// 是否是广播消息，仅直播群支持（6.5 及以上版本支持，需要您购买旗舰版套餐）
@property(nonatomic,assign,readonly) BOOL isBroadcastMessage;

/// 消息优先级（只有 onRecvNewMessage 收到的 V2TIMMessage 获取有效）
@property(nonatomic,assign,readonly) V2TIMMessagePriority priority;

/// 群消息中被 @ 的用户 UserID 列表（即该消息都 @ 了哪些人）
@property(nonatomic,strong,readonly,nullable) NSMutableArray<NSString *> *groupAtUserList;

/// 消息类型
@property(nonatomic,assign,readonly) V2TIMElemType elemType;

/// 消息类型 为 V2TIM_ELEM_TYPE_TEXT，textElem 会存储文本消息内容
@property(nonatomic,strong,readonly,nullable) V2TIMTextElem *textElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_CUSTOM，customElem 会存储自定义消息内容
@property(nonatomic,strong,readonly,nullable) V2TIMCustomElem *customElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_IMAGE，imageElem 会存储图片消息内容
@property(nonatomic,strong,readonly,nullable) V2TIMImageElem *imageElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_SOUND，soundElem 会存储语音消息内容
@property(nonatomic,strong,readonly,nullable) V2TIMSoundElem *soundElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_VIDEO，videoElem 会存储视频消息内容
@property(nonatomic,strong,readonly,nullable) V2TIMVideoElem *videoElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_FILE，fileElem 会存储文件消息内容
@property(nonatomic,strong,readonly,nullable) V2TIMFileElem *fileElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_LOCATION，locationElem 会存储地理位置消息内容
@property(nonatomic,strong,readonly,nullable) V2TIMLocationElem *locationElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_FACE，faceElem 会存储表情消息内容
@property(nonatomic,strong,readonly,nullable) V2TIMFaceElem *faceElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_MERGER，mergerElem 会存储转发消息内容
@property(nonatomic,strong,readonly,nullable) V2TIMMergerElem *mergerElem;

/// 消息类型 为 V2TIM_ELEM_TYPE_GROUP_TIPS，groupTipsElem 会存储群 tips 消息内容
@property(nonatomic,strong,readonly,nullable) V2TIMGroupTipsElem *groupTipsElem;

/// 消息自定义数据（本地保存，不会发送到对端，程序卸载重装后失效）
@property(nonatomic,strong,nullable) NSData* localCustomData;

/// 消息自定义数据,可以用来标记语音、视频消息是否已经播放（本地保存，不会发送到对端，程序卸载重装后失效）
@property(nonatomic,assign) int localCustomInt;

/// 消息自定义数据（云端保存，会发送到对端，程序卸载重装后还能拉取到）
@property(nonatomic,strong,nullable) NSData* cloudCustomData;

/// 消息是否不计入会话未读数：默认为 NO，表明需要计入会话未读数，设置为 YES，表明不需要计入会话未读数
/// <p> 5.3.425 及以上版本支持, 会议群（Meeting）默认不支持该字段
@property(nonatomic,assign) BOOL isExcludedFromUnreadCount;

/// 消息是否不计入会话 lastMsg：默认为 NO，表明需要计入会话 lastMsg，设置为 YES，表明不需要计入会话 lastMsg（5.4.666 及以上版本支持）
@property(nonatomic,assign) BOOL isExcludedFromLastMessage;

/// 消息是否不过内容审核（【云端审核】）(7.1 及以上版本支持)
/// 只有在开通【云端审核】功能后，isExcludedFromContentModeration 设置才有效，设置为 YES，表明不过内容审核，设置为 NO：表明过内容审核。
///【云端审核】开通流程请参考 [云端审核功能](https://cloud.tencent.com/document/product/269/83795#.E4.BA.91.E7.AB.AF.E5.AE.A1.E6.A0.B8.E5.8A.9F.E8.83.BD)
@property(nonatomic,assign) BOOL isExcludedFromContentModeration;

/// 消息自定义审核配置 ID（从 7.8 版本开始支持）
/// 在开通【云端审核】功能后，您可以请前往 [控制台](https://console.cloud.tencent.com/im) (云端审核 -> 审核配置 -> 自定义配置 -> 添加自定义配置) 获取配置 ID。
///【自定义审核】配置流程请参考 [云端审核功能]（https://cloud.tencent.com/document/product/269/78633#a5efc9e8-a7ec-40e3-9b18-8ed1910f589c）
/// @note 该字段需要发消息前设置，仅用于控制发消息时的消息审核策略，其值不会存储在漫游和本地。
@property(nonatomic,strong,nullable) NSString *customModerationConfigurationID;

/// 是否被标记为有安全风险的消息（从 7.4 版本开始支持）
/// 暂时只支持语音和视频消息。
/// 只有在开通【云端审核】功能后才生效，【云端审核】开通流程请参考 [云端审核功能](https://cloud.tencent.com/document/product/269/83795#.E4.BA.91.E7.AB.AF.E5.AE.A1.E6.A0.B8.E5.8A.9F.E8.83.BD)。
/// 如果您发送的语音或视频消息内容不合规，云端异步审核后会触发 SDK 的 onRecvMessageModified 回调，回调里的 message 对象该字段值为 YES。
@property(nonatomic,assign,readonly) BOOL hasRiskContent;

/// 是否禁用消息发送前云端回调（从 8.1 版本开始支持）
@property(nonatomic,assign) BOOL disableCloudMessagePreHook;

/// 是否禁用消息发送后云端回调（从 8.1 版本开始支持）
@property(nonatomic,assign) BOOL disableCloudMessagePostHook;

/// 消息的离线推送信息
@property(nonatomic,strong,readonly,nullable) V2TIMOfflinePushInfo *offlinePushInfo;

/// 消息撤回者（从 7.4 版本开始支持）
/// 仅当消息为撤回状态时有效
@property(nonatomic,strong,readonly,nullable) V2TIMUserFullInfo *revokerInfo;

/// 消息撤回原因 （从 7.4 版本开始支持）
/// 仅当消息为撤回状态时有效
@property(nonatomic,strong,readonly,nullable) NSString *revokeReason;

/// 消息置顶者 （从 8.0 版本开始支持）
/// 只有通过 GetPinnedGroupMessageList 获取到的置顶消息才包含该字段
@property(nonatomic,strong,readonly,nullable) V2TIMGroupMemberFullInfo *pinnerInfo;

@end


/////////////////////////////////////////////////////////////////////////////////
//                         
//                         消息元素基类
//                         
/////////////////////////////////////////////////////////////////////////////////
/// 消息元素基类
V2TIM_EXPORT @interface V2TIMElem : NSObject

/// 获取下一个 Elem，如果您的消息有多个 Elem，可以通过当前 Elem 获取下一个 Elem 对象，如果返回值为 nil，表示 Elem 获取结束。
/// 详细使用方法请参考文档 [消息收发](https://cloud.tencent.com/document/product/269/44490#4.-.E5.A6.82.E4.BD.95.E8.A7.A3.E6.9E.90.E5.A4.9A.E4.B8.AA-elem-.E7.9A.84.E6.B6.88.E6.81.AF.EF.BC.9F)
- (V2TIMElem * _Nullable )nextElem;

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
 *  1.该接口只能由 createMessage 创建的 Message 对象里的 elem 元素调用。
 *  2.该接口仅支持添加 V2TIMTextElem、V2TIMCustomElem、V2TIMFaceElem 和 V2TIMLocationElem 四类元素。
 */
- (void)appendElem:(V2TIMElem *)elem NS_SWIFT_NAME(appendElem(elem:));
@end

/////////////////////////////////////////////////////////////////////////////////
//                         文本消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 文本消息 Elem
V2TIM_EXPORT @interface V2TIMTextElem : V2TIMElem

/// 消息文本
@property(nonatomic,strong,nullable) NSString *text;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         自定义消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 自定义消息 Elem
V2TIM_EXPORT @interface V2TIMCustomElem : V2TIMElem

/// 自定义消息二进制数据
@property(nonatomic,strong,nullable) NSData * data;

/// 自定义消息描述信息
@property(nonatomic,strong,nullable) NSString * desc;

/// 自定义消息扩展字段
@property(nonatomic,strong,nullable) NSString * extension NS_SWIFT_NAME(ext);

@end

/////////////////////////////////////////////////////////////////////////////////
//                         图片消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 图片消息Elem
V2TIM_EXPORT @interface V2TIMImageElem : V2TIMElem

/// 图片路径（只有发送方可以获取到）
@property(nonatomic,strong,readonly,nullable) NSString * path;

/// 接收图片消息的时候这个字段会保存图片的所有规格，目前最多包含三种规格：原图、大图、缩略图，每种规格保存在一个 TIMImage 对象中
@property(nonatomic,strong,readonly) NSArray<V2TIMImage *> *imageList;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         图片消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 图片元素
V2TIM_EXPORT @interface V2TIMImage : NSObject

/// 图片 ID，内部标识，可用于外部缓存 key
@property(nonatomic,strong,readonly,nullable) NSString * uuid;

/// 图片类型
@property(nonatomic,assign,readonly) V2TIMImageType type;

/// 图片大小（type == V2TIM_IMAGE_TYPE_ORIGIN 有效）
@property(nonatomic,assign,readonly) int size;

/// 图片宽度
@property(nonatomic,assign,readonly) int width;

/// 图片高度
@property(nonatomic,assign,readonly) int height;

/// 图片 url
@property(nonatomic,strong,readonly,nullable) NSString * url;

/**
 *  下载图片
 *
 *  下载的数据需要由开发者缓存，IM SDK 每次调用 downloadImage 都会从服务端重新下载数据。建议通过图片的 uuid 作为 key 进行图片文件的存储。
 *
 *  @param path 图片保存路径，需要外部指定
 */
- (void)downloadImage:(NSString *)path progress:(_Nullable V2TIMDownLoadProgress)progress succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(downloadImage(path:progress:succ:fail:));

@end

/////////////////////////////////////////////////////////////////////////////////
//                         语音消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 语音消息 Elem
V2TIM_EXPORT @interface V2TIMSoundElem : V2TIMElem

/// 语音文件路径（只有发送方才能获取到）
@property(nonatomic,strong,readonly,nullable) NSString * path;

/// 语音消息内部 ID
@property(nonatomic,strong,readonly,nullable) NSString * uuid;

/// 语音数据大小
@property(nonatomic,assign,readonly) int dataSize;

/// 语音长度（秒）
@property(nonatomic,assign,readonly) int duration;

/// 获取语音的 URL 下载地址
-(void)getUrl:(void (^)(NSString * _Nullable url))urlCallBack;

/**
 *  下载语音
 *
 *  downloadSound 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 语音保存路径，需要外部指定
 */
- (void)downloadSound:(NSString*)path progress:(_Nullable V2TIMDownLoadProgress)progress succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(downloadSound(path:progress:succ:fail:));

/**
 *  将语音转成文字（7.4 及以上版本支持）
 *
 *  @param language 识别的语言。
 *
 *  @note
 *  - 语音转文字是增值付费功能，处于内测阶段，您可通过 [即时通信 IM 语音转文字插件交流群](https://zhiliao.qq.com/s/c5GY7HIM62CK/cPSYGIIM62CH) 联系我们为您开通体验完整功能。
 */
- (void)convertVoiceToText:(NSString *)language completion:(void (^)(int code, NSString *desc, NSString *result))callback NS_SWIFT_NAME(convertVoiceToText(language:completion:));

@end

/////////////////////////////////////////////////////////////////////////////////
//                         视频消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 视频消息 Elem
V2TIM_EXPORT @interface V2TIMVideoElem : V2TIMElem

/// 视频文件路径（只有发送方才能获取到）
@property(nonatomic,strong,readonly,nullable) NSString * videoPath;

/// 截图文件路径（只有发送方才能获取到）
@property(nonatomic,strong,readonly,nullable) NSString * snapshotPath;

/// 视频 ID,内部标识，可用于外部缓存 key
@property(nonatomic,strong,readonly,nullable) NSString * videoUUID;

/// 视频大小
@property(nonatomic,assign,readonly) int videoSize;

/// 视频类型
@property(nonatomic,strong,readonly,nullable) NSString *videoType;

/// 视频时长
@property(nonatomic,assign,readonly) int duration;

/// 截图 ID,内部标识，可用于外部缓存 key
@property(nonatomic,strong,readonly,nullable) NSString * snapshotUUID;

/// 截图 size
@property(nonatomic,assign,readonly) int snapshotSize;

/// 截图宽
@property(nonatomic,assign,readonly) int snapshotWidth;

/// 截图高
@property(nonatomic,assign,readonly) int snapshotHeight;

/// 获取视频的 URL 下载地址
-(void)getVideoUrl:(void (^)(NSString * _Nullable url))urlCallBack;

/// 获取截图的 URL 下载地址
-(void)getSnapshotUrl:(void (^)(NSString * _Nullable url))urlCallBack;

/**
 *  下载视频
 *
 *  downloadVideo 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 视频保存路径，需要外部指定
 */
- (void)downloadVideo:(NSString*)path progress:(_Nullable V2TIMDownLoadProgress)progress succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(downloadVideo(path:progress:succ:fail:));

/**
 *  下载视频截图
 *
 *  downloadSnapshot 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 截图保存路径，需要外部指定
 */
- (void)downloadSnapshot:(NSString*)path progress:(_Nullable V2TIMDownLoadProgress)progress succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(downloadSnapshot(path:progress:succ:fail:));

@end

/////////////////////////////////////////////////////////////////////////////////
//                         文件消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 文件消息 Elem
V2TIM_EXPORT @interface V2TIMFileElem : V2TIMElem

/// 文件路径（只有发送方才能获取到）
@property(nonatomic,strong,readonly,nullable) NSString * path;

/// 文件 ID,内部标识，可用于外部缓存 key
@property(nonatomic,strong,readonly,nullable) NSString * uuid;

/// 文件显示名称
@property(nonatomic,strong,readonly,nullable) NSString * filename;

/// 文件大小
@property(nonatomic,assign,readonly) int fileSize;

/// 获取文件的 URL 下载地址
-(void)getUrl:(void (^)(NSString * _Nullable url))urlCallBack;

/**
 *  下载文件
 *
 *  downloadFile 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 文件保存路径，需要外部指定
 */
- (void)downloadFile:(NSString*)path progress:(_Nullable V2TIMDownLoadProgress)progress succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(downloadFile(path:progress:succ:fail:));

@end

/////////////////////////////////////////////////////////////////////////////////
//                         地理位置 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 地理位置 Elem
V2TIM_EXPORT @interface V2TIMLocationElem : V2TIMElem

/// 地理位置描述信息
@property(nonatomic,strong,nullable) NSString * desc;

/// 经度，发送消息时设置
@property(nonatomic,assign) double longitude;

/// 纬度，发送消息时设置
@property(nonatomic,assign) double latitude;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         表情消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 表情消息 Elem
V2TIM_EXPORT @interface V2TIMFaceElem : V2TIMElem
/**
 *  表情索引，用户自定义
 *  1. 表情消息由 TIMFaceElem 定义，SDK 并不提供表情包，如果开发者有表情包，可使用 index 存储表情在表情包中的索引，由用户自定义，或者直接使用 data 存储表情二进制信息以及字符串 key，都由用户自定义，SDK 内部只做透传。
 *  2. index 和 data 只需要传入一个即可，ImSDK 只是透传这两个数据。
 */
@property(nonatomic,assign) int index;

/// 额外数据，用户自定义
@property(nonatomic,strong,nullable) NSData * data;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         合并消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 合并消息 Elem
V2TIM_EXPORT @interface V2TIMMergerElem : V2TIMElem

/// 合并消息里面又包含合并消息我们称之为合并嵌套，合并嵌套层数不能超过 100 层，如果超过限制，layersOverLimit 会返回 YES，title 和 abstractList 会返回 nil，downloadMergerMessage 会返回 ERR_MERGER_MSG_LAYERS_OVER_LIMIT 错误码。
@property(nonatomic,assign,readonly) BOOL layersOverLimit;

/// 合并消息 title
@property(nonatomic,strong,readonly,nullable) NSString *title;

/// 合并消息摘要列表
@property(nonatomic,strong,readonly,nullable) NSArray<NSString *> *abstractList;

/// 下载被合并的消息列表
- (void)downloadMergerMessage:(V2TIMMessageListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(downloadMergerMessage(succ:fail:));

@end

/////////////////////////////////////////////////////////////////////////////////
//                         群 Tips 消息 Elem
/////////////////////////////////////////////////////////////////////////////////

/// 群 tips 消息会存消息列表，群里所有的人都会展示，比如 xxx 进群，xxx 退群，xxx 群资料被修改了等
V2TIM_EXPORT @interface V2TIMGroupTipsElem : V2TIMElem

/// 群组 ID
@property(nonatomic,strong,readonly,nullable) NSString * groupID;

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
V2TIM_EXPORT @interface V2TIMGroupChangeInfo : NSObject

/// 变更类型
@property(nonatomic,assign,readonly) V2TIMGroupInfoChangeType type;

/// 根据变更类型表示不同的值,例如 type = V2TIM_GROUP_INFO_CHANGE_TYPE_NAME，value 表示群新的 groupName
@property(nonatomic,strong,readonly,nullable) NSString * value;

/// 变更自定义字段的 key 值（type = V2TIM_GROUP_INFO_CHANGE_TYPE_CUSTOM 生效）
/// 因为历史遗留原因，如果只修改了群自定义字段，当前消息不会存漫游和 DB
@property(nonatomic,strong,readonly,nullable) NSString * key;

/// 根据变更类型表示不同的值，当 type = V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL  或者 V2TIM_GROUP_INFO_CHANGE_TYPE_ENABLE_PERMISSION_GROUP 时有效
@property(nonatomic,assign,readonly) BOOL boolValue;

/// 根据变更类型表示不同的值
/// @note 仅针对以下类型有效：
/// - 从 6.5 版本开始，当 type 为 V2TIM_GROUP_INFO_CHANGE_TYPE_RECEIVE_MESSAGE_OPT 时，该字段标识了群消息接收选项发生了变化，其取值详见 @V2TIMReceiveMessageOpt；
/// - 从 6.5 版本开始，当 type 为 V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_ADD_OPT 时，该字段标识了申请加群审批选项发生了变化，其取值详见 @V2TIMGroupAddOpt;
/// - 从 7.1 版本开始，当 type 为 V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_APPROVE_OPT 时，该字段标识了邀请进群审批选项发生了变化，取值类型详见 @V2TIMGroupAddOpt。
@property(nonatomic,assign,readonly) uint32_t intValue;

/// 根据变更类型表示不同的值，当前只有 type = V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_PERMISSION 时有效
@property(nonatomic,assign,readonly) uint64_t uint64Value;

@end

///群tips，成员变更信息
V2TIM_EXPORT @interface V2TIMGroupMemberChangeInfo : NSObject

/// 变更用户
@property(nonatomic,strong,readonly,nullable) NSString * userID;

/// 禁言时间（秒，表示还剩多少秒可以发言）
@property(nonatomic,assign,readonly) uint32_t muteTime;

@end


/////////////////////////////////////////////////////////////////////////////////
//                         消息已读回执
/////////////////////////////////////////////////////////////////////////////////
//
/// 消息已读回执
V2TIM_EXPORT @interface V2TIMMessageReceipt : NSObject
/// 消息 ID
@property(nonatomic,strong,readonly,nullable) NSString * msgID;

/// C2C 消息接收对象
@property(nonatomic,strong,readonly,nullable) NSString * userID;

/// C2C 对端消息是否已读
@property(nonatomic,assign,readonly) BOOL isPeerRead;

/// C2C 对端已读的时间
/// 如果 msgID 为空，该字段表示对端用户标记会话已读的时间
/// 如果 msgID 不为空，该字段表示对端用户发送消息已读回执的时间（8.1 及以上版本支持）
@property(nonatomic,assign,readonly) time_t timestamp;

/// 群 ID
@property(nonatomic,strong,readonly,nullable) NSString * groupID;

/// 群消息已读人数
@property(nonatomic,assign,readonly) int readCount;

/// 群消息未读人数
@property(nonatomic,assign,readonly) int unreadCount;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         消息扩展
/////////////////////////////////////////////////////////////////////////////////
//
/// 消息扩展信息
V2TIM_EXPORT @interface V2TIMMessageExtension : NSObject

/// 消息扩展信息 key
@property(nonatomic, strong, nullable) NSString *extensionKey;

/// 消息扩展信息 value
@property(nonatomic, strong, nullable) NSString *extensionValue;

@end

/// 消息扩展操作结果
V2TIM_EXPORT @interface V2TIMMessageExtensionResult : NSObject
/// 返回码
@property(nonatomic,assign,readonly) int32_t resultCode;

/// 返回信息
@property(nonatomic,strong,readonly,nullable) NSString *resultInfo;

/// 扩展信息
@property(nonatomic,strong,readonly) V2TIMMessageExtension *extension NS_SWIFT_NAME(ext);

@end

/////////////////////////////////////////////////////////////////////////////////
//                         消息回应
/////////////////////////////////////////////////////////////////////////////////
/// 消息回应信息
V2TIM_EXPORT @interface V2TIMMessageReaction : NSObject
/// 消息回应 ID
@property(nonatomic,strong,readonly,nullable) NSString *reactionID;

/// 使用同一个 reactionID 回应消息的总的用户个数
@property(nonatomic,assign,readonly) uint32_t totalUserCount;

/// 使用同一个 reactionID 回应消息的部分用户列表（用户列表数量取决于调用 getMessageReactions 接口时设置的 maxUserCountPerReaction 值）
@property(nonatomic,strong,readonly) NSArray<V2TIMUserInfo *> *partialUserList;

/// 自己是否使用了该 reaction
@property(nonatomic,assign,readonly) BOOL reactedByMyself;

@end

/// 批量拉取消息回应结果
V2TIM_EXPORT @interface V2TIMMessageReactionResult : NSObject
/// 返回码
@property(nonatomic,assign,readonly) int32_t resultCode;

/// 返回信息
@property(nonatomic,strong,readonly,nullable) NSString *resultInfo;

/// 消息 ID
@property(nonatomic,strong,readonly,nullable) NSString *msgID;

/// 消息回应列表
@property(nonatomic,strong,readonly) NSArray<V2TIMMessageReaction *> *reactionList;

@end

/// 消息回应变更信息
V2TIM_EXPORT @interface V2TIMMessageReactionChangeInfo : NSObject

/// 消息 ID
@property(nonatomic,strong,readonly,nullable) NSString *msgID;

/// 消息回应变更列表
@property(nonatomic,strong,readonly) NSArray<V2TIMMessageReaction *> *reactionList;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         苹果 APNS 离线推送
/////////////////////////////////////////////////////////////////////////////////
//
/// 接收到离线推送时不会播放声音
V2TIM_EXTERN NSString * const kIOSOfflinePushNoSound;
/// 接收到离线推送时播放系统声音
V2TIM_EXTERN NSString * const kIOSOfflinePushDefaultSound;

/// 自定义消息 push。
V2TIM_EXPORT @interface V2TIMOfflinePushInfo : NSObject

/// 离线推送展示的标题。
@property(nonatomic,strong,nullable) NSString *title;

/// 离线推送展示的内容。
/// 自定义消息进行离线推送，必须设置此字段内容。
@property(nonatomic,strong,nullable) NSString *desc;

/// 离线推送扩展字段，
/// iOS: 收到离线推送的一方可以在 UIApplicationDelegate -> didReceiveRemoteNotification -> userInfo 拿到这个字段，用这个字段可以做 UI 跳转逻辑
@property(nonatomic,strong,nullable) NSString *ext;

/// 是否关闭推送（默认开启推送）。
@property(nonatomic,assign) BOOL disablePush;

/// iOS 离线推送的类型（仅对 iOS 生效）
/// 默认值是 V2TIM_IOS_OFFLINE_PUSH_TYPE_APNS
@property(nonatomic,assign) V2TIMIOSOfflinePushType iOSPushType;

/// 离线推送忽略 badge 计数（仅对 iOS 生效），
/// 如果设置为 YES，在 iOS 接收端，这条消息不会使 APP 的应用图标未读计数增加。
@property(nonatomic,assign) BOOL ignoreIOSBadge;

/// 离线推送声音设置（仅对 iOS 生效），
/// 当 iOSSound = kIOSOfflinePushNoSound，表示接收时不会播放声音。
/// 当 iOSSound = kIOSOfflinePushDefaultSound，表示接收时播放系统声音。
/// 如果要自定义 iOSSound，需要先把语音文件链接进 Xcode 工程，然后把语音文件名（带后缀）设置给 iOSSound。
@property(nonatomic,strong,nullable) NSString *iOSSound;

/// iOS 离线推送的通知级别  (iOS 15 及以上支持)
/// "passive"，不会发出声音、振动或横幅提示，只会静默地出现在通知中心。适用于不紧急的信息，例如应用内的社交活动更新或推荐内容。
/// "active", 会发出声音或振动，并显示横幅提示。适用于一般的重要通知，例如消息提醒、日历事件等。（默认类型）
/// "time-sensitive"，会发出声音或振动，并显示横幅提示，这种级别的通知会打扰用户，即使用户启用了"专注模式"（Focus Mode）。适用于需要用户立即关注的紧急通知，例如安全警报、重要的时间提醒等。打开需要在苹果开发者平台和 xcode 项目中增加相应的配置。
/// "critical", 会发出声音或振动，并显示横幅提示。这种级别的通知会打扰用户，即使设备处于静音模式。适用于极其重要的紧急通知，例如公共安全警报、严重的健康警告等。打开需要向 Apple 特殊申请。
@property(nonatomic,strong,nullable) NSString *iOSInterruptionLevel;

/// 设置 iOS 后台透传消息
/// 设置打开后，离线接收会唤起应用并透传消息内容 ext
@property(nonatomic,assign) BOOL enableIOSBackgroundNotification;

/// 离线推送声音设置（仅对 Android 生效, 仅 imsdk 6.1 及以上版本支持）
/// 只有华为和谷歌手机支持设置铃音提示，小米铃音设置请您参照：https://dev.mi.com/console/doc/detail?pId=1278%23_3_0
/// 另外，谷歌手机 FCM 推送在 Android 8.0 及以上系统设置声音提示，需要在 channel 通道配置，请参照接口 AndroidFCMChannelID
/// AndroidSound: Android 工程里 raw 目录中的铃声文件名，不需要后缀名。
@property(nonatomic,strong,nullable) NSString *AndroidSound;

/// 离线推送设置 OPPO 手机推送的 ChannelID, 仅支持 8.0 系统及以上。（应用配置接入 OPPO 推送的必须要设置）
@property(nonatomic,strong,nullable) NSString *AndroidOPPOChannelID;

/// 离线推送设置 Google FCM 手机推送的 ChannelID, 仅支持 8.0 系统及以上。
@property(nonatomic,strong,nullable) NSString *AndroidFCMChannelID;

/// 离线推送设置小米手机推送的 ChannelID, 仅支持 8.0 系统及以上。
@property(nonatomic,strong,nullable) NSString *AndroidXiaoMiChannelID;

/// 离线推送设置 VIVO 推送消息分类 (待废弃接口，VIVO 推送服务于 2023 年 4 月 3 日优化消息分类规则，推荐使用 AndroidVIVOCategory 设置消息类别)
/// VIVO 手机离线推送消息分类，0：运营消息，1：系统消息。默认取值为 1 。
@property(nonatomic,assign) NSInteger AndroidVIVOClassification;

/// 离线推送设置 VIVO 推送消息类别，详见：https://dev.vivo.com.cn/documentCenter/doc/359。(VIVO 推送服务于 2023 年 4 月 3 日优化消息分类规则，推荐使用 AndroidVIVOCategory 设置消息类别，不需要再关注和设置 AndroidVIVOClassification)
@property(nonatomic,strong,nullable) NSString *AndroidVIVOCategory;

/// 离线推送设置华为推送消息分类，详见：https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/message-classification-0000001149358835
@property(nonatomic,strong,nullable) NSString *AndroidHuaWeiCategory;

/// 离线推送设置 OPPO 推送消息分类，详见：https://open.oppomobile.com/new/developmentDoc/info?id=13189
/// 通讯与服务类型有："IM"，"ACCOUNT"等；内容与营销类型有："NEWS"，"CONTENT"等
@property(nonatomic,strong,nullable) NSString *AndroidOPPOCategory;

/// 离线推送设置 OPPO 推送通知栏消息提醒等级，详见：https://open.oppomobile.com/new/developmentDoc/info?id=13189
/// 使用生效前，需要先设置 AndroidOPPOCategory 指定 category 为 IM 类消息。消息提醒等级有：1，通知栏；2，通知栏 + 锁屏 （默认）；16，通知栏 + 锁屏 + 横幅 + 震动 + 铃声；
@property(nonatomic,assign) NSInteger AndroidOPPONotifyLevel;

/// 离线推送设置 Honor 推送消息分类，详见：https://developer.honor.com/cn/docs/11002/guides/notification-class
/// Honor 推送消息分类: "NORMAL", 表示消息为服务通讯类; "LOW", 表示消息为资讯营销类
@property(nonatomic,strong,nullable) NSString *AndroidHonorImportance;

/// 离线推送设置魅族推送消息分类，详见：https://open.flyme.cn/docs?id=329
/// 魅族推送消息分类: 0, 公信消息：⽤⼾对收到此类消息⽆预期，关注程度较低; 1, 私信消息：⽤⼾预期收到的，与⽤⼾关联较强的消息。
@property(nonatomic,assign) NSInteger AndroidMeizuNotifyType;

/// 设置华为设备离线推送的通知图片, url 使用的协议必须是 HTTPS 协议，取值样例：https://example.com/image.png
/// 图片文件须小于 512KB，规格建议为 40dp x 40dp，弧角大小为 8dp。超出建议规格的图片会存在图片压缩或图片显示不全的情况。图片格式建议使用 JPG/JPEG/PNG。
@property(nonatomic,strong,nullable) NSString *AndroidHuaWeiImage;

/// 设置荣耀设备离线推送的通知图片, url 使用的协议必须是 HTTPS 协议，取值样例：https://example.com/image.png
/// 图标文件大小须小于 100KB，图标建议规格大小：160px x 160px，弧角大小为 32px，超出规格大小的图标会存在图片压缩或显示不全的情况。
@property(nonatomic,strong,nullable) NSString *AndroidHonorImage;

/// 设置 Google FCM 设备离线推送的通知图片，未展开消息时显示为大图标，展开消息后展示为大图片. url 使用的协议必须是 HTTPS 协议，取值样例：https://example.com/image.png
/// 图标文件大小须小于 1 MB，超出规格大小的图标会存在图片压缩或显示不全的情况。
@property(nonatomic,strong,nullable) NSString *AndroidFCMImage;

/// 设置 APNs 离线推送的通知图片, 借助 iOS 10 Service Extension 特性，可以下载并展示在弹窗上.iOSImage 使用的协议必须是 HTTPS 协议，取值样例：https://example.com/image.png
/// 限制说明：
/// - 图片：支持 JPEG、GIF、PNG，大小不超过 10 MB
/// 使用说明：
/// - 需要在 IM 控制台打开 mutable-content 属性，支持 iOS 10 Service Extension 特性
/// - 获取 iOSImage 资源的 key 值是 "image"
@property(nonatomic,strong,nullable) NSString *iOSImage;

/// 设置鸿蒙设备离线推送的通知图片，URL使用的协议必须是HTTPS协议，取值样例：https://example.com/image.png。
/// 支持图片格式为png、jpg、jpeg、heif、gif、bmp，图片长*宽 < 25000像素。
@property(nonatomic,strong,nullable) NSString *HarmonyImage;

/// 设置鸿蒙设备离线推送通知消息类别，详见：https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/message-classification-0000001149358835
@property(nonatomic,strong,nullable) NSString *HarmonyCategory;

/// 离线推送忽略 badge 计数（仅对 Harmony 生效），
/// 如果设置为 YES，在 Harmony 接收端，这条消息不会使 APP 的应用图标未读计数增加。
@property(nonatomic,assign) BOOL ignoreHarmonyBadge;

/// 设置离线推送扩展特性, 支持的字段详见: https://cloud.tencent.com/document/product/269/121188
/// @note vendorParams 格式用法示例：
///   {
///     "fcmPriority": "high",
///     "vivoNotifyType": 4,
///     "oppoTemplateId": "id",
///     "oppoTitleParam": {
///         "title": "title"
///      },
///     "oppoContentParam": {
///         "content": "content"
///      }
///   }
@property(nonatomic,strong,nullable) NSString *vendorParams;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         用户消息接收选项
//
/////////////////////////////////////////////////////////////////////////////////
V2TIM_EXPORT @interface V2TIMReceiveMessageOptInfo : NSObject

/// 用户 ID
@property(nonatomic,strong,nullable) NSString *userID;

/// 获取消息免打扰开始时间：小时
@property(nonatomic,assign) NSInteger startHour;

/// 获取消息免打扰开始时间：分钟
@property(nonatomic,assign) NSInteger startMinute;

/// 获取消息免打扰开始时间：秒
@property(nonatomic,assign) NSInteger startSecond;

/**
 *  获取消息免打扰开始的 UTC 时间戳
 *  @note
 *  - 如果返回的 startTimeStamp 大于 0，您可以直接使用
 *  - 如果返回的 startTimeStamp 等于 0，您需要调用 getStartHour()、getStartMinute()、getStartSecond() 来获取免打扰的相对开始时间
 */
@property(nonatomic,assign) NSInteger startTimeStamp;

/// 获取免打扰持续时长，单位：秒
@property(nonatomic,assign) NSInteger duration;

/// 消息接收选项
@property(nonatomic,assign) V2TIMReceiveMessageOpt receiveOpt;
@end

/////////////////////////////////////////////////////////////////////////////////
//                         消息搜索
/////////////////////////////////////////////////////////////////////////////////
/// 消息搜索参数
V2TIM_EXPORT @interface V2TIMMessageSearchParam : NSObject
/**
 * 关键字列表，最多支持5个。当消息发送者以及消息类型均未指定时，关键字列表必须非空；否则，关键字列表可以为空。
 */
@property(nonatomic,strong,nullable) NSArray<NSString *> * keywordList;

/**
 * 指定关键字列表匹配类型，可设置为"或"关系搜索或者"与"关系搜索.
 * 取值分别为 V2TIM_KEYWORD_LIST_MATCH_TYPE_OR 和 V2TIM_KEYWORD_LIST_MATCH_TYPE_AND，默认为"或"关系搜索。
 */
@property(nonatomic,assign) V2TIMKeywordListMatchType keywordListMatchType;

/**
 * 指定 userID 发送的消息，最多支持5个。
 */
@property(nonatomic,strong,nullable) NSArray<NSString *> *senderUserIDList;

/// 指定搜索的消息类型集合，传 nil 表示搜索支持的全部类型消息（V2TIMFaceElem 和 V2TIMGroupTipsElem 不支持）取值详见 @V2TIMElemType。
@property(nonatomic,strong,nullable) NSArray<NSNumber *> * messageTypeList;

/**
 * 搜索"全部会话"还是搜索"指定的会话"：
 * <p> 如果设置 conversationID == nil，代表搜索全部会话。
 * <p> 如果设置 conversationID != nil，代表搜索指定会话。会话唯一 ID, C2C 单聊组成方式：[NSString stringWithFormat:@"c2c_%@",userID]；群聊组成方式为 [NSString stringWithFormat:@"group_%@",groupID]
 */
@property(nonatomic,strong,nullable) NSString *conversationID;

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
 *
 * @note 仅对接口 searchLocalMessages 生效
*/
@property(nonatomic,assign) NSUInteger pageIndex;

/**
 * 每页结果数量：用于分页展示查找结果，如不希望分页可将其设置成 0，但如果结果太多，可能会带来性能问题。
 * @note 仅对接口 searchLocalMessages 生效
 */
@property(nonatomic,assign) NSUInteger pageSize;

/**
 * 每次云端搜索返回结果的条数。
 * @note 仅对接口 searchCloudMessages 生效
 */
@property(nonatomic,assign) NSUInteger searchCount;

/**
 * 每次云端搜索的起始位置。第一次填空字符串，续拉时填写 V2TIMMessageSearchResult 中的返回值。
 * @note 仅对接口 searchCloudMessages 生效
 */
@property(nonatomic,strong,nullable) NSString *searchCursor;

@end

V2TIM_EXPORT @interface V2TIMMessageSearchResultItem : NSObject

/// 会话ID
@property(nonatomic,copy) NSString *conversationID;

/// 当前会话一共搜索到了多少条符合要求的消息
@property(nonatomic,assign) NSUInteger messageCount;

/**
 * 满足搜索条件的消息列表
 * <p>如果您本次搜索【指定会话】，那么 messageList 中装载的是本会话中所有满足搜索条件的消息列表。
 * <p>如果您本次搜索【全部会话】，那么 messageList 中装载的消息条数会有如下两种可能：
 * - 如果某个会话中匹配到的消息条数 > 1，则 messageList 为空，您可以在 UI 上显示" messageCount 条相关记录"。
 * - 如果某个会话中匹配到的消息条数 = 1，则 messageList 为匹配到的那条消息，您可以在 UI 上显示之，并高亮匹配关键词。
*/
@property(nonatomic,strong) NSArray<V2TIMMessage *> *messageList;

@end

V2TIM_EXPORT @interface V2TIMMessageSearchResult : NSObject

/**
 * 如果您本次搜索【指定会话】，那么返回满足搜索条件的消息总数量；
 * 如果您本次搜索【全部会话】，那么返回满足搜索条件的消息所在的所有会话总数量。
 */
@property(nonatomic,assign) NSUInteger totalCount;

/**
 * 如果您本次搜索【指定会话】，那么返回结果列表只包含该会话结果；
 * 如果您本次搜索【全部会话】，那么对满足搜索条件的消息根据会话 ID 分组，分页返回分组结果；
 */
@property(nonatomic,strong) NSArray<V2TIMMessageSearchResultItem *> *messageSearchResultItems;

/**
 * 下一次云端搜索的起始位置。
 */
@property(nonatomic,strong,nullable) NSString *searchCursor;

@end


/////////////////////////////////////////////////////////////////////////////////
//                         消息拉取
/////////////////////////////////////////////////////////////////////////////////

V2TIM_EXPORT @interface V2TIMMessageListGetOption : NSObject

/**
 * 拉取消息类型，可以设置拉取本地、云端更老或者更新的消息
 *
 * @note
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
@property(nonatomic,strong,nullable) NSString *userID;

/// 拉取群组历史消息
@property(nonatomic,strong,nullable) NSString *groupID;

/// 拉取消息数量
@property(nonatomic,assign) NSUInteger count;

/// 拉取的消息类型集合，getType 为 V2TIM_GET_LOCAL_OLDER_MSG 和 V2TIM_GET_LOCAL_NEWER_MSG 有效，传 nil 表示拉取全部类型消息，取值详见 @V2TIMElemType。
@property(nonatomic,strong,nullable) NSArray<NSNumber *> * messageTypeList;

/**
 * 拉取消息的起始消息
 *
 * @note
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
@property(nonatomic,strong,nullable) V2TIMMessage *lastMsg;
@property(nonatomic,assign) NSUInteger lastMsgSeq;

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
@property(nonatomic,assign) NSUInteger getTimeBegin;
@property(nonatomic,assign) NSUInteger getTimePeriod;

/**
 * 拉取群组历史消息时，支持按照消息序列号 seq 拉取（从 7.1 版本开始有效）
 *
 * @note
 * - 仅拉取群组历史消息时有效；
 * - 消息序列号 seq 可以通过 V2TIMMessage 对象的 seq 字段获取；
 * - 当 getType 设置为从云端拉取时，会将本地存储消息列表与云端存储消息列表合并后返回；如果无网络，则直接返回本地消息列表；
 * - 当 getType 设置为从本地拉取时，直接返回本地的消息列表；
 * - 当 getType 设置为拉取更旧的消息时，消息列表按照时间逆序，也即消息按照时间戳从大往小的顺序排序；
 * - 当 getType 设置为拉取更新的消息时，消息列表按照时间顺序，也即消息按照时间戳从小往大的顺序排序。
 */
@property(nonatomic,strong,nullable) NSArray<NSNumber *> *messageSeqList;

@end
