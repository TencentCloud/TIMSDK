//
//  TUILiveConfig.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by coddyliu on 2020/9/23.
//

#import "TUILiveConfig.h"

@implementation TUILiveConfig

- (instancetype)initWithUseCDNFirst:(BOOL)userCDNFirst cdnPlayDomain:(NSString *)cdnPlayDomain {
    self = [super init];
    if (self) {
        self.useCDNFirst = userCDNFirst;
        self.cdnPlayDomain = cdnPlayDomain;
    }
    return self;
}

@end
