//
//  TIMMessage+MsgExt.h
//  IMMessageExt
//
//  Created by tomzhu on 2016/12/27.
//
//

#ifndef TIMMessage_h
#define TIMMessage_h

#import "ImSDK.h"
#import "TIMComm+MsgExt.h"

#pragma mark - Elem类型

/**
 *  关系链变更消息
 */
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
 * 未决已读上报时间戳 type=TIM_SNS_SYSTEM_PENDENCY_REPORT 有效
 */
@property(nonatomic,assign) uint64_t pendencyReportTimestamp;

/**
 * 推荐已读上报时间戳 type=TIM_SNS_SYSTEM_RECOMMEND_REPORT 有效
 */
@property(nonatomic,assign) uint64_t recommendReportTimestamp;

/**
 * 已决已读上报时间戳 type=TIM_SNS_SYSTEM_DECIDE_REPORT 有效
 */
@property(nonatomic,assign) uint64_t decideReportTimestamp;

@end

/**
 *  资料变更系统消息
 */
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
 *  资料变更的昵称（如果昵称没有变更，该值为nil）
 */
@property(nonatomic,strong) NSString * nickName;

@end

#pragma mark - 消息扩展

@interface TIMMessage (MsgExt)

/**
 *  是否已读
 *
 *  @return TRUE 已读  FALSE 未读
 */
- (BOOL)isReaded;

/**
 *  对方是否已读（仅C2C消息有效）
 *
 *  @return TRUE 已读  FALSE 未读
 */
- (BOOL)isPeerReaded;

/**
 *  删除消息
 *
 *  @return TRUE 成功
 */
- (BOOL)remove;

/**
 *  消息有断层，OnNewMessage回调收到消息，如果有断层，需要重新GetMessage补全（有C2C漫游的情况下使用）
 *
 *  @return TRUE 有断层
 *          FALSE  无断层
 */
- (BOOL)hasGap;

/**
 *  设置自定义整数，默认为0
 *
 *  @param param 设置参数
 *
 *  @return TRUE 设置成功
 */
- (BOOL)setCustomInt:(int32_t)param;

/**
 *  设置自定义数据，默认为""
 *
 *  @param data 设置参数
 *
 *  @return TRUE 设置成功
 */
- (BOOL)setCustomData:(NSData*)data;

/**
 *  获取CustomInt
 *
 *  @return CustomInt
 */
- (int32_t)customInt;

/**
 *  获取CustomData
 *
 *  @return CustomData
 */
- (NSData*)customData;

/**
 *  获取消息定位符
 *
 *  @return locator
 */
- (TIMMessageLocator*)locator;

/**
 *  是否为locator对应的消息
 *
 *  @param locator 消息定位符
 *
 *  @return YES 是对应的消息
 */
- (BOOL)respondsToLocator:(TIMMessageLocator*)locator;

/**
 *  设置消息时间戳，导入到本地时有效
 *
 *  @param time 时间戳
 *
 *  @return 0 成功
 */
- (int)setTime:(time_t)time;

/**
 *  设置消息发送方（需要先将消息到导入到本地，调用 convertToImportedMsg 方法）

 *
 *  @param sender 发送方Id
 *
 *  @return 0 成功
 */
- (int)setSender:(NSString*)sender;

/**
 *  将消息导入到本地
 *
 *  @return 0 成功
 */
- (int)convertToImportedMsg;

@end

#pragma mark - 消息草稿

@interface TIMMessageDraft : NSObject

/**
 *  设置自定义数据
 *
 *  @param userData 自定义数据
 *
 *  @return 0 成功
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
 *  草稿生成对应的消息
 *
 *  @return 消息
 */
- (TIMMessage*)transformToMessage;

/**
 *  当前消息的时间戳
 *
 *  @return 时间戳
 */
- (NSDate*)timestamp;

@end

#endif /* TIMMessage_h */
