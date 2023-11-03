//
//  TUIChatConversationModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/12.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatConversationModel.h"

@implementation TUIChatConversationModel

- (instancetype)init {
    self = [super init];
    if (self){
        self.enabelVideo = YES;
        self.enabelAudio = YES;
        self.enabelRoom  = YES;
        self.isLimitedPortraitOrientation = NO;
    }
    return self;
}
@end
