//
//  TUIKit.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIKitConfig.h"
#import "TUIImageCache.h"
#import "UIImage+TUIKIT.h"
#import "NSDate+TUIKIT.h"
#import "TUIChatController.h"
#import "TUIBubbleMessageCell.h"
#import "TIMUserProfile+DataProvider.h"
#import "TUIProfileCardCell.h"
#import "TUIButtonCell.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "TUILocalStorage.h"

typedef NS_ENUM(NSUInteger, TUIUserStatus) {
    TUser_Status_ForceOffline,
    TUser_Status_ReConnFailed,
    TUser_Status_SigExpired,
};

typedef NS_ENUM(NSUInteger, TUINetStatus) {
    TNet_Status_Succ,
    TNet_Status_Connecting,
    TNet_Status_ConnFailed,
    TNet_Status_Disconnect,
};


@interface TUIKit : NSObject
+ (instancetype)sharedInstance;

- (void)setupWithAppId:(NSInteger)sdkAppId;

@property TUIKitConfig *config;
@property (readonly) TUINetStatus netStatus;

@end



