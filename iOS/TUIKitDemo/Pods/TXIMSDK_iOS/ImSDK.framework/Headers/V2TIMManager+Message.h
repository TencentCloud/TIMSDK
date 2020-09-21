/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：V2TIMManager+MsgExt
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
@class V2TIMGroupTipsElem;
@class V2TIMImage;
@class V2TIMMessageReceipt;
@class V2TIMOfflinePushInfo;
@class V2TIMGroupChangeInfo;
@class V2TIMGroupMemberChangeInfo;
@protocol V2TIMAdvancedMsgListener;

@interface V2TIMManager (Message)

/// 获取历史消息成功回调
typedef void (^V2TIMMessageListSucc)(NSArray<V2TIMMessage *> * msgs);
/// 文件上传进度回调，取值 0 -100
typedef void (^V2TIMProgress)(uint32_t progress);
/// 文件下载进度回调
typedef void (^V2TIMDownLoadProgress)(NSInteger curSize, NSInteger totalSize);

// 消息状态
typedef NS_ENUM(NSInteger, V2TIMMessageStatus){
    V2TIM_MSG_STATUS_SENDING                  = 1,  ///< 消息发送中
    V2TIM_MSG_STATUS_SEND_SUCC                = 2,  ///< 消息发送成功
    V2TIM_MSG_STATUS_SEND_FAIL                = 3,  ///< 消息发送失败
    V2TIM_MSG_STATUS_HAS_DELETED              = 4,  ///< 消息被删除
    V2TIM_MSG_STATUS_LOCAL_REVOKED            = 6,  ///< 被撤销的消息
};

// 消息类型
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
};

/**
 *  推送规则
 */
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
};

/////////////////////////////////////////////////////////////////////////////////
//
//                         监听 - 高级（图片、语音、视频等）消息
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  1.1 添加高级消息的事件监听器
 */
- (void)addAdvancedMsgListener:(id<V2TIMAdvancedMsgListener>)listener;

/**
 *  1.2 移除高级消息的事件监听器
 */
- (void)removeAdvancedMsgListener:(id<V2TIMAdvancedMsgListener>)listener;


/////////////////////////////////////////////////////////////////////////////////
//
//                         创建 - 高级（图片、语音、视频等）消息
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  2.1 创建文本消息
 */
- (V2TIMMessage *)createTextMessage:(NSString *)text;

/**
 *  2.2 创建文本消息，并且可以附带 @ 提醒功能
 *
 *  提醒消息仅适用于在群组中发送的消息
 *
 *  @param atUserList 需要 @ 的用户列表，如果需要 @ALL，请传入 kImSDK_MesssageAtALL 常量字符串。
 *  举个例子，假设该条文本消息希望@提醒 denny 和 lucy 两个用户，同时又希望@所有人，atUserList 传 @[@"denny",@"lucy",kImSDK_MesssageAtALL]
 */
- (V2TIMMessage *)createTextAtMessage:(NSString *)text atUserList:(NSMutableArray<NSString *> *)atUserList;

/**
 *  2.3 创建自定义消息
 */
- (V2TIMMessage *)createCustomMessage:(NSData *)data;

/**
 *  2.4 创建图片消息（图片文件最大支持 28 MB）
 *
 *  @note 如果是系统相册拿的图片，需要先把图片导入 APP 的目录下，具体请参考 Demo TUIChatController -> imagePickerController 代码示例
 */
- (V2TIMMessage *)createImageMessage:(NSString *)imagePath;

/**
 *  2.5 创建语音消息（语音文件最大支持 28 MB）
 *
 *  @param duration 音频时长，单位 s
 */
- (V2TIMMessage *)createSoundMessage:(NSString *)audioFilePath duration:(int)duration;

/**
 *  2.6 创建视频消息（视频文件最大支持 100 MB）
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
 *  2.7 创建文件消息（文件最大支持 100 MB）
 */
- (V2TIMMessage *)createFileMessage:(NSString *)filePath fileName:(NSString *)fileName;

/**
 *  2.8 创建地理位置消息
 */
- (V2TIMMessage *)createLocationMessage:(NSString *)desc longitude:(double)longitude latitude:(double)latitude;

/**
 *  2.9 创建表情消息
 *
 *  SDK 并不提供表情包，如果开发者有表情包，可使用 index 存储表情在表情包中的索引，或者使用 data 存储表情映射的字符串 key，这些都由用户自定义，SDK 内部只做透传。
 *
 *  @param index 表情索引
 *  @param data 自定义数据
 */
- (V2TIMMessage *)createFaceMessage:(int)index data:(NSData *)data;


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
 *  @param onlineUserOnly 是否只有在线用户才能收到，如果设置为 YES ，接收方历史消息拉取不到，常被用于实现”对方正在输入”或群组里的非重要提示等弱提示功能。
 *  @param offlinePushInfo 苹果 APNS 离线推送时携带的标题和声音。
 *  @param progress 文件上传进度（当发送消息中包含图片、语音、视频、文件等富媒体消息时才有效）。
 *  @return msgID 消息唯一标识
 *
 *  @note
 *  - 如果需要消息离线推送，请先在 V2TIMManager+APNS.h 开启推送，推送开启后，除了自定义消息，其他消息默认都会推送。
 *  - 如果自定义消息也需要推送，请设置 offlinePushInfo 的 desc 字段，设置成功后，推送的时候会默认展示 desc 信息。
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
//                         获取历史消息、撤回、删除、标记已读等高级接口
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  4.1 获取单聊历史消息
 *
 *  @param count 拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
 *  @param lastMsg 获取消息的起始消息，如果传 nil，起始消息为会话的最新消息
 *
 *  @note 如果 SDK 检测到没有网络，默认会直接返回本地数据
 */
- (void)getC2CHistoryMessageList:(NSString *)userID count:(int)count lastMsg:(V2TIMMessage*)lastMsg succ:(V2TIMMessageListSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.2 获取群组历史消息
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
 *  4.3 撤回消息
 *
 *  @note 请注意：
    - 撤回消息的时间限制默认 2 minutes，超过 2 minutes 的消息不能撤回，您也可以在 [控制台](https://console.cloud.tencent.com/im)（功能配置 -> 登录与消息 -> 消息撤回设置）自定义撤回时间限制。
 *  - 如果发送方撤回消息，已经收到消息的一方会收到 V2TIMAdvancedMsgListener -> onRecvMessageRevoked 回调。
 */
- (void)revokeMessage:(V2TIMMessage *)msg succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.4 设置单聊消息已读
 */
- (void)markC2CMessageAsRead:(NSString *)userID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.5 设置群组消息已读
 */
- (void)markGroupMessageAsRead:(NSString *)groupID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.6 删除本地消息
 *
 *  @note 该接口只能删除本地历史，消息删除后，SDK 会在本地把这条消息标记为已删除状态，getHistoryMessage 不能再拉取到，如果程序卸载重装，本地会失去对这条消息的删除标记，getHistoryMessage 还能再拉取到该条消息。
 */
- (void)deleteMessageFromLocalStorage:(V2TIMMessage *)msg succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.7 删除本地及云端的消息
 *
 *  @note 该接口会在 deleteMessageFromLocalStorage 的基础上，同步删除云端存储的消息，且无法恢复。需要注意的是：
 *  - 一次最多只能删除 30 条消息
 *  - 要删除的消息必须属于同一会话
 *  - 一秒钟最多只能调用一次该接口
 *  - 如果该账号在其他设备上拉取过这些消息，那么调用该接口删除后，这些消息仍然会保存在那些设备上，即删除消息不支持多端同步。
 */
- (void)deleteMessages:(NSArray<V2TIMMessage *>*)msgList succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

/**
 *  4.8 向群组消息列表中添加一条消息
 *
 *  该接口主要用于满足向群组聊天会话中插入一些提示性消息的需求，比如“您已经退出该群”，这类消息有展示
 *  在聊天消息区的需求，但并没有发送给其他人的必要。
 *  所以 insertGroupMessageToLocalStorage() 相当于一个被禁用了网络发送能力的 sendMessage() 接口。
 *
 *  @return msgID 消息唯一标识
 *  @note 通过该接口 save 的消息只存本地，程序卸载后会丢失。
 */
- (NSString *)insertGroupMessageToLocalStorage:(V2TIMMessage *)msg to:(NSString *)groupID sender:(NSString *)sender succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;

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
/// 在 C2C 场景下，陌生人的头像不会实时更新，如需更新陌生人的头像（如在 UI 上点击陌生人头像以展示陌生人信息时），
/// 请调用 V2TIMManager.h -> getUsersInfo 接口触发信息的拉取。待拉取成功后，SDK 会更新本地头像信息，即 faceURL 字段的内容。
/// @note 请不要在收到每条消息后都去 getUsersInfo，会严重影响程序性能。
@property(nonatomic,strong,readonly) NSString *faceURL;

/// 如果是群组消息，groupID 为会话群组 ID，否则为 nil
@property(nonatomic,strong,readonly) NSString *groupID;

/// 群聊中的消息序列号云端生成，在群里是严格递增且唯一的,
/// 单聊中的序列号是本地生成，不能保证严格递增且唯一。
@property(nonatomic,assign,readonly) uint64_t seq;

/// 如果是单聊消息，userID 为会话用户 ID，否则为 nil，
/// 假设自己和 userA 聊天，无论是自己发给 userA 的消息还是 userA 发给自己的消息，这里的 userID 均为 userA
@property(nonatomic,strong,readonly) NSString *userID;

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

/// 消息类型 为 V2TIM_ELEM_TYPE_GROUP_TIPS，groupTipsElem 会存储群 tips 消息内容
@property(nonatomic,strong,readonly) V2TIMGroupTipsElem *groupTipsElem;

/// 消息自定义数据（本地保存，不会发送到对端，程序卸载重装后失效）
@property(nonatomic,strong) NSData* localCustomData;

/// 消息自定义数据,可以用来标记语音、视频消息是否已经播放（本地保存，不会发送到对端，程序卸载重装后失效）
@property(nonatomic,assign) int localCustomInt;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         消息元素基类
/////////////////////////////////////////////////////////////////////////////////
/// 消息元素基类
@interface V2TIMElem : NSObject

/// 获取下一个 Elem，如果您的消息有多个 Elem，可以通过当前 Elem 获取下一个 Elem 对象，如果返回值为 nil，表示 Elem 获取结束。
/// 详细使用方法请参考文档 [消息收发](https://cloud.tencent.com/document/product/269/44490#4.-.E6.9C.89.E5.A4.9A.E4.B8.AA-elem-.E7.9A.84.E6.B6.88.E6.81.AF.E5.BA.94.E8.AF.A5.E5.A6.82.E4.BD.95.E8.A7.A3.E6.9E.90.EF.BC.9F)
- (V2TIMElem *)nextElem;
@end

/////////////////////////////////////////////////////////////////////////////////
//                         文本消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 文本消息 Elem
@interface V2TIMTextElem : V2TIMElem

/// 消息文本
@property(nonatomic,strong,readonly) NSString * text;

@end

/////////////////////////////////////////////////////////////////////////////////
//                         自定义消息 Elem
/////////////////////////////////////////////////////////////////////////////////
/// 自定义消息 Elem
@interface V2TIMCustomElem : V2TIMElem

/// 自定义消息二进制数据
@property(nonatomic,strong,readonly) NSData * data;

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

/// 图片 url（URL 的有效期为）
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
@property(nonatomic,strong,readonly) NSString * desc;

/// 经度，发送消息时设置
@property(nonatomic,assign,readonly) double longitude;

/// 纬度，发送消息时设置
@property(nonatomic,assign,readonly) double latitude;

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
@property(nonatomic,assign,readonly) int index;

/// 额外数据，用户自定义
@property(nonatomic,strong,readonly) NSData * data;

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
@property(nonatomic, assign,readonly) V2TIMGroupInfoChangeType type;

/// 根据变更类型表示不同的值,例如 type = V2TIM_GROUP_INFO_CHANGE_TYPE_NAME，value 表示群新的 groupName
@property(nonatomic,strong,readonly) NSString * value;

/// 变更自定义字段的 key 值（type = V2TIM_GROUP_INFO_CHANGE_TYPE_CUSTOM 生效）
/// 因为历史遗留原因，如果只修改了群自定义字段，当前消息不会存漫游和 DB
@property(nonatomic,strong,readonly) NSString * key;

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

// 填入 sound 字段表示接收时不会播放声音
extern NSString * const kIOSOfflinePushNoSound;

/// 自定义消息 push。
@interface V2TIMOfflinePushInfo : NSObject

/// 离线推送展示的标题。
@property(nonatomic,strong) NSString * title;

/// 离线推送展示的内容。
@property(nonatomic,strong) NSString * desc;

/// 离线推送扩展字段，
/// iOS: 收到离线推送的一方可以在 UIApplicationDelegate -> didReceiveRemoteNotification -> userInfo 拿到这个字段，用这个字段可以做 UI 跳转逻辑
@property(nonatomic,strong) NSString * ext;

/// 是否关闭推送（默认开启推送）。
@property(nonatomic,assign) BOOL disablePush;

/// 离线推送声音设置（仅对 iOS 生效），
/// 当 sound = kIOSOfflinePushNoSound，表示接收时不会播放声音。
/// 如果要自定义 iOSSound，需要先把语音文件链接进 Xcode 工程，然后把语音文件名（带后缀）设置给 iOSSound。
@property(nonatomic,strong) NSString * iOSSound;

/// 离线推送忽略 badge 计数（仅对 iOS 生效），
/// 如果设置为 YES，在 iOS 接收端，这条消息不会使 APP 的应用图标未读计数增加。
@property(nonatomic,assign) BOOL ignoreIOSBadge;

/// 离线推送设置 OPPO 手机 8.0 系统及以上的渠道 ID（仅对 Android 生效）。
@property(nonatomic,strong) NSString *AndroidOPPOChannelID;
@end

