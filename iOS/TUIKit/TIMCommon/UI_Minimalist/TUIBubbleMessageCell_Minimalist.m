//
//  TUIBubbleMessageCell_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIBubbleMessageCell_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

@implementation TUIBubbleMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bubbleView = [[UIImageView alloc] initWithFrame:self.container.bounds];
        [self.container addSubview:_bubbleView];
        _bubbleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)fillWithData:(TUIBubbleMessageCellData *)data {
    [super fillWithData:data];
    _bubbleData = data;

    if (self.bubbleData.sameToNextMsgSender) {
        self.bubbleView.image = self.getSameMessageBubble;
        self.bubbleView.highlightedImage = self.getHighlightSameMessageBubble;
    } else {
        self.bubbleView.image = self.getBubble;
        self.bubbleView.highlightedImage = self.getHighlightBubble;
    }
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.size.mas_equalTo(self.container);
        make.top.mas_equalTo(self.container);
    }];
    
    CGPoint center = self.retryView.center;
    center.y = self.bubbleView.center.y;
    self.retryView.center = center;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)highlightWhenMatchKeyword:(NSString *)keyword {
    /**
     * The parent class implements the default highlighting effect - flickering
     */
    if (keyword) {
        if (self.highlightAnimating) {
            return;
        }
        [self animate:3];
    }
}

- (void)animate:(int)times {
    times--;
    if (times < 0) {
        if (self.bubbleData.sameToNextMsgSender) {
            self.bubbleView.image = self.getSameMessageBubble;
        } else {
            self.bubbleView.image = self.getBubble;
        }
        self.bubbleView.layer.cornerRadius = 0;
        self.bubbleView.layer.masksToBounds = YES;
        self.highlightAnimating = NO;
        return;
    }

    self.bubbleView.image = self.getAnimateHighlightBubble_alpha50;
    self.bubbleView.layer.cornerRadius = 12;
    self.bubbleView.layer.masksToBounds = YES;
    self.highlightAnimating = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      self.bubbleView.image = self.getAnimateHighlightBubble_alpha20;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.bubbleData.highlightKeyword) {
            [self animate:0];
            return;
        }
        [self animate:times];
      });
    });
}

- (CGFloat)getBubbleTop {
    return [self.class getBubbleTop:self.bubbleData];
}

- (UIImage *)getBubble {
    if (!TIMConfig.defaultConfig.enableMessageBubble) {
        return nil;
    }
    if (self.bubbleData.direction == MsgDirectionIncoming) {
        return self.class.incommingBubble;
    } else {
        return self.class.outgoingBubble;
    }
}

- (UIImage *)getHighlightBubble {
    if (!TIMConfig.defaultConfig.enableMessageBubble) {
        return nil;
    }
    if (self.bubbleData.direction == MsgDirectionIncoming) {
        return self.class.incommingHighlightedBubble;
    } else {
        return self.class.outgoingHighlightedBubble;
    }
}

- (UIImage *)getAnimateHighlightBubble_alpha50 {
    if (!TIMConfig.defaultConfig.enableMessageBubble) {
        return nil;
    }
    if (self.bubbleData.direction == MsgDirectionIncoming) {
        return self.class.incommingAnimatedHighlightedAlpha50;
    } else {
        return self.class.outgoingAnimatedHighlightedAlpha50;
    }
}

- (UIImage *)getAnimateHighlightBubble_alpha20 {
    if (!TIMConfig.defaultConfig.enableMessageBubble) {
        return nil;
    }
    if (self.bubbleData.direction == MsgDirectionIncoming) {
        return self.class.incommingAnimatedHighlightedAlpha20;
    } else {
        return self.class.outgoingAnimatedHighlightedAlpha20;
    }
}

- (UIImage *)getSameMessageBubble {
    if (!TIMConfig.defaultConfig.enableMessageBubble) {
        return nil;
    }
    UIImage *bubble_SameMsg = nil;
    UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
    ei = rtlEdgeInsetsWithInsets(ei);
    if (self.bubbleData.direction == MsgDirectionIncoming) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"ReceiverTextNodeBkg_Same")];
        defaultImage = [defaultImage rtl_imageFlippedForRightToLeftLayoutDirection];
        bubble_SameMsg = [defaultImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
    } else {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"SenderTextNodeBkg_Same")];
        defaultImage = [defaultImage rtl_imageFlippedForRightToLeftLayoutDirection];
        bubble_SameMsg = [defaultImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
    }
    return bubble_SameMsg;
}

- (UIImage *)getHighlightSameMessageBubble {
    if (!TIMConfig.defaultConfig.enableMessageBubble) {
        return nil;
    }
    return self.getSameMessageBubble;
}

+ (CGFloat)getBubbleTop:(TUIBubbleMessageCellData *)data {
    if (data.direction == MsgDirectionIncoming) {
        return self.class.incommingBubbleTop;
    } else {
        return self.class.outgoingBubbleTop;
    }
}

@end

@implementation TUIBubbleMessageCell_Minimalist (TUILayoutConfiguration)

+ (void)initialize {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onThemeChanged:) name:TUIDidApplyingThemeChangedNotfication object:nil];
}

static UIImage *gOutgoingBubble;

+ (UIImage *)outgoingBubble {
    if (!gOutgoingBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"SenderTextNodeBkg")];
        defaultImage = [defaultImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gOutgoingBubble = [defaultImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
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
        defaultImage = [defaultImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gOutgoingHighlightedBubble = [defaultImage resizableImageWithCapInsets:ei
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
        defaultImage = [defaultImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gIncommingBubble = [defaultImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
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
        defaultImage = [defaultImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gIncommingHighlightedBubble = [defaultImage resizableImageWithCapInsets:ei
                                                                   resizingMode:UIImageResizingModeStretch];
    }
    return gIncommingHighlightedBubble;
}

+ (void)setIncommingHighlightedBubble:(UIImage *)incommingHighlightedBubble {
    gIncommingHighlightedBubble = incommingHighlightedBubble;
}

static UIImage *gOutgoingAnimatedHighlightedAlpha50;

+ (UIImage *)outgoingAnimatedHighlightedAlpha50 {
    if (!gOutgoingAnimatedHighlightedAlpha50) {
        UIImage *alpha50 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha50")];
        alpha50 = [alpha50 rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gOutgoingAnimatedHighlightedAlpha50 =
            [TUIChatDynamicImage(@"chat_bubble_send_alpha50_img", alpha50) resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
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
        alpha20 = [alpha20 rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gOutgoingAnimatedHighlightedAlpha20 =
            [TUIChatDynamicImage(@"chat_bubble_send_alpha20_img", alpha20) resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
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
        alpha50 = [alpha50 rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gIncommingAnimatedHighlightedAlpha50 =
            [TUIChatDynamicImage(@"chat_bubble_receive_alpha50_img", alpha50) resizableImageWithCapInsets:ei
                                                                                             resizingMode:UIImageResizingModeStretch];
    }
    return gIncommingAnimatedHighlightedAlpha50;
}

+ (void)setIncommingAnimatedHighlightedAlpha50:(UIImage *)image {
    gIncommingAnimatedHighlightedAlpha50 = image;
}

static UIImage *gIncommingAnimatedHighlightedAlpha20;
+ (UIImage *)incommingAnimatedHighlightedAlpha20 {
    if (!gIncommingAnimatedHighlightedAlpha20) {
        UIImage *alpha20 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha20")];
        alpha20 = [alpha20 rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gIncommingAnimatedHighlightedAlpha20 =
            [TUIChatDynamicImage(@"chat_bubble_receive_alpha20_img", alpha20) resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
    }
    return gIncommingAnimatedHighlightedAlpha20;
}

+ (void)setIncommingAnimatedHighlightedAlpha20:(UIImage *)image {
    gIncommingAnimatedHighlightedAlpha20 = image;
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
    gOutgoingAnimatedHighlightedAlpha50 = nil;
    gOutgoingAnimatedHighlightedAlpha20 = nil;

    gIncommingBubble = nil;
    gIncommingHighlightedBubble = nil;
    gIncommingAnimatedHighlightedAlpha50 = nil;
    gIncommingAnimatedHighlightedAlpha20 = nil;
}

@end
