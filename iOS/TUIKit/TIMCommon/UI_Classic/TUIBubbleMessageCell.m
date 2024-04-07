//
//  TBubbleMessageCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIBubbleMessageCell.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>

@implementation TUIBubbleMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bubbleView = [[UIImageView alloc] initWithFrame:self.container.bounds];
        [self.container addSubview:_bubbleView];
        _bubbleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.securityStrikeView = [[TUISecurityStrikeView alloc] init];
        [self.bubbleView addSubview:self.securityStrikeView];

    }
    return self;
}

- (void)fillWithData:(TUIBubbleMessageCellData *)data {
    [super fillWithData:data];
    self.bubbleData = data;
    self.bubbleView.image = self.getBubble;
    self.bubbleView.highlightedImage = self.getHighlightBubble;
    self.securityStrikeView.hidden = YES;
    BOOL hasRiskContent = self.messageData.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        self.bubbleView.image =  [self getErrorBubble];
        self.securityStrikeView.hidden = NO;
    }
    
    [self prepareReactTagUI:self.container];
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
        self.bubbleView.image = self.getBubble;
        self.highlightAnimating = NO;
        return;
    }
    self.highlightAnimating = YES;
    self.bubbleView.image = self.getAnimateHighlightBubble_alpha50;
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

- (UIImage *)getErrorBubble {
    if (self.bubbleData.direction == MsgDirectionIncoming) {
        return self.class.incommingErrorBubble;
    } else {
        return self.class.outgoingErrorBubble;
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

- (void)prepareReactTagUI:(UIView *)containerView {
    NSDictionary *param = @{TUICore_TUIChatExtension_ChatMessageReactPreview_Delegate: self};
    [TUICore raiseExtension:TUICore_TUIChatExtension_ChatMessageReactPreview_ClassicExtensionID parentView:containerView param:param];
}

+ (CGFloat)getBubbleTop:(TUIBubbleMessageCellData *)data {
    if (data.direction == MsgDirectionIncoming) {
        return self.class.incommingBubbleTop;
    } else {
        return self.class.outgoingBubbleTop;
    }
}

@end


@implementation TUIBubbleMessageCell (TUILayoutConfiguration)

+ (void)initialize {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onThemeChanged:) name:TUIDidApplyingThemeChangedNotfication object:nil];
}

static UIImage *gOutgoingBubble;

+ (UIImage *)outgoingBubble {
    if (!gOutgoingBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg")];
        UIImage *formatImage = TUIChatDynamicImage(@"chat_bubble_send_img", defaultImage);
        formatImage = [formatImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gOutgoingBubble = [formatImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
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
        UIImage *formatImage = TUIChatDynamicImage(@"chat_bubble_send_img", defaultImage);
        formatImage = [formatImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gOutgoingHighlightedBubble = [formatImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
    }
    return gOutgoingHighlightedBubble;
}

+ (void)setOutgoingHighlightedBubble:(UIImage *)outgoingHighlightedBubble {
    gOutgoingHighlightedBubble = outgoingHighlightedBubble;
}

static UIImage *gOutgoingErrorBubble;
+ (UIImage *)outgoingErrorBubble {
    if (!gOutgoingErrorBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg")];
        UIImage *formatImage = TUIChatDynamicImage(@"chat_bubble_send_img", defaultImage);
        formatImage = [TUISecurityStrikeView changeImageColorWith:[UIColor tui_colorWithHex:@"#FA5151" alpha:0.16] image:formatImage alpha:1];
        formatImage = [formatImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gOutgoingErrorBubble = [formatImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
    }
    return gOutgoingErrorBubble;
}

static UIImage *gIncommingBubble;
+ (UIImage *)incommingBubble {
    if (!gIncommingBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg")];
        UIImage *formatImage = TUIChatDynamicImage(@"chat_bubble_receive_img", defaultImage);
        formatImage = [formatImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gIncommingBubble = [formatImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
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
        UIImage *formatImage = TUIChatDynamicImage(@"chat_bubble_receive_img", defaultImage);
        formatImage = [formatImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gIncommingHighlightedBubble = [formatImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
    }
    return gIncommingHighlightedBubble;
}

+ (void)setIncommingHighlightedBubble:(UIImage *)incommingHighlightedBubble {
    gIncommingHighlightedBubble = incommingHighlightedBubble;
}

static UIImage *gIncommingErrorBubble;
+ (UIImage *)incommingErrorBubble {
    if (!gIncommingErrorBubble) {
        UIImage *defaultImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"ReceiverTextNodeBkg")];
        UIImage *formatImage = TUIChatDynamicImage(@"chat_bubble_receive_img", defaultImage);
        formatImage = [TUISecurityStrikeView changeImageColorWith:[UIColor tui_colorWithHex:@"#FA5151" alpha:0.16] image:formatImage alpha:1];
        formatImage = [formatImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gIncommingErrorBubble = [formatImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
    }
    return gIncommingErrorBubble;
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


static UIImage *gOutgoingAnimatedHighlightedAlpha50;

+ (UIImage *)outgoingAnimatedHighlightedAlpha50 {
    if (!gOutgoingAnimatedHighlightedAlpha50) {
        UIImage *alpha50 = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"SenderTextNodeBkg_alpha50")];
        UIImage *formatImage = TUIChatDynamicImage(@"chat_bubble_send_alpha50_img", alpha50);
        formatImage = [formatImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gOutgoingAnimatedHighlightedAlpha50 = [formatImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
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
        UIImage *formatImage = TUIChatDynamicImage(@"chat_bubble_send_alpha20_img", alpha20);
        formatImage = [formatImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gOutgoingAnimatedHighlightedAlpha20 = [formatImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
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
        UIImage *formatImage = TUIChatDynamicImage(@"chat_bubble_receive_alpha50_img", alpha50);
        formatImage = [formatImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gIncommingAnimatedHighlightedAlpha50 = [formatImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
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
        UIImage *formatImage = TUIChatDynamicImage(@"chat_bubble_receive_alpha20_img", alpha20);
        formatImage = [formatImage rtl_imageFlippedForRightToLeftLayoutDirection];
        UIEdgeInsets ei = UIEdgeInsetsFromString(@"{12,12,12,12}");
        ei = rtlEdgeInsetsWithInsets(ei);
        gIncommingAnimatedHighlightedAlpha20 = [formatImage resizableImageWithCapInsets:ei resizingMode:UIImageResizingModeStretch];
    }
    return gIncommingAnimatedHighlightedAlpha20;
}

+ (void)setIncommingAnimatedHighlightedAlpha20:(UIImage *)image {
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
