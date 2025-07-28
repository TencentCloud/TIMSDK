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
        self.msgNeedReadReceipt = YES;
        self.enableVideoCall = YES;
        self.enableAudioCall = YES;
        self.enableRoom  = YES;
        self.enableWelcomeCustomMessage  = YES;
        self.isLimitedPortraitOrientation = NO;
        self.enablePoll = YES;
        self.enableGroupNote = YES;
        self.enableTakePhoto = YES;
        self.enableRecordVideo = YES;
        self.enableAlbum = YES;
        self.enableFile = YES;
    }
    return self;
}

- (BOOL)isAIConversation {
    BOOL isAIConversation = [self.conversationID containsString:@"@RBT#"] ||
                           [self.conversationID hasPrefix:@"@RBT#"];
    return isAIConversation;
}

- (BOOL)msgNeedReadReceipt {
    if ([self isAIConversation]) {
        return NO;
    }
    return _msgNeedReadReceipt;
}
@end
