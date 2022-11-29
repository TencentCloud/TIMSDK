//
//  TUIBubbleMessageCellData_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIBubbleMessageCellData_Minimalist.h"
#import "TUIMessageCellLayout.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

@implementation TUIBubbleMessageCellData_Minimalist

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
            
            UIImage *alpha50 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha50")];
            _animateHighlightBubble_alpha50 = [TUIChatDynamicImage(@"chat_bubble_receive_alpha50_img", alpha50) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                                resizingMode:UIImageResizingModeStretch];
            UIImage *alpha20 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha20")];
            _animateHighlightBubble_alpha20 = [TUIChatDynamicImage(@"chat_bubble_receive_alpha20_img", alpha20) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                                resizingMode:UIImageResizingModeStretch];
        } else {
            _bubbleTop = [[self class] outgoingBubbleTop];
            
            UIImage *alpha50 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha50")];
            _animateHighlightBubble_alpha50 = [TUIChatDynamicImage(@"chat_bubble_send_alpha50_img", alpha50) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                                resizingMode:UIImageResizingModeStretch];
            
            UIImage *alpha20 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha20")];
            _animateHighlightBubble_alpha20 = [TUIChatDynamicImage(@"chat_bubble_send_alpha20_img", alpha20) resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
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


static UIImage *sOutgoingBubble;

+ (UIImage *)outgoingBubble
{
    if (!sOutgoingBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"SenderTextNodeBkg")];
        sOutgoingBubble = [defaultImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
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
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"SenderTextNodeBkg")];
        sOutgoingHighlightedBubble = [defaultImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
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
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"ReceiverTextNodeBkg")];
        sIncommingBubble = [defaultImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
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
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"ReceiverTextNodeBkg")];
        sIncommingHighlightedBubble =[defaultImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
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

+ (void)onThemeChanged:(NSNotification *)notice
{
    sOutgoingBubble = nil;
    sOutgoingHighlightedBubble = nil;
    
    sIncommingBubble = nil;
    sIncommingHighlightedBubble = nil;
}

@end
