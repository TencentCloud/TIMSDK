/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：V2TIMManager+LiveActivity
//
//  消息 LiveActivity 推送接口
//
/////////////////////////////////////////////////////////////////////

#import "V2TIMManager.h"

@class V2TIMLiveActivityConfig;

V2TIM_EXPORT @interface V2TIMManager (LiveActivity)

/**
 *  1.1 设置 LiveActivity 远端推送配置；当 config 为 nil 时，清除所有的远端推送配置
 */
- (void)setLiveActivity:(V2TIMLiveActivityConfig * _Nullable)config succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setLiveActivity(config:succ:fail:));


@end


V2TIM_EXPORT @interface V2TIMLiveActivityConfig : NSObject

/**
 * 创建 LiveActivity 时自定义的 activityID，用来标识该 LiveActivity
 */
@property(nonatomic,strong) NSString *activityID;

/**
 * LiveActivity token
 */
@property (nonatomic, strong, nullable) NSData *token;

/**
 * IM 控制台上传的 P8 证书 ID
 */
@property (nonatomic, assign) int businessID;

@end
