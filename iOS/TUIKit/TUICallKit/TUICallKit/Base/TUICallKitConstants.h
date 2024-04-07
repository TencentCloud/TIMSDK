//
//  TUICallKitConstants.h
//  TUICallKit
//
//  Created by noah on 2022/12/22.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Signaling timeout duration, default 30s
static const int TUI_CALLKIT_SIGNALING_MAX_TIME = 30;
// Default avatar
static NSString * const TUI_CALL_DEFAULT_AVATAR = @"https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png";

@interface TUICallKitConstants : NSObject

@end

NS_ASSUME_NONNULL_END
