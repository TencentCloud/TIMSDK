//
//  TUIBubbleMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIBubbleMessageCellData.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIBubbleMessageCellData

+ (void)initialize
{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onThemeChanged:) name:TUIDidApplyingThemeChangedNotfication object:nil];
}

- (instancetype)initWithDirection:(TMsgDirection)direction
{
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

static UIImage *sOutgoingBubble;

+ (UIImage *)outgoingBubble
{
    if (!sOutgoingBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg")];
        sOutgoingBubble = [TUIChatDynamicImage(@"chat_bubble_send_img", defaultImage) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
    }
    return sOutgoingBubble;
}

+ (void)setOutgoingBubble:(UIImage *)outgoingBubble
{
    sOutgoingBubble = outgoingBubble;
}

static UIImage *sOutgoingHighlightedBubble;
+ (UIImage *)outgoingHighlightedBubble
{
    if (!sOutgoingHighlightedBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkgHL")];
        sOutgoingHighlightedBubble = [TUIChatDynamicImage(@"chat_bubble_send_img", defaultImage) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
    }
    return sOutgoingHighlightedBubble;
}

+ (void)setOutgoingHighlightedBubble:(UIImage *)outgoingHighlightedBubble
{
    sOutgoingHighlightedBubble = outgoingHighlightedBubble;
}

static UIImage *sIncommingBubble;
+ (UIImage *)incommingBubble
{
    if (!sIncommingBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg")];
        sIncommingBubble = [TUIChatDynamicImage(@"chat_bubble_receive_img", defaultImage) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
    }
    return sIncommingBubble;
}

+ (void)setIncommingBubble:(UIImage *)incommingBubble
{
    sIncommingBubble = incommingBubble;
}

static UIImage *sIncommingHighlightedBubble;
+ (UIImage *)incommingHighlightedBubble
{
    if (!sIncommingHighlightedBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkgHL")];
        sIncommingHighlightedBubble =[TUIChatDynamicImage(@"chat_bubble_receive_img", defaultImage) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
    }
    return sIncommingHighlightedBubble;
}

+ (void)setIncommingHighlightedBubble:(UIImage *)incommingHighlightedBubble
{
    sIncommingHighlightedBubble = incommingHighlightedBubble;
}


static CGFloat sOutgoingBubbleTop = 0;

+ (CGFloat)outgoingBubbleTop
{
    return sOutgoingBubbleTop;
}

+ (void)setOutgoingBubbleTop:(CGFloat)outgoingBubble
{
    sOutgoingBubbleTop = outgoingBubble;
}

static CGFloat sIncommingBubbleTop = 0;

+ (CGFloat)incommingBubbleTop
{
    return sIncommingBubbleTop;
}

+ (void)setIncommingBubbleTop:(CGFloat)incommingBubbleTop
{
    sIncommingBubbleTop = incommingBubbleTop;
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
        _animateHighlightBubble_alpha50 = (self.direction == MsgDirectionIncoming) ? self.class.incommingAnimatedHighlightedAlpha50 : self.class.outgoingAnimatedHighlightedAlpha50;
    }
    return _animateHighlightBubble_alpha50;
}

- (UIImage *)animateHighlightBubble_alpha20 {
    if (_animateHighlightBubble_alpha20 == nil) {
        _animateHighlightBubble_alpha20 = (self.direction == MsgDirectionIncoming) ? self.class.incommingAnimatedHighlightedAlpha20 : self.class.outgoingAnimatedHighlightedAlpha20;
    }
    return _animateHighlightBubble_alpha20;
}

static UIImage *sOutgoingAnimatedHighlightedAlpha50;

+ (UIImage *)outgoingAnimatedHighlightedAlpha50
{
    if (!sOutgoingAnimatedHighlightedAlpha50) {
        UIImage *alpha50 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha50")];
        sOutgoingAnimatedHighlightedAlpha50 = [TUIChatDynamicImage(@"chat_bubble_send_alpha50_img", alpha50) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                            resizingMode:UIImageResizingModeStretch];
    }
    return sOutgoingAnimatedHighlightedAlpha50;
}

+ (void)setOutgoingAnimatedHighlightedAlpha50:(UIImage *)image
{
    sOutgoingAnimatedHighlightedAlpha50 = image;
}

static UIImage *sOutgoingAnimatedHighlightedAlpha20;

+ (UIImage *)outgoingAnimatedHighlightedAlpha20
{
    if (!sOutgoingAnimatedHighlightedAlpha20) {
        UIImage *alpha20 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha20")];
        sOutgoingAnimatedHighlightedAlpha20 = [TUIChatDynamicImage(@"chat_bubble_send_alpha20_img", alpha20) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                            resizingMode:UIImageResizingModeStretch];
    }
    return sOutgoingAnimatedHighlightedAlpha20;
}

+ (void)setOutgoingAnimatedHighlightedAlpha20:(UIImage *)image
{
    sOutgoingAnimatedHighlightedAlpha20 = image;
}


static UIImage *sIncommingAnimatedHighlightedAlpha50;
+ (UIImage *)incommingAnimatedHighlightedAlpha50
{
    if (!sIncommingAnimatedHighlightedAlpha50) {
        UIImage *alpha50 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha50")];
        sIncommingAnimatedHighlightedAlpha50 = [TUIChatDynamicImage(@"chat_bubble_receive_alpha50_img", alpha50) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                            resizingMode:UIImageResizingModeStretch];
    }
    return sIncommingAnimatedHighlightedAlpha50;
}

+ (void)setsIncommingAnimatedHighlightedAlpha50:(UIImage *)image
{
    sIncommingAnimatedHighlightedAlpha50 = image;
}

static UIImage *sIncommingAnimatedHighlightedAlpha20;
+ (UIImage *)incommingAnimatedHighlightedAlpha20
{
    if (!sIncommingAnimatedHighlightedAlpha20) {
        UIImage *alpha20 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha20")];
        sIncommingAnimatedHighlightedAlpha20 = [TUIChatDynamicImage(@"chat_bubble_receive_alpha20_img", alpha20) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                            resizingMode:UIImageResizingModeStretch];
    }
    return sIncommingAnimatedHighlightedAlpha20;
}

+ (void)setsIncommingAnimatedHighlightedAlpha20:(UIImage *)image
{
    sIncommingAnimatedHighlightedAlpha20 = image;
}


+ (void)onThemeChanged:(NSNotification *)notice
{
    sOutgoingBubble = nil;
    sOutgoingHighlightedBubble = nil;
    sOutgoingAnimatedHighlightedAlpha50 = nil;
    sOutgoingAnimatedHighlightedAlpha20 = nil;
    
    sIncommingBubble = nil;
    sIncommingHighlightedBubble = nil;
    sIncommingAnimatedHighlightedAlpha50 = nil;
    sIncommingAnimatedHighlightedAlpha20 = nil;
    
}

@end
