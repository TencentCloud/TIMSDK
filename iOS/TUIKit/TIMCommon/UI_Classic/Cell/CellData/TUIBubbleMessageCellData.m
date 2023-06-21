//
//  TUIBubbleMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIBubbleMessageCellData.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIBubbleMessageCellData

+ (void)initialize {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onThemeChanged:) name:TUIDidApplyingThemeChangedNotfication object:nil];
}

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            _bubbleTop = [[self class] incommingBubbleTop];
        } else {
            _bubbleTop = [[self class] outgoingBubbleTop];
        }
    }
    return self;
}

static UIImage *gOutgoingBubble;

+ (UIImage *)outgoingBubble {
    if (!gOutgoingBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg")];
        gOutgoingBubble = [TUIChatDynamicImage(@"chat_bubble_send_img", defaultImage) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                                     resizingMode:UIImageResizingModeStretch];
    }
    return gOutgoingBubble;
}

+ (void)setOutgoingBubble:(UIImage *)outgoingBubble {
    gOutgoingBubble = outgoingBubble;
}

static UIImage *gOutgoingHighlightedBubble;
+ (UIImage *)outgoingHighlightedBubble {
    if (!gOutgoingHighlightedBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkgHL")];
        gOutgoingHighlightedBubble =
            [TUIChatDynamicImage(@"chat_bubble_send_img", defaultImage) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                       resizingMode:UIImageResizingModeStretch];
    }
    return gOutgoingHighlightedBubble;
}

+ (void)setOutgoingHighlightedBubble:(UIImage *)outgoingHighlightedBubble {
    gOutgoingHighlightedBubble = outgoingHighlightedBubble;
}

static UIImage *gIncommingBubble;
+ (UIImage *)incommingBubble {
    if (!gIncommingBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg")];
        gIncommingBubble = [TUIChatDynamicImage(@"chat_bubble_receive_img", defaultImage) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                                         resizingMode:UIImageResizingModeStretch];
    }
    return gIncommingBubble;
}

+ (void)setIncommingBubble:(UIImage *)incommingBubble {
    gIncommingBubble = incommingBubble;
}

static UIImage *gIncommingHighlightedBubble;
+ (UIImage *)incommingHighlightedBubble {
    if (!gIncommingHighlightedBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkgHL")];
        gIncommingHighlightedBubble =
            [TUIChatDynamicImage(@"chat_bubble_receive_img", defaultImage) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                          resizingMode:UIImageResizingModeStretch];
    }
    return gIncommingHighlightedBubble;
}

+ (void)setIncommingHighlightedBubble:(UIImage *)incommingHighlightedBubble {
    gIncommingHighlightedBubble = incommingHighlightedBubble;
}

static CGFloat gOutgoingBubbleTop = 0;

+ (CGFloat)outgoingBubbleTop {
    return gOutgoingBubbleTop;
}

+ (void)setOutgoingBubbleTop:(CGFloat)outgoingBubble {
    gOutgoingBubbleTop = outgoingBubble;
}

static CGFloat gIncommingBubbleTop = 0;

+ (CGFloat)incommingBubbleTop {
    return gIncommingBubbleTop;
}

+ (void)setIncommingBubbleTop:(CGFloat)incommingBubbleTop {
    gIncommingBubbleTop = incommingBubbleTop;
}

- (UIImage *)bubble {
    if (_bubble == nil) {
        _bubble = (self.direction == MsgDirectionIncoming) ? self.class.incommingBubble : self.class.outgoingBubble;
    }
    return _bubble;
}

- (UIImage *)highlightedBubble {
    if (_highlightedBubble == nil) {
        _highlightedBubble = (self.direction == MsgDirectionIncoming) ? self.class.incommingHighlightedBubble : self.class.outgoingHighlightedBubble;
    }
    return _highlightedBubble;
}

- (UIImage *)animateHighlightBubble_alpha50 {
    if (_animateHighlightBubble_alpha50 == nil) {
        _animateHighlightBubble_alpha50 =
            (self.direction == MsgDirectionIncoming) ? self.class.incommingAnimatedHighlightedAlpha50 : self.class.outgoingAnimatedHighlightedAlpha50;
    }
    return _animateHighlightBubble_alpha50;
}

- (UIImage *)animateHighlightBubble_alpha20 {
    if (_animateHighlightBubble_alpha20 == nil) {
        _animateHighlightBubble_alpha20 =
            (self.direction == MsgDirectionIncoming) ? self.class.incommingAnimatedHighlightedAlpha20 : self.class.outgoingAnimatedHighlightedAlpha20;
    }
    return _animateHighlightBubble_alpha20;
}

static UIImage *gOutgoingAnimatedHighlightedAlpha50;

+ (UIImage *)outgoingAnimatedHighlightedAlpha50 {
    if (!gOutgoingAnimatedHighlightedAlpha50) {
        UIImage *alpha50 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha50")];
        gOutgoingAnimatedHighlightedAlpha50 =
            [TUIChatDynamicImage(@"chat_bubble_send_alpha50_img", alpha50) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                          resizingMode:UIImageResizingModeStretch];
    }
    return gOutgoingAnimatedHighlightedAlpha50;
}

+ (void)setOutgoingAnimatedHighlightedAlpha50:(UIImage *)image {
    gOutgoingAnimatedHighlightedAlpha50 = image;
}

static UIImage *gOutgoingAnimatedHighlightedAlpha20;

+ (UIImage *)outgoingAnimatedHighlightedAlpha20 {
    if (!gOutgoingAnimatedHighlightedAlpha20) {
        UIImage *alpha20 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha20")];
        gOutgoingAnimatedHighlightedAlpha20 =
            [TUIChatDynamicImage(@"chat_bubble_send_alpha20_img", alpha20) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                          resizingMode:UIImageResizingModeStretch];
    }
    return gOutgoingAnimatedHighlightedAlpha20;
}

+ (void)setOutgoingAnimatedHighlightedAlpha20:(UIImage *)image {
    gOutgoingAnimatedHighlightedAlpha20 = image;
}

static UIImage *gIncommingAnimatedHighlightedAlpha50;
+ (UIImage *)incommingAnimatedHighlightedAlpha50 {
    if (!gIncommingAnimatedHighlightedAlpha50) {
        UIImage *alpha50 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha50")];
        gIncommingAnimatedHighlightedAlpha50 =
            [TUIChatDynamicImage(@"chat_bubble_receive_alpha50_img", alpha50) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                             resizingMode:UIImageResizingModeStretch];
    }
    return gIncommingAnimatedHighlightedAlpha50;
}

+ (void)setgIncommingAnimatedHighlightedAlpha50:(UIImage *)image {
    gIncommingAnimatedHighlightedAlpha50 = image;
}

static UIImage *gIncommingAnimatedHighlightedAlpha20;
+ (UIImage *)incommingAnimatedHighlightedAlpha20 {
    if (!gIncommingAnimatedHighlightedAlpha20) {
        UIImage *alpha20 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha20")];
        gIncommingAnimatedHighlightedAlpha20 =
            [TUIChatDynamicImage(@"chat_bubble_receive_alpha20_img", alpha20) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                             resizingMode:UIImageResizingModeStretch];
    }
    return gIncommingAnimatedHighlightedAlpha20;
}

+ (void)setgIncommingAnimatedHighlightedAlpha20:(UIImage *)image {
    gIncommingAnimatedHighlightedAlpha20 = image;
}

+ (void)onThemeChanged:(NSNotification *)notice {
    gOutgoingBubble = nil;
    gOutgoingHighlightedBubble = nil;
    gOutgoingAnimatedHighlightedAlpha50 = nil;
    gOutgoingAnimatedHighlightedAlpha20 = nil;

    gIncommingBubble = nil;
    gIncommingHighlightedBubble = nil;
    gIncommingAnimatedHighlightedAlpha50 = nil;
    gIncommingAnimatedHighlightedAlpha20 = nil;
}

@end
