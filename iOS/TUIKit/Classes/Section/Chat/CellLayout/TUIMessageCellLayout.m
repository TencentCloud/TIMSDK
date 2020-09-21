//
//  TUIMessageCellLayout.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIMessageCellLayout.h"
#import "THeader.h"

@implementation TUIMessageCellLayout

- (instancetype)init:(BOOL)isIncomming
{
    self = [super init];
    if (self) {
        self.avatarSize = CGSizeMake(40, 40);
        if (isIncomming) {
            self.avatarInsets = (UIEdgeInsets){
                .left = 8,
                .top = 3,
                .bottom = 1,
            };
            self.messageInsets = (UIEdgeInsets){
                .top = 3,
                .bottom = 1,
                .left = 8,
            };
        } else {
            self.avatarInsets = (UIEdgeInsets){
                .right = 8,
                .top = 3,
                .bottom = 1,
            };
            self.messageInsets = (UIEdgeInsets){
                .top = 3,
                .bottom = 1,
                .right = 8,
            };
        }
    }
    return self;
}

static TUIMessageCellLayout *sIncommingMessageLayout;

+ (TUIMessageCellLayout *)incommingMessageLayout
{
    if (!sIncommingMessageLayout) {
        sIncommingMessageLayout = [[TUIMessageCellLayout alloc] init:YES];
    }
    return sIncommingMessageLayout;
}

static TUIMessageCellLayout *sOutgoingMessageLayout;

+ (TUIMessageCellLayout *)outgoingMessageLayout
{
    if (!sOutgoingMessageLayout) {
        sOutgoingMessageLayout = [[TUIMessageCellLayout alloc] init:NO];
    }
    return sOutgoingMessageLayout;
}

#pragma Text CellLayout

static TUIMessageCellLayout *sIncommingTextMessageLayout;

+ (TUIMessageCellLayout *)incommingTextMessageLayout
{
    if (!sIncommingTextMessageLayout) {
        sIncommingTextMessageLayout = [[TUIMessageCellLayout alloc] init:YES];
        sIncommingTextMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 16, .left = 16, .right = 16};
    }
    return sIncommingTextMessageLayout;
}

static TUIMessageCellLayout *sOutgingTextMessageLayout;

+ (TUIMessageCellLayout *)outgoingTextMessageLayout
{
    if (!sOutgingTextMessageLayout) {
        sOutgingTextMessageLayout = [[TUIMessageCellLayout alloc] init:NO];
        sOutgingTextMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 16, .left = 16, .right = 16};
    }
    return sOutgingTextMessageLayout;
}


#pragma Voice CellLayout

static TUIMessageCellLayout *sIncommingVoiceMessageLayout;

+ (TUIMessageCellLayout *)incommingVoiceMessageLayout
{
    if (!sIncommingVoiceMessageLayout) {
        sIncommingVoiceMessageLayout = [[TUIMessageCellLayout alloc] init:YES];
        sIncommingVoiceMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 20, .left = 19, .right = 22};
    }
    return sIncommingVoiceMessageLayout;
}

static TUIMessageCellLayout *sOutgingVoiceMessageLayout;

+ (TUIMessageCellLayout *)outgoingVoiceMessageLayout
{
    if (!sOutgingVoiceMessageLayout) {
        sOutgingVoiceMessageLayout = [[TUIMessageCellLayout alloc] init:NO];
        sOutgingVoiceMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 20, .left = 22, .right = 20};
    }
    return sOutgingVoiceMessageLayout;
}

#pragma System CellLayout

static TUIMessageCellLayout *sSystemMessageLayout;

+ (TUIMessageCellLayout *)systemMessageLayout
{
    if (!sSystemMessageLayout) {
        sSystemMessageLayout = [[TUIMessageCellLayout alloc] init:YES];
        sSystemMessageLayout.messageInsets = (UIEdgeInsets){.top = 5, .bottom = 5};
    }
    return sSystemMessageLayout;
}

@end
