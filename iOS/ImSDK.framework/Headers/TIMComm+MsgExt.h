//
//  TIMComm+MsgExt.h
//  IMMessageExt
//
//  Created by tomzhu on 2017/1/11.
//
//

#ifndef TIMComm_MsgExt_h
#define TIMComm_MsgExt_h

#import <Foundation/Foundation.h>
#import "TIMComm.h"

@class TIMSendToUsersDetailInfo;

#pragma mark - 枚举类型

typedef NS_ENUM(NSInteger, TIM_SNS_SYSTEM_TYPE){
    /**
     *  增加好友消息
     */
    TIM_SNS_SYSTEM_ADD_FRIEND                           = 0x01,
    /**
     *  删除好友消息
     */
    TIM_SNS_SYSTEM_DEL_FRIEND                           = 0x02,
    /**
     *  增加好友申请
     */
    TIM_SNS_SYSTEM_ADD_FRIEND_REQ                       = 0x03,
    /**
     *  删除未决申请
     */
    TIM_SNS_SYSTEM_DEL_FRIEND_REQ                       = 0x04,
    /**
     *  黑名单添加
     */
    TIM_SNS_SYSTEM_ADD_BLACKLIST                        = 0x05,
    /**
     *  黑名单删除
     */
    TIM_SNS_SYSTEM_DEL_BLACKLIST                        = 0x06,
    /**
     *  未决已读上报
     */
    TIM_SNS_SYSTEM_PENDENCY_REPORT                      = 0x07,
    /**
     *  关系链资料变更
     */
    TIM_SNS_SYSTEM_SNS_PROFILE_CHANGE                   = 0x08,
    /**
     *  推荐数据增加
     */
    TIM_SNS_SYSTEM_ADD_RECOMMEND                        = 0x09,
    /**
     *  推荐数据删除
     */
    TIM_SNS_SYSTEM_DEL_RECOMMEND                        = 0x0a,
    /**
     *  已决增加
     */
    TIM_SNS_SYSTEM_ADD_DECIDE                           = 0x0b,
    /**
     *  已决删除
     */
    TIM_SNS_SYSTEM_DEL_DECIDE                           = 0x0c,
    /**
     *  推荐已读上报
     */
    TIM_SNS_SYSTEM_RECOMMEND_REPORT                     = 0x0d,
    /**
     *  已决已读上报
     */
    TIM_SNS_SYSTEM_DECIDE_REPORT                        = 0x0e,
    
    
};

/**
 *  资料变更
 */
typedef NS_ENUM(NSInteger, TIM_PROFILE_SYSTEM_TYPE){
    /**
     好友资料变更
     */
    TIM_PROFILE_SYSTEM_FRIEND_PROFILE_CHANGE        = 0x01,
};

#pragma mark - block回调

typedef void (^TIMSendToUsersFail)(int code, NSString *err, TIMSendToUsersDetailInfo *detailInfo);

#pragma mark - 基本类型

/**
 *  发送消息给多用户的失败回调信息
 */
@interface TIMSendToUsersDetailInfo : NSObject
/**
 *  发送消息成功的目标用户数
 */
@property(nonatomic,assign) uint32_t succCnt;
/**
 *  发送消息失败的目标用户数
 */
@property(nonatomic,assign) uint32_t failCnt;
/**
 *  失败信息（TIMSendToUsersErrInfo*）列表
 */
@property(nonatomic,strong) NSArray *errInofs;
@end

/**
 *  发送消息给多用户的失败信息
 */
@interface TIMSendToUsersErrInfo : NSObject
/**
 *  发送消息失败的目标用户id
 */
@property(nonatomic,strong) NSString *identifier;
/**
 *  错误码
 */
@property(nonatomic,assign) int code;
/**
 *  错误描述
 */
@property(nonatomic,strong) NSString *err;
@end

/**
 *  关系链变更详细信息
 */
@interface TIMSNSChangeInfo : NSObject

/**
 *  用户 identifier
 */
@property(nonatomic,strong) NSString * identifier;

/**
 *  用户昵称
 */
@property(nonatomic,strong) NSString * nickname;

/**
 *  申请添加时有效，添加理由
 */
@property(nonatomic,strong) NSString * wording;

/**
 *  申请时填写，添加来源
 */
@property(nonatomic,strong) NSString * source;


/**
 *  备注 type=TIM_SNS_SYSTEM_SNS_PROFILE_CHANGE 有效
 */
@property(nonatomic,strong) NSString * remark;

@end

#endif /* TIMComm_MsgExt_h */
