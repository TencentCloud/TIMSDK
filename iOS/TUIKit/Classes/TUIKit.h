//
//  TUIKit.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIKitConfig.h"

typedef void (^TFail)(int code, NSString * msg);
typedef void (^TSucc)(void);

typedef NS_ENUM(NSUInteger, TUserStatus) {
    TUser_Status_ForceOffline,
    TUser_Status_ReConnFailed,
    TUser_Status_SigExpired,
};

typedef NS_ENUM(NSUInteger, TNetStatus) {
    TNet_Status_Succ,
    TNet_Status_Connecting,
    TNet_Status_ConnFailed,
    TNet_Status_Disconnect,
};


@interface TUIKit : NSObject
+ (instancetype)sharedInstance;
- (void)initKit:(NSInteger)sdkAppId accountType:(NSString *)accountType withConfig:(TUIKitConfig *)config;
- (void)loginKit:(NSString *)identifier userSig:(NSString *)sig succ:(TSucc)succ fail:(TFail)fail;
- (void)logoutKit:(TSucc)succ fail:(TFail)fail;
- (TUIKitConfig *)getConfig;
- (NSString *)getSDKVersion;
@end



