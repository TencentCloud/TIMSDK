//
//  NSTimer+TUISafe.h
//  TUICore
//
//  Created by wyl on 2022/7/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (TUISafe)
+ (NSTimer *)tui_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;
@end

NS_ASSUME_NONNULL_END
