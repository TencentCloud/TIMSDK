//
//  TUITranslationView.m
//  TUIChat
//

#import "TUITranslationView.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"
#import "TUIChatPopMenu.h"
#import "NSString+TUIEmoji.h"

@interface TUITranslationView()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *tips;

@property (nonatomic, strong) UIImageView *tipsIcon;
@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) UIColor *bgColor;

@end

@implementation TUITranslationView

- (instancetype)initWithBackgroundColor:(UIColor *)color {
    self.bgColor = color;
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self setupGesture];
    }
    return self;
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = self.bgColor ? : TUIChatDynamicColor(@"chat_message_translation_bg_color", @"#F2F7FF");
    self.layer.cornerRadius = 10.0;
    
    self.loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [self.loadingView setImage:TUIChatBundleThemeImage(@"chat_message_translation_loading_img", @"message_translation_loading")];
    self.loadingView.hidden = YES;
    [self addSubview:self.loadingView];

    self.textView = [[TUITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.scrollEnabled = NO;
    self.textView.editable = NO;
    [self addSubview:self.textView];
    self.textView.hidden = YES;
    self.textView.userInteractionEnabled = NO;
    
    self.tipsIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 13)];
    [self.tipsIcon setImage:TUIChatBundleThemeImage(@"chat_message_translation_tips_img", @"message_translation_tips")];
    self.tipsIcon.alpha = 0.4;
    [self addSubview:self.tipsIcon];
    self.tipsIcon.hidden = YES;
    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.font = [UIFont systemFontOfSize:12];
    self.tipsLabel.text = TUIKitLocalizableString(TUIKitTranslateDefaultTips);
    self.tipsLabel.textColor = TUICoreDynamicColor(@"form_value_text_color", @"#000000");
    self.tipsLabel.alpha = 0.4;
    [self addSubview:self.tipsLabel];
    self.tipsLabel.hidden = YES;
}

- (void)setupGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress addTarget:self action:@selector(onLongPressed:)];
    [self addGestureRecognizer:longPress];
}

- (void)layoutSubviews {
    if (self.text.length == 0) {
        self.loadingView
             .mm_height(15)
             .mm_width(15)
             .mm_left(10)
             .mm__centerY(self.mm_h / 2.0);
    } else {
        self.textView
            .mm_top(10)
            .mm_left(10)
            .mm_height(self.mm_h - 10 - 40 + 2)
            .mm_width(self.mm_w - 2 * 10);
        self.tipsIcon
            .mm_top(self.textView.mm_maxY + 14)
            .mm_left(10)
            .mm_height(13)
            .mm_width(13);
        self.tipsLabel
            .mm_height(20)
            .mm_sizeToFit()
            .mm__centerY(self.tipsIcon.mm_centerY)
            .mm_left(self.tipsIcon.mm_maxX + 4);
    }
}

- (void)updateTransaltion:(NSString *)text {
    BOOL isTranslated = text.length > 0;
    if (isTranslated) {
        self.textView.attributedText = [text getAdvancedFormatEmojiStringWithFont:[UIFont systemFontOfSize:16]
                                                                        textColor:TUIChatDynamicColor(@"chat_message_translation_text_color", @"#000000") emojiLocations:nil];
    }
  
    self.textView.hidden = !isTranslated;
    self.tipsIcon.hidden = !isTranslated;
    self.tipsLabel.hidden = !isTranslated;
    
    self.text = text;
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
    if (![recognizer isKindOfClass:[UILongPressGestureRecognizer class]] ||
       recognizer.state != UIGestureRecognizerStateBegan){
        return;
    }
    
    TUIChatPopMenu *popMenu = [[TUIChatPopMenu alloc] init];
    
    @weakify(self);
    TUIChatPopMenuAction *copy = [[TUIChatPopMenuAction alloc] initWithTitle:TUIKitLocalizableString(Copy)
                                                                       image:TUIChatBundleThemeImage(@"chat_icon_copy_img", @"icon_copy")
                                                                        rank:1
                                                                    callback:^{
        @strongify(self);
        [self onCopy:self.text];
    }];
    [popMenu addAction:copy];
    
    TUIChatPopMenuAction *forward = [[TUIChatPopMenuAction alloc] initWithTitle:TUIKitLocalizableString(Forward)
                                                                          image:TUIChatBundleThemeImage(@"chat_icon_forward_img", @"icon_forward")
                                                                           rank:2
                                                                       callback:^{
        @strongify(self);
        [self onForward:self.text];
    }];
    [popMenu addAction:forward];
    
    TUIChatPopMenuAction *hide = [[TUIChatPopMenuAction alloc] initWithTitle:TUIKitLocalizableString(Hide)
                                                                       image:TUIChatBundleThemeImage(@"chat_icon_hide_img", @"icon_hide")
                                                                        rank:3
                                                                    callback:^{
        @strongify(self);
        [self onHide:self];
    }];
    [popMenu addAction:hide];
    
    CGRect frame = [UIApplication.sharedApplication.keyWindow convertRect:self.frame fromView:self.superview];
    [popMenu setArrawPosition:CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y + 66)
                 adjustHeight:0];
    [popMenu showInView:UIApplication.sharedApplication.keyWindow];
}

- (void)onCopy:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = text;
    [TUITool makeToast:TUIKitLocalizableString(Copied)];
}

- (void)onForward:(NSString *)text {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(translationViewWillForward:)]) {
        [self.delegate translationViewWillForward:text];
    }
}

- (void)onHide:(id)sender {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(translationViewWillHide:)]) {
        [self.delegate translationViewWillHide:self];
    }
}

@end
