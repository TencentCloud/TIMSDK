//
//  TIMMessage.h
//  ImSDK
//
//  Created by bodeng on 28/1/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMMessage_h
#define ImSDK_TIMMessage_h


#import <Foundation/Foundation.h>

#import "TIMComm.h"
#import "TIMCallback.h"

@class TIMUserProfile;
@class TIMGroupMemberInfo;
@class TIMConversation;
@class TIMSnapshot;

/////////////////////////////////////////////////////////////////////////////////
//
//                      （一）消息基类
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 消息基类
/**
 *  消息 Elem 基类
 */
@interface TIMElem : NSObject
@end
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （二）文本消息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 文本消息
/**
 *  文本消息 Elem
 */
@interface TIMTextElem : TIMElem
/**
 *  消息文本
 */
@property(nonatomic,strong) NSString * text;
@end
/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （三）图片消息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 图片消息
/**
 *  图片
 */
@interface TIMImage : NSObject
/**
 *  图片ID，内部标识，可用于外部缓存key
 */
@property(nonatomic,strong) NSString * uuid;
/**
 *  图片类型
 */
@property(nonatomic,assign) TIM_IMAGE_TYPE type;
/**
 *  图片大小
 */
@property(nonatomic,assign) int size;
/**
 *  图片宽度
 */
@property(nonatomic,assign) int width;
/**
 *  图片高度
 */
@property(nonatomic,assign) int height;
/**
 *  下载URL
 */
@property(nonatomic, strong) NSString * url;

/**
 *  获取图片
 *
 *  下载的数据需要由开发者缓存，IM SDK 每次调用 getImage 都会从服务端重新下载数据。建议通过图片的 uuid 作为 key 进行图片文件的存储。
 *
 *  @param path 图片保存路径
 *  @param succ 成功回调，返回图片数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getImage:(NSString*)path succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取图片（有进度回调）
 *
 *  下载的数据需要由开发者缓存，IM SDK 每次调用 getImage 都会从服务端重新下载数据。建议通过图片的 uuid 作为 key 进行图片文件的存储。
 *
 *  @param path 图片保存路径
 *  @param progress 图片下载进度
 *  @param succ 成功回调，返回图片数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getImage:(NSString*)path progress:(TIMProgress)progress succ:(TIMSucc)succ fail:(TIMFail)fail;

@end

/**
 *  图片消息Elem
 */
@interface TIMImageElem : TIMElem

/**
 *  要发送的图片路径
 */
@property(nonatomic,strong) NSString * path;

/**
 *  所有类型图片，只读，发送的时候不用关注，接收的时候这个字段会保存图片的所有规格，目前最多包含三种规格：原图、大图、缩略图，每种规格保存在一个 TIMImage 对象中
 */
@property(nonatomic,strong) NSArray * imageList;

/**
 * 上传时任务Id，可用来查询上传进度（已废弃，请在 TIMUploadProgressListener 监听上传进度）
 */
@property(nonatomic,assign) uint32_t taskId DEPRECATED_ATTRIBUTE;

/**
 *  图片压缩等级，详见 TIM_IMAGE_COMPRESS_TYPE（仅对 jpg 格式有效）
 */
@property(nonatomic,assign) TIM_IMAGE_COMPRESS_TYPE level;

/**
 *  图片格式，详见 TIM_IMAGE_FORMAT
 */
@property(nonatomic,assign) TIM_IMAGE_FORMAT format;

@end

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （四）语音消息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 语音消息
/**
 *  语音消息Elem
 *
 *  1. 一条消息只能有一个语音 Elem，添加多条语音 Elem 时，AddElem 函数返回错误 1，添加不生效。
 *  2. 语音和文件 Elem 不一定会按照添加时的顺序获取，建议逐个判断 Elem 类型展示，而且语音和文件 Elem 也不保证按照发送的 Elem 顺序排序。
 *
 */
@interface TIMSoundElem : TIMElem
/**
 *  上传时任务Id，可用来查询上传进度（已废弃，请在 TIMUploadProgressListener 监听上传进度）
 */
@property(nonatomic,assign) uint32_t taskId DEPRECATED_ATTRIBUTE;
/**
 *  上传时，语音文件的路径，接收时使用 getSound 获得数据
 */
@property(nonatomic,strong) NSString * path;
/**
 *  语音消息内部 ID
 */
@property(nonatomic,strong) NSString * uuid;
/**
 *  语音数据大小
 */
@property(nonatomic,assign) int dataSize;
/**
 *  语音长度（秒），发送消息时设置
 */
@property(nonatomic,assign) int second;

/**
 *  获取语音数据到指定路径的文件中
 *
 *  getSound 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 语音保存路径
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getSound:(NSString*)path succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取语音数据到指定路径的文件中（有进度回调）
 *
 *  getSound 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 语音保存路径
 *  @param progress 语音下载进度
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getSound:(NSString*)path progress:(TIMProgress)progress succ:(TIMSucc)succ fail:(TIMFail)fail;

@end

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （五）视频消息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 视频消息
/**
 *  视频
 */
@interface TIMVideo : NSObject
/**
 *  视频消息内部 ID，不用设置
 */
@property(nonatomic,strong) NSString * uuid;
/**
 *  视频文件类型，发送消息时设置
 */
@property(nonatomic,strong) NSString * type;
/**
 *  视频大小，不用设置
 */
@property(nonatomic,assign) int size;
/**
 *  视频时长，发送消息时设置
 */
@property(nonatomic,assign) int duration;

/**
 *  获取视频
 *
 *  getVideo 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 视频保存路径
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getVideo:(NSString*)path succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取视频（有进度回调）
 *
 *  getVideo 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 视频保存路径
 *  @param progress 视频下载进度
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getVideo:(NSString*)path progress:(TIMProgress)progress succ:(TIMSucc)succ fail:(TIMFail)fail;
@end

/**
 *  视频消息 Elem
 */
@interface TIMVideoElem : TIMElem

/**
 *  上传时任务Id，可用来查询上传进度（已废弃，请在 TIMUploadProgressListener 监听上传进度）
 */
@property(nonatomic,assign) uint32_t taskId DEPRECATED_ATTRIBUTE;

/**
 *  视频文件路径，发送消息时设置
 */
@property(nonatomic,strong) NSString * videoPath;

/**
 *  视频信息，发送消息时设置
 */
@property(nonatomic,strong) TIMVideo * video;

/**
 *  截图文件路径，发送消息时设置
 */
@property(nonatomic,strong) NSString * snapshotPath;

/**
 *  视频截图，发送消息时设置
 */
@property(nonatomic,strong) TIMSnapshot * snapshot;

@end

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （六）文件消息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 文件消息
/**
 *  文件消息Elem
 */
@interface TIMFileElem : TIMElem
/**
 *  上传时任务Id，可用来查询上传进度（已废弃，请在 TIMUploadProgressListener 监听上传进度）
 */
@property(nonatomic,assign) uint32_t taskId DEPRECATED_ATTRIBUTE;
/**
 *  上传时，文件的路径（设置 path 时，优先上传文件）
 */
@property(nonatomic,strong) NSString * path;
/**
 *  文件内部ID
 */
@property(nonatomic,strong) NSString * uuid;
/**
 *  文件大小
 */
@property(nonatomic,assign) int fileSize;
/**
 *  文件显示名，发消息时设置
 */
@property(nonatomic,strong) NSString * filename;

/**
 *  获取文件数据到指定路径的文件中
 *
 *  getFile 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 文件保存路径
 *  @param succ 成功回调，返回数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getFile:(NSString*)path succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取文件数据到指定路径的文件中（有进度回调）
 *
 *  getFile 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 文件保存路径
 *  @param progress 文件下载进度
 *  @param succ 成功回调，返回数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getFile:(NSString*)path progress:(TIMProgress)progress succ:(TIMSucc)succ fail:(TIMFail)fail;

@end

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （七）表情消息
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  表情消息类型
 *
 *  1. 表情消息由 TIMFaceElem 定义，SDK 并不提供表情包，如果开发者有表情包，可使用 index 存储表情在表情包中的索引，由用户自定义，或者直接使用 data 存储表情二进制信息以及字符串 key，都由用户自定义，SDK 内部只做透传。
 *  2. index 和 data 只需要传入一个即可，ImSDK 只是透传这两个数据。
 *
 */
@interface TIMFaceElem : TIMElem

/**
 *  表情索引，用户自定义
 */
@property(nonatomic, assign) int index;
/**
 *  额外数据，用户自定义
 */
@property(nonatomic,strong) NSData * data;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      （八）地理位置消息
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  地理位置Elem
 */
@interface TIMLocationElem : TIMElem
/**
 *  地理位置描述信息，发送消息时设置
 */
@property(nonatomic,strong) NSString * desc;
/**
 *  纬度，发送消息时设置
 */
@property(nonatomic,assign) double latitude;
/**
 *  经度，发送消息时设置
 */
@property(nonatomic,assign) double longitude;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      （九）截图消息
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  截图消息 Elem
 */
@interface TIMSnapshot : NSObject
/**
 *  图片ID，不用设置
 */
@property(nonatomic,strong) NSString * uuid;
/**
 *  截图文件类型，发送消息时设置
 */
@property(nonatomic,strong) NSString * type;
/**
 *  图片大小，不用设置
 */
@property(nonatomic,assign) int size;
/**
 *  图片宽度，发送消息时设置
 */
@property(nonatomic,assign) int width;
/**
 *  图片高度，发送消息时设置
 */
@property(nonatomic,assign) int height;

/**
 *  获取图片
 *
 *  getImage 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 图片保存路径
 *  @param succ 成功回调，返回图片数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getImage:(NSString*)path succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取图片（有进度回调）
 *
 *  getImage 接口每次都会从服务端下载，如需缓存或者存储，开发者可根据 uuid 作为 key 进行外部存储，ImSDK 并不会存储资源文件。
 *
 *  @param path 图片保存路径
 *  @param progress 图片下载进度
 *  @param succ 成功回调，返回图片数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getImage:(NSString*)path progress:(TIMProgress)progress succ:(TIMSucc)succ fail:(TIMFail)fail;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十）自定义消息
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  自定义消息类型
 *
 *  自定义消息是指当内置的消息类型无法满足特殊需求，开发者可以自定义消息格式，内容全部由开发者定义，IM SDK 只负责透传。自定义消息由 TIMCustomElem 定义，其中 data 存储消息的二进制数据，其数据格式由开发者定义，desc 存储描述文本。一条消息内可以有多个自定义 Elem，并且可以跟其他 Elem 混合排列，离线 Push 时叠加每个 Elem 的 desc 描述信息进行下发。
 *
 */
@interface TIMCustomElem : TIMElem

/**
 *  自定义消息二进制数据
 */
@property(nonatomic,strong) NSData * data;
/**
 *  自定义消息描述信息，做离线Push时文本展示（已废弃，请使用 TIMMessage 中 offlinePushInfo 进行配置）
 */
@property(nonatomic,strong) NSString * desc DEPRECATED_ATTRIBUTE;
/**
 *  离线Push时扩展字段信息（已废弃，请使用 TIMMessage 中 offlinePushInfo 进行配置）
 */
@property(nonatomic,strong) NSString * ext DEPRECATED_ATTRIBUTE;
/**
 *  离线Push时声音字段信息（已废弃，请使用 TIMMessage 中 offlinePushInfo 进行配置）
 */
@property(nonatomic,strong) NSString * sound DEPRECATED_ATTRIBUTE;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十一）群 Tips 消息
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  群tips，成员变更信息
 */
@interface TIMGroupTipsElemMemberInfo : NSObject

/**
 *  变更用户
 */
@property(nonatomic,strong) NSString * identifier;
/**
 *  禁言时间（秒，表示还剩多少秒可以发言）
 */
@property(nonatomic,assign) uint32_t shutupTime;

@end

/**
 *  群 tips，群变更信息
 */
@interface TIMGroupTipsElemGroupInfo : NSObject

/**
 *  变更类型
 */
@property(nonatomic, assign) TIM_GROUP_INFO_CHANGE_TYPE type;

/**
 *  根据变更类型表示不同含义
 */
@property(nonatomic,strong) NSString * value;
@end

/**
 *  群Tips
 */
@interface TIMGroupTipsElem : TIMElem

/**
 *  群组Id
 */
@property(nonatomic,strong) NSString * group;

/**
 *  群Tips类型
 */
@property(nonatomic,assign) TIM_GROUP_TIPS_TYPE type;

/**
 *  操作人用户名
 */
@property(nonatomic,strong) NSString * opUser;

/**
 *  被操作人列表 NSString* 数组
 */
@property(nonatomic,strong) NSArray * userList;

/**
 *  在群名变更时表示变更后的群名，否则为 nil
 */
@property(nonatomic,strong) NSString * groupName;

/**
 *  群信息变更： TIM_GROUP_TIPS_TYPE_INFO_CHANGE 时有效，为 TIMGroupTipsElemGroupInfo 结构体列表
 */
@property(nonatomic,strong) NSArray * groupChangeList;

/**
 *  成员变更： TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE 时有效，为 TIMGroupTipsElemMemberInfo 结构体列表
 */
@property(nonatomic,strong) NSArray * memberChangeList;

/**
 *  操作者用户资料
 */
@property(nonatomic,strong) TIMUserProfile * opUserInfo;
/**
 *  操作者群成员资料
 */
@property(nonatomic,strong) TIMGroupMemberInfo * opGroupMemberInfo;
/**
 *  变更成员资料
 */
@property(nonatomic,strong) NSDictionary * changedUserInfo;
/**
 *  变更成员群内资料
 */
@property(nonatomic,strong) NSDictionary * changedGroupMemberInfo;

/**
 *  当前群人数： TIM_GROUP_TIPS_TYPE_INVITE、TIM_GROUP_TIPS_TYPE_QUIT_GRP、
 *             TIM_GROUP_TIPS_TYPE_KICKED时有效
 */
@property(nonatomic,assign) uint32_t memberNum;


/**
 *  操作方平台信息
 *  取值： iOS Android Windows Mac Web RESTAPI Unknown
 */
@property(nonatomic,strong) NSString * platform;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      （十二）群系统消息
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  群系统消息
 */
@interface TIMGroupSystemElem : TIMElem

/**
 * 操作类型
 */
@property(nonatomic,assign) TIM_GROUP_SYSTEM_TYPE type;

/**
 * 群组Id
 */
@property(nonatomic,strong) NSString * group;

/**
 * 操作人
 */
@property(nonatomic,strong) NSString * user;

/**
 * 操作理由
 */
@property(nonatomic,strong) NSString * msg;

/**
 *  消息标识，客户端无需关心
 */
@property(nonatomic,assign) uint64_t msgKey;

/**
 *  消息标识，客户端无需关心
 */
@property(nonatomic,strong) NSData * authKey;

/**
 *  用户自定义透传消息体（type ＝ TIM_GROUP_SYSTEM_CUSTOM_INFO 时有效）
 */
@property(nonatomic,strong) NSData * userData;

/**
 *  操作人资料
 */
@property(nonatomic,strong) TIMUserProfile * opUserInfo;

/**
 *  操作人群成员资料
 */
@property(nonatomic,strong) TIMGroupMemberInfo * opGroupMemberInfo;

/**
 *  操作方平台信息
 *  取值： iOS、Android、Windows、Mac、Web、RESTAPI、Unknown
 */
@property(nonatomic,strong) NSString * platform;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                      （十三）设置消息推送
//
/////////////////////////////////////////////////////////////////////////////////
/**
 填入 sound 字段表示接收时不会播放声音
 */
extern NSString * const kIOSOfflinePushNoSound;

@interface TIMOfflinePushInfo : NSObject
/**
 *  自定义消息描述信息，做离线Push时文本展示
 */
@property(nonatomic,strong) NSString * desc;
/**
 *  离线 Push 时扩展字段信息
 */
@property(nonatomic,strong) NSString * ext;
/**
 *  推送规则标志
 */
@property(nonatomic,assign) TIMOfflinePushFlag pushFlag;
/**
 *  iOS离线推送配置
 */
@property(nonatomic,strong) TIMIOSOfflinePushConfig * iosConfig;
/**
 *  Android离线推送配置
 */
@property(nonatomic,strong) TIMAndroidOfflinePushConfig * androidConfig;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//                      （十四）消息封装
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  消息
 */
@interface TIMMessage : NSObject

/**
 *  增加 Elem
 *
 *  @param elem elem 结构
 *
 *  @return 0：表示成功；1：禁止添加 Elem（文件或语音多于两个 Elem）；2：未知 Elem
 */
- (int)addElem:(TIMElem*)elem;

/**
 *  获取对应索引的 Elem
 *
 *  @param index 对应索引
 *
 *  @return 返回对应 Elem
 */
- (TIMElem*)getElem:(int)index;

/**
 *  获取 Elem 数量
 *
 *  @return elem数量
 */
- (int)elemCount;

/**
 *  设置离线推送配置信息
 *
 *  @param info 配置信息
 *
 *  @return 0 成功
 */
- (int)setOfflinePushInfo:(TIMOfflinePushInfo*)info;

/**
 *  获得本消息离线推送配置信息
 *
 *  @return 配置信息，没设置返回 nil
 */
- (TIMOfflinePushInfo*)getOfflinePushInfo;

/**
 *  设置业务命令字
 *
 *  @param buzCmds 业务命令字列表
 *                 @"im_open_busi_cmd.msg_robot"：表示发送给IM机器人；
 *                 @"im_open_busi_cmd.msg_nodb"：表示不存离线；
 *                 @"im_open_busi_cmd.msg_noramble"：表示不存漫游；
 *                 @"im_open_busi_cmd.msg_nopush"：表示不实时下发给用户
 *
 *  @return 0：成功；1：buzCmds 为 nil
 */
-(int)setBusinessCmd:(NSArray*)buzCmds;

/**
 *  获取会话
 *
 *  @return 该消息所对应会话
 */
- (TIMConversation*)getConversation;

/**
 *  消息状态
 *
 *  @return TIMMessageStatus 消息状态
 */
- (TIMMessageStatus)status;

/**
 *  是否发送方
 *
 *  @return TRUE：表示是发送消息；FALSE：表示是接收消息
 */
- (BOOL)isSelf;

/**
 *  获取发送方
 *
 *  @return 发送方标识
 */
- (NSString*)sender;

/**
 *  消息 Id，当消息生成时，就已经固定，这种方式可能跟其他用户产生的消息冲突，需要再加一个时间约束，可以认为 10 分钟以内的消息可以使用 msgId 区分，需要在同一个会话内判断。
 */
- (NSString*)msgId;

/**
 *  消息 uniqueId，当消息发送成功以后才能固定下来（uniqueId），这种方式能保证全局唯一，需要在同一个会话内判断。
 *
 *  @return uniqueId
 */
- (uint64_t)uniqueId;

/**
 *  当前消息的时间戳
 *
 *  @return 时间戳，该时间是 Server 时间，而非本地时间。在创建消息时，此时间为根据 Server 时间校准过的时间，发送成功后会改为准确的 Server 时间。
 */
- (NSDate*)timestamp;

/**
 *  获取发送者资料
 *
 *  如果本地有发送者资料，这里会直接通过 return 值 TIMUserProfile 返回发送者资料，如果本地没有发送者资料，这里会直接 return nil,SDK 内部会向服务器拉取发送者资料，并在 profileCallBack 回调里面返回发送者资料。
 *
 *  @param  profileCallBack 发送者资料回调
 *
 *  @return 发送者资料，nil 表示本地没有获取到资料
 */
- (TIMUserProfile*)getSenderProfile:(ProfileCallBack)profileCallBack;

/**
 *  获取发送者群内资料（发送者为自己时可能为空）
 *
 *  @return 发送者群内资料，nil 表示没有获取资料或者不是群消息，目前仅能获取字段：member ，其他的字段获取建议通过 TIMGroupManager+Ext.h -> getGroupMembers 获取
 */
- (TIMGroupMemberInfo*)getSenderGroupMemberProfile;

/**
 *  设置消息的优先级
 *
 *  @param priority 优先级
 *
 *  @return TRUE 设置成功
 */
- (BOOL)setPriority:(TIMMessagePriority)priority;

/**
 *  获取消息的优先级（仅对群组消息有效）
 *
 *  对于直播场景，会有点赞和发红包功能，点赞相对优先级较低，红包消息优先级较高，具体消息内容可以使用 TIMCustomElem 进行定义，发送消息时，可设置消息优先级。
 *
 *  @return 优先级
 */
- (TIMMessagePriority)getPriority;

/**
 *  获取消息所属会话的接收消息选项（仅对群组消息有效）
 *
 *  对于群组会话消息，可以通过消息属性判断本群组设置的接收消息选项，可参阅 [群组管理](https://cloud.tencent.com/document/product/269/9152#.E4.BF.AE.E6.94.B9.E6.8E.A5.E6.94.B6.E7.BE.A4.E6.B6.88.E6.81.AF.E9.80.89.E9.A1.B9)。
 *
 *  @return 接收消息选项
 */
- (TIMGroupReceiveMessageOpt)getRecvOpt;

/**
 *  拷贝消息中的属性（ELem、priority、online、offlinePushInfo）
 *
 *  @param srcMsg 源消息
 *
 *  @return 0 成功
 */
- (int)copyFrom:(TIMMessage*)srcMsg;

@end

#endif
