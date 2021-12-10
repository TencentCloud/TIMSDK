//
//  TUIBubbleMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIBubbleMessageCellData.h"
#import "TUIDefine.h"

@implementation TUIBubbleMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            _bubble = [[self class] incommingBubble];
            _highlightedBubble = [[self class] incommingHighlightedBubble];
            _bubbleTop = [[self class] incommingBubbleTop];
            _animateHighlightBubble_alpha50 = [[[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha50")]
                                                                        resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                       resizingMode:UIImageResizingModeStretch];
            _animateHighlightBubble_alpha20 = [[[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha20")]
                                                                        resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                       resizingMode:UIImageResizingModeStretch];
        } else {
            _bubble = [[self class] outgoingBubble];
            _highlightedBubble = [[self class] outgoingHighlightedBubble];
            _bubbleTop = [[self class] outgoingBubbleTop];
            _animateHighlightBubble_alpha50 = [[[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha50")]
                                                                        resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                       resizingMode:UIImageResizingModeStretch];
            _animateHighlightBubble_alpha20 = [[[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha20")]
                                                                        resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}")
                                                                                       resizingMode:UIImageResizingModeStretch];
        }
    }
    return self;
}


static UIImage *sOutgoingBubble;

+ (UIImage *)outgoingBubble
{
    if (!sOutgoingBubble) {
        sOutgoingBubble = [[[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
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
        sOutgoingHighlightedBubble = [[[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkgHL")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
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
        sIncommingBubble = [[[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
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
        sIncommingHighlightedBubble =[[[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkgHL")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{12,12,12,12}") resizingMode:UIImageResizingModeStretch];
    }
    return sIncommingHighlightedBubble;
}

+ (void)setIncommingHighlightedBubble:(UIImage *)incommingHighlightedBubble
{
    sIncommingHighlightedBubble = incommingHighlightedBubble;
}


static CGFloat sOutgoingBubbleTop = -2;

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

@end
