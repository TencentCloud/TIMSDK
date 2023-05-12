//
//  TUILog.h
//  TUICallEngine
//
//  Created by noah on 2022/8/3.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TUILog(fmt, ...) callingAPILog(fmt, ##__VA_ARGS__)

FOUNDATION_EXPORT void callingAPILog(NSString *format, ...);

NS_ASSUME_NONNULL_BEGIN

@interface TUILog : NSObject

@end

NS_ASSUME_NONNULL_END
