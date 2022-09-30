//
//  TUIChatConfig.m
//  TUIChat
//
//  Created by wyl on 2022/6/10.
//

#import "TUIChatConfig.h"


@implementation TUIChatConfig

- (id)init
{
    self = [super init];
    if(self){
        self.msgNeedReadReceipt = NO;
        self.enableVideoCall = YES;
        self.enableAudioCall = YES;
        self.enableLink = YES;
        self.enablePopMenuEmojiReactAction = YES;
        self.enablePopMenuReplyAction = YES;
        self.enablePopMenuReferenceAction = YES;
        self.enableTypingStatus = YES;
        self.enableFloatWindowForCall = YES;
        self.enableMultiDeviceForCall = NO;
    }
    return self;
}

+ (TUIChatConfig *)defaultConfig {
    static dispatch_once_t onceToken;
    static TUIChatConfig *config;
    dispatch_once(&onceToken, ^{
        config = [[TUIChatConfig alloc] init];
    });
    return config;
}



@end
