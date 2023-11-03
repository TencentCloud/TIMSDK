//
//  TUIMessageCellLayout.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageCellLayout.h"
#import <TIMCommon/TIMDefine.h>

@implementation TUIMessageCellLayout

- (instancetype)init:(BOOL)isIncomming {
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
                .bottom = 17,
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
                .bottom = 17,
                .right = 8,
            };
        }
    }
    return self;
}

static TUIMessageCellLayout *gIncommingMessageLayout;

+ (TUIMessageCellLayout *)incommingMessageLayout {
    if (!gIncommingMessageLayout) {
        gIncommingMessageLayout = [[TUIMessageCellLayout alloc] init:YES];
    }
    return gIncommingMessageLayout;
}

static TUIMessageCellLayout *gOutgoingMessageLayout;

+ (TUIMessageCellLayout *)outgoingMessageLayout {
    if (!gOutgoingMessageLayout) {
        gOutgoingMessageLayout = [[TUIMessageCellLayout alloc] init:NO];
    }
    return gOutgoingMessageLayout;
}

#pragma Text CellLayout

static TUIMessageCellLayout *gIncommingTextMessageLayout;

+ (TUIMessageCellLayout *)incommingTextMessageLayout {
    if (!gIncommingTextMessageLayout) {
        gIncommingTextMessageLayout = [[TUIMessageCellLayout alloc] init:YES];
        gIncommingTextMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 10.5, .bottom = 10.5, .left = 16, .right = 16};
    }
    return gIncommingTextMessageLayout;
}

static TUIMessageCellLayout *gOutgingTextMessageLayout;

+ (TUIMessageCellLayout *)outgoingTextMessageLayout {
    if (!gOutgingTextMessageLayout) {
        gOutgingTextMessageLayout = [[TUIMessageCellLayout alloc] init:NO];
        gOutgingTextMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 10.5, .bottom = 10.5, .left = 16, .right = 16};
    }
    return gOutgingTextMessageLayout;
}

#pragma Voice CellLayout

static TUIMessageCellLayout *gIncommingVoiceMessageLayout;

+ (TUIMessageCellLayout *)incommingVoiceMessageLayout {
    if (!gIncommingVoiceMessageLayout) {
        gIncommingVoiceMessageLayout = [[TUIMessageCellLayout alloc] init:YES];
        gIncommingVoiceMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 12, .bottom = 12, .left = 16, .right = 16};
    }
    return gIncommingVoiceMessageLayout;
}

static TUIMessageCellLayout *gOutgingVoiceMessageLayout;

+ (TUIMessageCellLayout *)outgoingVoiceMessageLayout {
    if (!gOutgingVoiceMessageLayout) {
        gOutgingVoiceMessageLayout = [[TUIMessageCellLayout alloc] init:NO];
        gOutgingVoiceMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 20, .left = 22, .right = 20};
    }
    return gOutgingVoiceMessageLayout;
}

#pragma System CellLayout

static TUIMessageCellLayout *gSystemMessageLayout;

+ (TUIMessageCellLayout *)systemMessageLayout {
    if (!gSystemMessageLayout) {
        gSystemMessageLayout = [[TUIMessageCellLayout alloc] init:YES];
        gSystemMessageLayout.messageInsets = (UIEdgeInsets){.top = 5, .bottom = 5};
    }
    return gSystemMessageLayout;
}

#pragma Image CellLayout

static TUIMessageCellLayout *gIncommingImageMessageLayout;
+ (TUIMessageCellLayout *)incommingImageMessageLayout {
    if (!gIncommingImageMessageLayout) {
        gIncommingImageMessageLayout = [[TUIMessageCellLayout alloc] init:YES];
        gIncommingImageMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 0, .bottom = 0, .left = 0 ,.right = 0};
    }
    return gIncommingImageMessageLayout;
}

static TUIMessageCellLayout *gOutgoingImageMessageLayout;
+ (TUIMessageCellLayout *)outgoingImageMessageLayout {
    if (!gOutgoingImageMessageLayout) {
        gOutgoingImageMessageLayout = [[TUIMessageCellLayout alloc] init:NO];
        gOutgoingImageMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 0, .bottom = 0, .left = 0 ,.right = 0};
    }
    return gOutgoingImageMessageLayout;
}

#pragma Video CellLayout
static TUIMessageCellLayout *gIncommingVideoMessageLayout;

+ (TUIMessageCellLayout *)incommingVideoMessageLayout {
    if (!gIncommingVideoMessageLayout) {
        gIncommingVideoMessageLayout = [[TUIMessageCellLayout alloc] init:YES];
        gIncommingVideoMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 0, .bottom = 0, .left = 0 ,.right = 0};
    }
    return gIncommingVideoMessageLayout;
}

static TUIMessageCellLayout *gOutgoingVideoMessageLayout;

+ (TUIMessageCellLayout *)outgoingVideoMessageLayout {
    if (!gOutgoingVideoMessageLayout) {
        gOutgoingVideoMessageLayout = [[TUIMessageCellLayout alloc] init:NO];
        gOutgoingVideoMessageLayout.bubbleInsets = (UIEdgeInsets){.top = 0, .bottom = 0, .left = 0 ,.right = 0};
    }
    return gOutgoingVideoMessageLayout;
}

@end
