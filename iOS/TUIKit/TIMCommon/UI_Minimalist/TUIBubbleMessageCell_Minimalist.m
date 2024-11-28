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
        _bubbleView.userInteractionEnabled = YES;
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
    return self.bubbleData.direction == MsgDirectionIncoming ? self.class.incommingSameBubble : self.class.outgoingSameBubble;
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

#pragma mark - gOutgoingBubble
static UIImage *gOutgoingBubble;
+ (UIImage *)outgoingBubble {
    if (!gOutgoingBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"SenderTextNodeBkg")];
        [self setOutgoingBubble:defaultImage];
    }
    return gOutgoingBubble;
}
+ (void)setOutgoingBubble:(UIImage *)outgoingBubble {
    gOutgoingBubble = [self stretchImage:outgoingBubble];
}

#pragma mark - gOutgoingSameBubble
static UIImage *gOutgoingSameBubble;
+ (UIImage *)outgoingSameBubble {
    if (!gOutgoingSameBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"SenderTextNodeBkg_Same")];
        [self setOutgoingSameBubble:defaultImage];
    }
    return gOutgoingSameBubble;
}
+ (void)setOutgoingSameBubble:(UIImage *)outgoingSameBubble {
    gOutgoingSameBubble = [self stretchImage:outgoingSameBubble];
}

#pragma mark - gOutgoingHighlightedBubble
static UIImage *gOutgoingHighlightedBubble;
+ (UIImage *)outgoingHighlightedBubble {
    if (!gOutgoingHighlightedBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"SenderTextNodeBkg")];
        [self setOutgoingHighlightedBubble:defaultImage];
    }
    return gOutgoingHighlightedBubble;
}
+ (void)setOutgoingHighlightedBubble:(UIImage *)outgoingHighlightedBubble {
    gOutgoingHighlightedBubble = [self stretchImage:outgoingHighlightedBubble];
}

#pragma mark - gOutgoingAnimatedHighlightedAlpha20
static UIImage *gOutgoingAnimatedHighlightedAlpha20;
+ (UIImage *)outgoingAnimatedHighlightedAlpha20 {
    if (!gOutgoingAnimatedHighlightedAlpha20) {
        UIImage *alpha20 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha20")];
        [self setOutgoingAnimatedHighlightedAlpha20:TUIChatDynamicImage(@"chat_bubble_send_alpha20_img", alpha20)];
    }
    return gOutgoingAnimatedHighlightedAlpha20;
}
+ (void)setOutgoingAnimatedHighlightedAlpha20:(UIImage *)outgoingAnimatedHighlightedAlpha20 {
    gOutgoingAnimatedHighlightedAlpha20 = [self stretchImage:outgoingAnimatedHighlightedAlpha20];
}

#pragma mark - gOutgoingAnimatedHighlightedAlpha50
static UIImage *gOutgoingAnimatedHighlightedAlpha50;
+ (UIImage *)outgoingAnimatedHighlightedAlpha50 {
    if (!gOutgoingAnimatedHighlightedAlpha50) {
        UIImage *alpha50 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha50")];
        [self setOutgoingAnimatedHighlightedAlpha50:TUIChatDynamicImage(@"chat_bubble_send_alpha50_img", alpha50)];
    }
    return gOutgoingAnimatedHighlightedAlpha50;
}
+ (void)setOutgoingAnimatedHighlightedAlpha50:(UIImage *)outgoingAnimatedHighlightedAlpha50 {
    gOutgoingAnimatedHighlightedAlpha50 = [self stretchImage:outgoingAnimatedHighlightedAlpha50];
}

#pragma mark - gIncommingBubble
static UIImage *gIncommingBubble;
+ (UIImage *)incommingBubble {
    if (!gIncommingBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"ReceiverTextNodeBkg")];
        [self setIncommingBubble:defaultImage];
    }
    return gIncommingBubble;
}
+ (void)setIncommingBubble:(UIImage *)incommingBubble {
    gIncommingBubble = [self stretchImage:incommingBubble];
}

#pragma mark - gIncommingSameBubble
static UIImage *gIncommingSameBubble;
+ (UIImage *)incommingSameBubble {
    if (!gIncommingSameBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"ReceiverTextNodeBkg_Same")];
        [self setIncommingSameBubble:defaultImage];
    }
    return gIncommingSameBubble;
}
+ (void)setIncommingSameBubble:(UIImage *)incommingSameBubble {
    gIncommingSameBubble = [self stretchImage:incommingSameBubble];
}

#pragma mark - gIncommingHighlightedBubble
static UIImage *gIncommingHighlightedBubble;
+ (UIImage *)incommingHighlightedBubble {
    if (!gIncommingHighlightedBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"ReceiverTextNodeBkg")];
        [self setIncommingHighlightedBubble:defaultImage];
    }
    return gIncommingHighlightedBubble;
}
+ (void)setIncommingHighlightedBubble:(UIImage *)incommingHighlightedBubble {
    gIncommingHighlightedBubble = [self stretchImage:incommingHighlightedBubble];
}

#pragma mark - gIncommingAnimatedHighlightedAlpha20
static UIImage *gIncommingAnimatedHighlightedAlpha20;
+ (UIImage *)incommingAnimatedHighlightedAlpha20 {
    if (!gIncommingAnimatedHighlightedAlpha20) {
        UIImage *alpha20 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha20")];
        [self setIncommingAnimatedHighlightedAlpha20:TUIChatDynamicImage(@"chat_bubble_receive_alpha20_img", alpha20)];
    }
    return gIncommingAnimatedHighlightedAlpha20;
}
+ (void)setIncommingAnimatedHighlightedAlpha20:(UIImage *)incommingAnimatedHighlightedAlpha20 {
    gIncommingAnimatedHighlightedAlpha20 = [self stretchImage:incommingAnimatedHighlightedAlpha20];
}

#pragma mark - gIncommingAnimatedHighlightedAlpha50
static UIImage *gIncommingAnimatedHighlightedAlpha50;
+ (UIImage *)incommingAnimatedHighlightedAlpha50 {
    if (!gIncommingAnimatedHighlightedAlpha50) {
        UIImage *alpha50 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg_alpha50")];
        [self setIncommingAnimatedHighlightedAlpha50:TUIChatDynamicImage(@"chat_bubble_receive_alpha50_img", alpha50)];
    }
    return gIncommingAnimatedHighlightedAlpha50;
}
+ (void)setIncommingAnimatedHighlightedAlpha50:(UIImage *)incommingAnimatedHighlightedAlpha50 {
    gIncommingAnimatedHighlightedAlpha50 = [self stretchImage:incommingAnimatedHighlightedAlpha50];
}

+ (UIImage *)stretchImage:(UIImage *)oldImage {
    UIImage *image = [oldImage rtl_imageFlippedForRightToLeftLayoutDirection];
    UIEdgeInsets insets = rtlEdgeInsetsWithInsets(UIEdgeInsetsFromString(@"{12,12,12,12}"));
    return [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
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
