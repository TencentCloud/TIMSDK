//
//  TIMMessage+MsgExt.h
//  IMMessageExt
//
//  Created by tomzhu on 2016/12/27.
//
//

#ifndef TIMMessage_h
#define TIMMessage_h

#import "TIMMessage.h"
#import "TIMComm+MsgExt.h"

#pragma mark - Elem类型

/////////////////////////////////////////////////////////////////////////////////
//
//                      （一）关系链变更消息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 关系链变更消息
/// @{
@interface TIMSNSSystemElem : TIMElem

/**
 * 操作类型
 */
@property(nonatomic,assign) TIM_SNS_SYSTEM_TYPE type;

/**
 * 被操作用户列表：TIMSNSChangeInfo 列表
 */
@property(nonatomic,strong) NSArray * users;

/**
 * 未决已读上报时间戳 type = TIM_SNS_SYSTEM_PENDENCY_REPORT 有效
 */
@property(nonatomic,assign) uint64_t pendencyReportTimestamp;

/**
 * 推荐已读上报时间戳 type = TIM_SNS_SYSTEM_RECOMMEND_REPORT 有效
 */
@property(nonatomic,assign) uint64_t recommendReportTimestamp;

/**
 * 已决已读上报时间戳 type = TIM_SNS_SYSTEM_DECIDE_REPORT 有效
 */
@property(nonatomic,assign) uint64_t decideReportTimestamp;

@end

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （二）资料变更消息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 资料变更消息
/// @{
@interface TIMProfileSystemElem : TIMElem

/**
 *  变更类型
 */
@property(nonatomic,assign) TIM_PROFILE_SYSTEM_TYPE type;

/**
 *  资料变更的用户
 */
@property(nonatomic,strong) NSString * fromUser;

/**
 *  资料变更的昵称（暂未实现）
 */
@property(nonatomic,strong) NSString * nickName;

@end

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （三）消息扩展接口
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 消息扩展接口
/// @{
@interface TIMMessage (MsgExt)

/**
 *  自己是否已读
 *
 *  @return TRUE：已读；FALSE：未读
 */
- (BOOL)isReaded;

/**
 *  对方是否已读（仅 C2C 消息有效）
 *
 *  @return TRUE：已读；FALSE：未读
 */
- (BOOL)isPeerReaded;

/**
 *  删除消息
 *
 *  目前暂不支持 Server 消息删除，只能在本地删除。删除后使用 getMessage 拉取本地消息，不会返回被删除的消息。
 *
 *  @return TRUE：成功；FALSE：失败
 */
- (BOOL)remove;

/**
 *  设置自定义整数，默认为 0
 *
 *  1.此自定义字段仅存储于本地，不会同步到 Server，用户卸载应用或则更换终端后无法获取。
 *  2.可以根据这个字段设置语音消息是否已经播放，如 customInt 的值 0 表示未播放，1 表示播放，当用户单击播放后可设置 customInt 的值为 1。
 *
 *  @param param 设置参数
 *
 *  @return TRUE：设置成功；FALSE:设置失败
 */
- (BOOL)setCustomInt:(int32_t)param;

/**
 *  设置自定义数据，默认为""
 *
 *  此自定义字段仅存储于本地，不会同步到 Server，用户卸载应用或则更换终端后无法获取。
 *
 *  @param data 设置参数
 *
 *  @return TRUE：设置成功；FALSE:设置失败
 */
- (BOOL)setCustomData:(NSData*)data;

/**
 *  获取 CustomInt
 *
 *  @return CustomInt
 */
- (int32_t)customInt;

/**
 *  获取 CustomData
 *
 *  @return CustomData
 */
- (NSData*)customData;

/**
 *  获取消息定位符
 *
 *  @return locator，详情请参考 TIMComm.h 里面的 TIMMessageLocator 定义
 */
- (TIMMessageLocator*)locator;

/**
 *  是否为 locator 对应的消息
 *
 *  @param locator 消息定位符
 *
 *  @return YES 是对应的消息
 */
- (BOOL)respondsToLocator:(TIMMessageLocator*)locator;

/**
 *  设置消息时间戳
 *
 *  需要先将消息到导入到本地，调用 convertToImportedMsg 方法
 *
 *  @param time 时间戳
 *
 *  @return 0：成功；1：失败
 */
- (int)setTime:(time_t)time;

/**
 *  设置消息发送方
 *
 *  需要先将消息到导入到本地，调用 convertToImportedMsg 方法
 *
 *  @param sender 发送方Id
 *
 *  @return 0：成功；1：失败
 */
- (int)setSender:(NSString*)sender;

/**
 *  将消息导入到本地
 *
 *  只有调用这个接口，才能去修改消息的时间戳和发送方
 *
 *  @return 0：成功；1：失败
 */
- (int)convertToImportedMsg;

/// @}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                      （四）草稿箱
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 草稿箱
/// @{
@interface TIMMessageDraft : NSObject

/**
 *  设置自定义数据
 *
 *  @param userData 自定义数据
 *
 *  @return 0：成功；1：失败
 */
- (int)setUserData:(NSData*)userData;

/**
 *  获取自定义数据
 *
 *  @return 自定义数据
 */
- (NSData*)getUserData;

/**
 *  增加Elem
 *
 *  @param elem elem结构
 *
 *  @return 0：表示成功；1：禁止添加Elem（文件或语音多于两个Elem)；2：未知Elem
 *
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
 *  获取Elem数量
 *
 *  @return elem数量
 */
- (int)elemCount;

/**
 *  草稿生成对应的消息
 *
 *  @return 消息，详情请参考 TIMMessage.h 里面的 TIMMessage 定义
 */
- (TIMMessage*)transformToMessage;

/**
 *  当前消息的时间戳
 *
 *  @return 时间戳
 */
- (NSDate*)timestamp;

/// @}

@end

#endif /* TIMMessage_h */
