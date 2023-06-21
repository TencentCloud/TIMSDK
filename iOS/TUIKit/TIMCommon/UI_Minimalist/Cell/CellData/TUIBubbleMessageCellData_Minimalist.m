//
//  TUIBubbleMessageCellData_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIBubbleMessageCellData_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMessageCellLayout.h"

@implementation TUIBubbleMessageCellData_Minimalist

+ (void)initialize {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onThemeChanged:) name:TUIDidApplyingThemeChangedNotfication object:nil];
}

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            _bubbleTop = [[self class] incommingBubbleTop];

            UIImage *alpha50 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha50")];
            _animateHighlightBubble_alpha50 =
                [TUIChatDynamicImage(@"chat_bubble_receive_alpha50_img", alpha50) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                                 resizingMode:UIImageResizingModeStretch];
            UIImage *alpha20 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha20")];
            _animateHighlightBubble_alpha20 =
                [TUIChatDynamicImage(@"chat_bubble_receive_alpha20_img", alpha20) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                                 resizingMode:UIImageResizingModeStretch];
        } else {
            _bubbleTop = [[self class] outgoingBubbleTop];

            UIImage *alpha50 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha50")];
            _animateHighlightBubble_alpha50 =
                [TUIChatDynamicImage(@"chat_bubble_send_alpha50_img", alpha50) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                              resizingMode:UIImageResizingModeStretch];

            UIImage *alpha20 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha20")];
            _animateHighlightBubble_alpha20 =
                [TUIChatDynamicImage(@"chat_bubble_send_alpha20_img", alpha20) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                              resizingMode:UIImageResizingModeStretch];
        }
    }
    return self;
}

- (UIImage *)bubble {
    UIImage *bubble = nil;
    if (self.direction == MsgDirectionIncoming) {
        bubble = [[self class] incommingBubble];
    } else {
        bubble = [[self class] outgoingBubble];
    }
    _highlightedBubble = bubble;
    return bubble;
}

- (UIImage *)bubble_SameMsg {
    UIImage *bubble_SameMsg = nil;
    if (self.direction == MsgDirectionIncoming) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"ReceiverTextNodeBkg_Same")];
        bubble_SameMsg = [defaultImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
    } else {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"SenderTextNodeBkg_Same")];
        bubble_SameMsg = [defaultImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
    }
    _highlightedBubble_SameMsg = bubble_SameMsg;
    return bubble_SameMsg;
}

static UIImage *gOutgoingBubble;

+ (UIImage *)outgoingBubble {
    if (!gOutgoingBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"SenderTextNodeBkg")];
        gOutgoingBubble = [defaultImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
    }
    return gOutgoingBubble;
}

+ (void)setOutgoingBubble:(UIImage *)outgoingBubble {
    gOutgoingBubble = outgoingBubble;
}

static UIImage *gOutgoingHighlightedBubble;
+ (UIImage *)outgoingHighlightedBubble {
    if (!gOutgoingHighlightedBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"SenderTextNodeBkg")];
        gOutgoingHighlightedBubble = [defaultImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
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
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"ReceiverTextNodeBkg")];
        gIncommingBubble = [defaultImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
    }
    return gIncommingBubble;
}

+ (void)setIncommingBubble:(UIImage *)incommingBubble {
    gIncommingBubble = incommingBubble;
}

static UIImage *gIncommingHighlightedBubble;
+ (UIImage *)incommingHighlightedBubble {
    if (!gIncommingHighlightedBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"ReceiverTextNodeBkg")];
        gIncommingHighlightedBubble = [defaultImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
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

+ (void)onThemeChanged:(NSNotification *)notice {
    gOutgoingBubble = nil;
    gOutgoingHighlightedBubble = nil;

    gIncommingBubble = nil;
    gIncommingHighlightedBubble = nil;
}

@end
