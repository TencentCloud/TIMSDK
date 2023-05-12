//
//  TUILog.m
//  TUICallEngine
//
//  Created by noah on 2022/8/3.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUILog.h"
#import "TRTCCloud.h"

@interface TRTCCloud (CallingLog)

- (void)apiLog:(NSString *)log;

@end

void callingAPILog(NSString *format, ...) {
    if (!format || ![format isKindOfClass:[NSString class]] || format.length == 0) {
        return;
    }
    va_list arguments;
    va_start(arguments, format);
    NSString *content = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    if (content) {
        [[TRTCCloud sharedInstance] apiLog:content];
    }
}

@implementation TUILog

@end
