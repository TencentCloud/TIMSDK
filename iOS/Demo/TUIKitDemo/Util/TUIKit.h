/** 腾讯云 TUIKit
 *
 *
 *  本类依赖于腾讯云 IM SDK 实现
 *  TUIKit 中的组件在实现 UI 功能的同时，调用 IM SDK 相应的接口实现 IM 相关逻辑和数据的处理
 *  您可以在TUIKit的基础上做一些个性化拓展，即可轻松接入IM SDK
 *
 *
 */

#import <UIKit/UIKit.h>
#import "TUIDefine.h"
#import "TUIProfileCardCell.h"
#import "TUIBubbleMessageCell.h"
#import "TUICommonModel.h"
#import "TUIConversationCell.h"
#import "TUILogin.h"
#import "TUITool.h"

/////////////////////////////////////////////////////////////////////////////////
//        欢迎来到 TUIKit
/////////////////////////////////////////////////////////////////////////////////


/**
 *  TUIKit用户状态枚举
 *
 *  TUser_Status_ForceOffline   用户被强制下线
 *  TUser_Status_ReConnFailed   用户重连失败
 *  TUser_Status_SigExpired     用户身份（usersig）过期
 */
typedef NS_ENUM(NSUInteger, TUIUserStatus) {
    TUser_Status_ForceOffline,
    TUser_Status_ReConnFailed,
    TUser_Status_SigExpired,
};

/**
 *  TUIKit网络状态枚举
 *
 *  TNet_Status_Succ        连接成功
 *  TNet_Status_Connecting  正在连接
 *  TNet_Status_ConnFailed  连接失败
 *  TNet_Status_Disconnect  断开链接
 */
typedef NS_ENUM(NSUInteger, TUINetStatus) {
    TNet_Status_Succ,
    TNet_Status_Connecting,
    TNet_Status_ConnFailed,
    TNet_Status_Disconnect,
};


@interface TUIKit : NSObject

/**
 *  共享实例
 *  TUIKit为单例
 */
+ (instancetype)sharedInstance;

/**
 *  收到音视频通话邀请推送
 */
- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo;

/**
 *  TUIKit 配置类，包含默认表情、默认图标资源等
 */
@property (nonatomic, strong) TUIConfig *config;

/**
 *  TUIKit 网络状态
 */
@property (readonly) TUINetStatus netStatus;


/**
 *  IMSDK sdkAppId
 */
@property (readonly) UInt32 sdkAppId;

/**
 *  userID
 */
@property (readonly) NSString *userID;

/**
 *  userSig
 */
@property (readonly) NSString *userSig;

/**
 * nickName
 */
@property (readonly) NSString *nickName;

/**
 * faceUrl
 */
@property (readonly) NSString *faceUrl;

@end
