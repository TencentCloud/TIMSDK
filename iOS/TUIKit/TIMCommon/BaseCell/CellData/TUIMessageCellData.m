//
//  TUIMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageCellData.h"
#import <TIMCommon/TIMDefine.h>

@interface TUIMessageCellData ()

@property(nonatomic, assign) CGFloat cellHeight;

@end

@implementation TUIMessageCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    return nil;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return nil;
}

- (Class)getReplyQuoteViewDataClass {
    return nil;
}

- (Class)getReplyQuoteViewClass {
    return nil;
}

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super init];
    if (self) {
        _direction = direction;
        _status = Msg_Status_Init;
        _showReadReceipt = YES;
        _sameToNextMsgSender = NO;
        _showAvatar = YES;
        _cellLayout = [self cellLayout:direction];
        if (direction == MsgDirectionIncoming) {
            _nameFont = [[self class] incommingNameFont];
            _nameColor = [[self class] incommingNameColor];
        } else {
            _nameFont = [[self class] outgoingNameFont];
            _nameColor = [[self class] outgoingNameColor];
        }
    }
    return self;
}

- (TUIMessageCellLayout *)cellLayout:(TMsgDirection)direction {
    if (direction == MsgDirectionIncoming) {
        return [TUIMessageCellLayout incommingMessageLayout];
    } else {
        return [TUIMessageCellLayout outgoingMessageLayout];
    }
}

- (CGFloat)heightOfWidth:(CGFloat)width {
    if (self.cellHeight) {
        return self.cellHeight;
    }

    CGFloat height = 0;

    if (self.showName) {
        height += 20;
    }
    if (self.showMessageModifyReplies) {
        height += 22;
    }
    if (self.messageModifyReactsSize.height > 0) {
        height += self.messageModifyReactsSize.height;
    }

    CGSize containerSize = [self contentSize];
    height += containerSize.height;
    height += self.cellLayout.messageInsets.top + self.cellLayout.messageInsets.bottom;

    if (height < 55) height = 55;

    self.cellHeight = height;
    return self.cellHeight;
}

- (CGSize)contentSize {
    return CGSizeZero;
}

- (BOOL)canForward {
    return YES;
}

- (void)clearCachedCellHeight {
    self.cellHeight = 0;
}

static UIColor *gOutgoingNameColor;

+ (UIColor *)outgoingNameColor {
    if (!gOutgoingNameColor) {
        gOutgoingNameColor = [UIColor d_systemGrayColor];
    }
    return gOutgoingNameColor;
}

+ (void)setOutgoingNameColor:(UIColor *)outgoingNameColor {
    gOutgoingNameColor = outgoingNameColor;
}

static UIFont *gOutgoingNameFont;

+ (UIFont *)outgoingNameFont {
    if (!gOutgoingNameFont) {
        gOutgoingNameFont = [UIFont systemFontOfSize:14];
    }
    return gOutgoingNameFont;
}

+ (void)setOutgoingNameFont:(UIFont *)outgoingNameFont {
    gOutgoingNameFont = outgoingNameFont;
}

static UIColor *gIncommingNameColor;

+ (UIColor *)incommingNameColor {
    if (!gIncommingNameColor) {
        gIncommingNameColor = [UIColor d_systemGrayColor];
    }
    return gIncommingNameColor;
}

+ (void)setIncommingNameColor:(UIColor *)incommingNameColor {
    gIncommingNameColor = incommingNameColor;
}

static UIFont *gIncommingNameFont;

+ (UIFont *)incommingNameFont {
    if (!gIncommingNameFont) {
        gIncommingNameFont = [UIFont systemFontOfSize:14];
    }
    return gIncommingNameFont;
}

+ (void)setIncommingNameFont:(UIFont *)incommingNameFont {
    gIncommingNameFont = incommingNameFont;
}
@end
