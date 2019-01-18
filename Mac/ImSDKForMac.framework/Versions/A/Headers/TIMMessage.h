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

/**
 *  消息Elem基类
 */
@interface TIMElem : NSObject
@end

/**
 *  文本消息Elem
 */
@interface TIMTextElem : TIMElem
/**
 *  消息文本
 */
@property(nonatomic,strong) NSString * text;
@end

#pragma mark - 普通消息类型

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
 *  @param path 图片保存路径
 *  @param succ 成功回调，返回图片数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getImage:(NSString*)path succ:(TIMSucc)succ fail:(TIMFail)fail;
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
 *  所有类型图片，只读
 */
@property(nonatomic,strong) NSArray * imageList;

/**
 * 上传时任务Id，可用来查询上传进度
 */
@property(nonatomic,assign) uint32_t taskId;

/**
 *  图片压缩等级，详见 TIM_IMAGE_COMPRESS_TYPE（仅对jpg格式有效）
 */
@property(nonatomic,assign) TIM_IMAGE_COMPRESS_TYPE level;

/**
 *  图片格式，详见 TIM_IMAGE_FORMAT
 */
@property(nonatomic,assign) TIM_IMAGE_FORMAT format;

@end

/**
 *  文件消息Elem
 */
@interface TIMFileElem : TIMElem
/**
 *  上传时任务Id，可用来查询上传进度
 */
@property(nonatomic,assign) uint32_t taskId;
/**
 *  上传时，文件的路径（设置path时，优先上传文件）
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
 *  @param path 文件保存路径
 *  @param succ 成功回调，返回数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getFile:(NSString*)path succ:(TIMSucc)succ fail:(TIMFail)fail;
- (void)getFile:(NSString*)path progress:(TIMProgress)progress succ:(TIMSucc)succ fail:(TIMFail)fail;

@end

/**
 *  语音消息Elem
 */
@interface TIMSoundElem : TIMElem
/**
 *  上传时任务Id，可用来查询上传进度
 */
@property(nonatomic,assign) uint32_t taskId;
/**
 *  上传时，语音文件的路径，接收时使用getSound获得数据
 */
@property(nonatomic,strong) NSString * path;
/**
 *  语音消息内部ID
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
 *  @param path 语音保存路径
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getSound:(NSString*)path succ:(TIMSucc)succ fail:(TIMFail)fail;
- (void)getSound:(NSString*)path progress:(TIMProgress)progress succ:(TIMSucc)succ fail:(TIMFail)fail;

@end

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


/**
 *  自定义消息类型
 */
@interface TIMCustomElem : TIMElem

/**
 *  自定义消息二进制数据
 */
@property(nonatomic,strong) NSData * data;
/**
 *  自定义消息描述信息，做离线Push时文本展示（已废弃，请使用TIMMessage中offlinePushInfo进行配置）
 */
@property(nonatomic,strong) NSString * desc DEPRECATED_ATTRIBUTE;
/**
 *  离线Push时扩展字段信息（已废弃，请使用TIMMessage中offlinePushInfo进行配置）
 */
@property(nonatomic,strong) NSString * ext DEPRECATED_ATTRIBUTE;
/**
 *  离线Push时声音字段信息（已废弃，请使用TIMMessage中offlinePushInfo进行配置）
 */
@property(nonatomic,strong) NSString * sound DEPRECATED_ATTRIBUTE;
@end

/**
 *  表情消息类型
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

@interface TIMVideo : NSObject
/**
 *  视频ID，不用设置
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
 *  @param path 视频保存路径
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getVideo:(NSString*)path succ:(TIMSucc)succ fail:(TIMFail)fail;
- (void)getVideo:(NSString*)path progress:(TIMProgress)progress succ:(TIMSucc)succ fail:(TIMFail)fail;
@end


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
 *  @param path 图片保存路径
 *  @param succ 成功回调，返回图片数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void)getImage:(NSString*)path succ:(TIMSucc)succ fail:(TIMFail)fail;
- (void)getImage:(NSString*)path progress:(TIMProgress)progress succ:(TIMSucc)succ fail:(TIMFail)fail;

@end

/**
 *  微视频消息
 */
@interface TIMVideoElem : TIMElem

/**
 *  上传时任务Id，可用来查询上传进度
 */
@property(nonatomic,assign) uint32_t taskId;

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

#pragma mark - 群系统消息和tip消息

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
 *  群tips，群变更信息
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
 *  用户自定义透传消息体（type＝TIM_GROUP_SYSTEM_CUSTOM_INFO时有效）
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
 *  取值： iOS Android Windows Mac Web RESTAPI Unknown
 */
@property(nonatomic,strong) NSString * platform;

@end

#pragma mark - 消息体TIMMessage

/**
 填入sound字段表示接收时不会播放声音
 */
extern NSString * const kIOSOfflinePushNoSound;

@interface TIMOfflinePushInfo : NSObject
/**
 *  自定义消息描述信息，做离线Push时文本展示
 */
@property(nonatomic,strong) NSString * desc;
/**
 *  离线Push时扩展字段信息
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


/**
 *  消息
 */
@interface TIMMessage : NSObject

/**
 *  增加Elem
 *
 *  @param elem elem结构
 *
 *  @return 0       表示成功
 *          1       禁止添加Elem（文件或语音多于两个Elem）
 *          2       未知Elem
 */
- (int)addElem:(TIMElem*)elem;

/**
 *  获取对应索引的Elem
 *
 *  @param index 对应索引
 *
 *  @return 返回对应Elem
 */
- (TIMElem*)getElem:(int)index;

/**
 *  获取Elem数量
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
 *  @return 配置信息，没设置返回nil
 */
- (TIMOfflinePushInfo*)getOfflinePushInfo;

/**
 *  设置业务命令字
 *
 *  @param buzCmds 业务命令字列表
 *                 @"im_open_busi_cmd.msg_robot" 表示发送给IM机器人
 *                 @"im_open_busi_cmd.msg_nodb" 表示不存离线
 *                 @"im_open_busi_cmd.msg_noramble" 表示不存漫游
 *                 @"im_open_busi_cmd.msg_nopush" 表示不实时下发给用户
 *
 *  @return 0 成功
 */
-(int) setBusinessCmd:(NSArray*)buzCmds;

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
 *  @return TRUE 表示是发送消息    FALSE 表示是接收消息
 */
- (BOOL)isSelf;

/**
 *  获取发送方
 *
 *  @return 发送方标识
 */
- (NSString*)sender;

/**
 *  消息Id
 */
- (NSString*)msgId;

/**
 *  获取消息uniqueId
 *
 *  @return uniqueId
 */
- (uint64_t)uniqueId;

/**
 *  当前消息的时间戳
 *
 *  @return 时间戳
 */
- (NSDate*)timestamp;


/**
 *  获取发送者资料（发送者为自己时可能为空）
 *
 *  @return 发送者资料，nil 表示没有获取资料，目前只有字段：identifier、nickname、faceURL、customInfo
 */
- (TIMUserProfile*)getSenderProfile;

/**
 *  获取发送者群内资料（发送者为自己时可能为空）
 *
 *  @return 发送者群内资料，nil 表示没有获取资料或者不是群消息，目前只有字段：member、nameCard、role、customInfo
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
 *  获取消息的优先级
 *
 *  @return 优先级
 */
- (TIMMessagePriority)getPriority;

/**
 *  获取消息所属会话的接收消息选项（仅对群组消息有效）
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
