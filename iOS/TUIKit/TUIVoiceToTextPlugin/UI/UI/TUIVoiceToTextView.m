
//  Created by Tencent on 2023/08/17.
//  Copyright © 2023 Tencent. All rights reserved.
//
//  TUIVoiceToTextView.m
//  TUIVoiceToText
//

#import "TUIVoiceToTextView.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TUIMessageCellData.h>
#import <TIMCommon/TUITextView.h>
#import <TUIChat/TUIChatPopMenu.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIVoiceToTextDataProvider.h"

@interface TUIVoiceToTextView ()

@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) NSString *tips;
@property(nonatomic, strong) UIColor *bgColor;

@property(nonatomic, strong) UIImageView *loadingView;
@property(nonatomic, strong) TUITextView *textView;

@property(nonatomic, strong) TUIMessageCellData *cellData;

@end

@implementation TUIVoiceToTextView

- (instancetype)initWithBackgroundColor:(UIColor *)color {
    self.bgColor = color;
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithData:(TUIMessageCellData *)data {
    self = [super init];
    if (self) {
        self.cellData = data;

        BOOL shouldShow = [TUIVoiceToTextDataProvider shouldShowConvertedText:data.innerMessage];
        if (shouldShow) {
            [self setupViews];
            [self setupGesture];
            [self refreshWithData:data];
        } else {
            if (!CGSizeEqualToSize(self.cellData.bottomContainerSize, CGSizeZero)) {
                [self notifyConversionChanged];
            }
            self.hidden = YES;
            [self stopLoading];
            self.cellData.bottomContainerSize = CGSizeZero;
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self setupGesture];
    }
    return self;
}

- (void)refreshWithData:(TUIMessageCellData *)cellData {
    self.text = [TUIVoiceToTextDataProvider getConvertedText:cellData.innerMessage];
    TUIVoiceToTextViewStatus status = [TUIVoiceToTextDataProvider getConvertedTextStatus:cellData.innerMessage];

    CGSize size = [self calcSizeOfStatus:status];
    if (!CGSizeEqualToSize(self.cellData.bottomContainerSize, size)) {
        [self notifyConversionChanged];
    }
    self.cellData.bottomContainerSize = size;
    self.mm_top(0).mm_left(0).mm_width(size.width).mm_height(size.height);
    
    if (status == TUIVoiceToTextViewStatusLoading) {
        [self startLoading];
    } else if (status == TUIVoiceToTextViewStatusShown) {
        [self stopLoading];
        [self updateConversionViewByText:self.text];
    }
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];
    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (CGSize)calcSizeOfStatus:(TUIVoiceToTextViewStatus)status {
    CGFloat minTextWidth = 164;
    CGFloat maxTextWidth = Screen_Width * 0.68;
    CGFloat actualTextWidth = 80 - 20;  // 80 is the fixed container width.
    CGFloat oneLineTextHeight = 22;
    CGFloat commonMargins = 11 * 2;

    // Conversion is processing, return the size of an empty cell including loading animation.
    if (status == TUIVoiceToTextViewStatusLoading) {
        return CGSizeMake(80, oneLineTextHeight + commonMargins);
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];

    // Conversion is finished.
    // Calc the size according to the actual text width.
    NSString *rtlText = rtlString(self.text);
    CGRect textRect = [rtlText boundingRectWithSize:CGSizeMake(actualTextWidth, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16],
                                                      NSParagraphStyleAttributeName: paragraphStyle}
                                            context:nil];
    if (textRect.size.height < 30) {
        // Result is only one line text.
        return CGSizeMake(MAX(textRect.size.width, minTextWidth) + commonMargins,
                          MAX(textRect.size.height, oneLineTextHeight) + commonMargins);
    }

    // Result is more than one line, so recalc size using maxTextWidth.
    textRect = [rtlText boundingRectWithSize:CGSizeMake(maxTextWidth, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16],
                                               NSParagraphStyleAttributeName: paragraphStyle}
                                     context:nil];
    return CGSizeMake(MAX(textRect.size.width, minTextWidth) + commonMargins,
                      MAX(textRect.size.height, oneLineTextHeight) + commonMargins);
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = self.bgColor ?: TUIVoiceToTextDynamicColor(@"convert_voice_text_view_bg_color", @"#F2F7FF");
    self.layer.cornerRadius = 10.0;

    self.loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [self.loadingView setImage:TUIVoiceToTextBundleThemeImage(@"convert_voice_text_view_icon_loading_img", @"convert_voice_text_loading")];
    self.loadingView.hidden = YES;
    [self addSubview:self.loadingView];

    self.textView = [[TUITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.scrollEnabled = NO;
    self.textView.editable = NO;
    self.textView.textAlignment = isRTL() ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.textColor = TUIVoiceToTextDynamicColor(@"convert_voice_text_view_text_color", @"#000000");
    [self addSubview:self.textView];
    self.textView.hidden = YES;
    self.textView.userInteractionEnabled = NO;
}

- (void)setupGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress addTarget:self action:@selector(onLongPressed:)];
    [self addGestureRecognizer:longPress];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [super updateConstraints];
 
    if (self.text.length == 0) {
        [self.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(15);
            make.leading.mas_equalTo(10);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        MASAttachKeys(self.loadingView);
    } else {
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(10);
            make.trailing.mas_equalTo(-10);
            make.top.bottom.mas_equalTo(10);
        }];
        MASAttachKeys(self.textView);
    }
}

- (void)updateConversionViewByText:(NSString *)text {
    BOOL isConverted = text.length > 0;
    if (isConverted) {
        self.textView.text = rtlString(text);
    }
    self.textView.hidden = !isConverted;
}

#pragma mark - Public
- (void)startLoading {
    if (!self.loadingView.hidden) {
        return;
    }

    self.loadingView.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotate.toValue = @(M_PI * 2.0);
        rotate.duration = 1;
        rotate.repeatCount = HUGE_VALF;
        [self.loadingView.layer addAnimation:rotate forKey:@"rotationAnimation"];
    });
}

- (void)stopLoading {
    if (self.loadingView.hidden) {
        return;
    }
    self.loadingView.hidden = YES;
    [self.loadingView.layer removeAllAnimations];
}

#pragma mark - Event response
- (void)onLongPressed:(UILongPressGestureRecognizer *)recognizer {
    if (![recognizer isKindOfClass:[UILongPressGestureRecognizer class]] || recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }

    TUIChatPopMenu *popMenu = [[TUIChatPopMenu alloc] init];

    @weakify(self);
    TUIChatPopMenuAction *copy = [[TUIChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(Copy)
                                                                       image:TUIVoiceToTextBundleThemeImage(@"convert_voice_text_view_pop_menu_copy_img", @"icon_copy")
                                                                      weight:1
                                                                    callback:^{
                                                                      @strongify(self);
                                                                      [self onCopy:self.text];
                                                                    }];
    [popMenu addAction:copy];

    TUIChatPopMenuAction *forward =
        [[TUIChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(Forward)
                                              image:TUIVoiceToTextBundleThemeImage(@"convert_voice_text_view_pop_menu_forward_img", @"icon_forward")
                                             weight:2
                                           callback:^{
                                             @strongify(self);
                                             [self onForward:self.text];
                                           }];
    [popMenu addAction:forward];

    TUIChatPopMenuAction *hide = [[TUIChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(Hide)
                                                                       image:TUIVoiceToTextBundleThemeImage(@"convert_voice_text_view_pop_menu_hide_img", @"icon_hide")
                                                                      weight:3
                                                                    callback:^{
                                                                      @strongify(self);
                                                                      [self onHide:self];
                                                                    }];
    [popMenu addAction:hide];

    CGRect frame = [UIApplication.sharedApplication.keyWindow convertRect:self.frame fromView:self.superview];
    [popMenu setArrawPosition:CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y + 66) adjustHeight:0];
    [popMenu showInView:UIApplication.sharedApplication.keyWindow];
}

- (void)onCopy:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = text;
    [TUITool makeToast:TIMCommonLocalizableString(Copied)];
}

- (void)onForward:(NSString *)text {
    [self notifyConversionForward:text];
}

- (void)onHide:(id)sender {
    self.cellData.bottomContainerSize = CGSizeZero;
    [TUIVoiceToTextDataProvider saveConvertedResult:self.cellData.innerMessage text:@"" status:TUIVoiceToTextViewStatusHidden];
    [self removeFromSuperview];
    [self notifyConversionViewHidden];
}

#pragma mark-- Notify
- (void)notifyConversionViewShown {
    [self notifyConversionChanged];
}

- (void)notifyConversionViewHidden {
    [self notifyConversionChanged];
}

- (void)notifyConversionForward:(NSString *)text {
    NSDictionary *param = @{TUICore_TUIPluginNotify_WillForwardTextSubKey_Text : text};
    [TUICore notifyEvent:TUICore_TUIPluginNotify
                  subKey:TUICore_TUIPluginNotify_WillForwardTextSubKey
                  object:nil
                   param:param];
}

- (void)notifyConversionChanged {
    NSDictionary *param =  @{TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data : self.cellData,
                             TUICore_TUIPluginNotify_DidChangePluginViewSubKey_VC : self};
    [TUICore notifyEvent:TUICore_TUIPluginNotify
                  subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey
                  object:nil
                   param:param];
}

@end
