//
//  TUITranslationView.m
//  TUITranslation
//

#import "TUITranslationView.h"
#import <TUICore/TUIDefine.h>
#import <TUICore/TUIThemeManager.h>
#import <TUIChat/TUIChatPopMenu.h>
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TUIMessageCellData.h>
#import <TUICore/TUICore.h>
#import <TIMCommon/TUITextView.h>
#import "TUITranslationDataProvider.h"

@interface TUITranslationView()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *tips;
@property (nonatomic, strong) UIColor *bgColor;

@property (nonatomic, strong) UIImageView *tipsIcon;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIImageView *loadingView;
@property (nonatomic, strong) TUITextView *textView;

@property (nonatomic, strong) TUIMessageCellData *cellData;

@end

@implementation TUITranslationView

- (instancetype)initWithBackgroundColor:(UIColor *)color {
    self.bgColor = color;
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithData:(TUIMessageCellData *)data {
    self = [super init];
    if (self) {
        self.cellData = data;
        
        BOOL shouldShow = [TUITranslationDataProvider shouldShowTranslation:data.innerMessage];
        if (shouldShow) {
            [self setupViews];
            [self setupGesture];
            [self refreshWithData:data];
        } else {
            if (!CGSizeEqualToSize(self.cellData.bottomContainerSize, CGSizeZero)) {
                [self notifyTranslationChanged];
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
    self.text = [TUITranslationDataProvider getTranslationText:cellData.innerMessage];
    TUITranslationViewStatus status = [TUITranslationDataProvider getTranslationStatus:cellData.innerMessage];
    
    CGSize size = [self calcSizeOfStatus:status];
    if (!CGSizeEqualToSize(self.cellData.bottomContainerSize, size)) {
        [self notifyTranslationChanged];
    }
    self.cellData.bottomContainerSize = size;
    self.mm_top(0).mm_left(0).mm_width(size.width).mm_height(size.height);
    if (status == TUITranslationViewStatusLoading) {
        [self startLoading];
    } else if (status == TUITranslationViewStatusShown) {
        [self stopLoading];
        [self updateTransaltionViewByText:self.text];
    }
}

- (CGSize)calcSizeOfStatus:(TUITranslationViewStatus)status {
    CGFloat minTextWidth = 164;
    CGFloat maxTextWidth = Screen_Width * 0.68;
    CGFloat actualTextWidth = 80 - 20; // 80 is the fixed container width.
    CGFloat tipsHeight = 20;
    CGFloat tipsBottomMargin = 10;
    CGFloat oneLineTextHeight = 22;
    CGFloat commonMargins = 10 * 2;
    
    // Translation is processing, return the size of an empty cell including loading animation.
    if (status == TUITranslationViewStatusLoading) {
        return CGSizeMake(80, oneLineTextHeight + commonMargins);
    }
    
    NSAttributedString *attrStr = [self.text getAdvancedFormatEmojiStringWithFont:[UIFont systemFontOfSize:16]
                                                                        textColor:[UIColor grayColor]
                                                                   emojiLocations:nil];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    
    // Translation is finished.
    // Calc the size according to the actual text width.
    CGRect textRect = [attrStr boundingRectWithSize:CGSizeMake(actualTextWidth, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            context:nil];
    if (textRect.size.height < 30) {
        // Result is only one line text.
        return CGSizeMake(MAX(textRect.size.width, minTextWidth) + commonMargins,
                               MAX(textRect.size.height, oneLineTextHeight) + commonMargins + tipsHeight + tipsBottomMargin);
    }
    
    // Result is more than one line, so recalc size using maxTextWidth.
    textRect = [attrStr boundingRectWithSize:CGSizeMake(maxTextWidth, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     context:nil];
    return CGSizeMake(MAX(textRect.size.width, minTextWidth) + commonMargins,
                           MAX(textRect.size.height, oneLineTextHeight) + commonMargins + tipsHeight + tipsBottomMargin);
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = self.bgColor ? : TUITranslationDynamicColor(@"translation_view_bg_color", @"#F2F7FF");
    self.layer.cornerRadius = 10.0;
    
    self.loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [self.loadingView setImage:TUITranslationBundleThemeImage(@"translation_view_icon_loading_img", @"translation_loading")];
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
    [self.tipsIcon setImage:TUITranslationBundleThemeImage(@"translation_view_icon_tips_img", @"translation_tips")];
    self.tipsIcon.alpha = 0.4;
    [self addSubview:self.tipsIcon];
    self.tipsIcon.hidden = YES;
    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.font = [UIFont systemFontOfSize:12];
    self.tipsLabel.text = TIMCommonLocalizableString(TUIKitTranslateDefaultTips);
    self.tipsLabel.textColor = TUITranslationDynamicColor(@"translation_view_tips_color", @"#000000");
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

- (void)updateTransaltionViewByText:(NSString *)text {
    BOOL isTranslated = text.length > 0;
    if (isTranslated) {
        self.textView.attributedText = [text getAdvancedFormatEmojiStringWithFont:[UIFont systemFontOfSize:16]
                                                                        textColor:TUITranslationDynamicColor(@"translation_view_text_color", @"#000000") emojiLocations:nil];
    }
    self.textView.hidden = !isTranslated;
    self.tipsIcon.hidden = !isTranslated;
    self.tipsLabel.hidden = !isTranslated;
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
    TUIChatPopMenuAction *copy = [[TUIChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(Copy)
                                                                       image:TUITranslationBundleThemeImage(@"translation_view_pop_menu_copy_img", @"icon_copy")
                                                                        weight:1
                                                                    callback:^{
        @strongify(self);
        [self onCopy:self.text];
    }];
    [popMenu addAction:copy];
    
    TUIChatPopMenuAction *forward = [[TUIChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(Forward)
                                                                          image:TUITranslationBundleThemeImage(@"translation_view_pop_menu_forward_img", @"icon_forward")
                                                                         weight:2
                                                                       callback:^{
        @strongify(self);
        [self onForward:self.text];
    }];
    [popMenu addAction:forward];

    TUIChatPopMenuAction *hide = [[TUIChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(Hide)
                                                                       image:TUITranslationBundleThemeImage(@"translation_view_pop_menu_hide_img", @"icon_hide")
                                                                      weight:3
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
    [TUITool makeToast:TIMCommonLocalizableString(Copied)];
}

- (void)onForward:(NSString *)text {
    [self notifyTranslationForward:text];
}

- (void)onHide:(id)sender {
    self.cellData.bottomContainerSize = CGSizeZero;
    [TUITranslationDataProvider saveTranslationResult:self.cellData.innerMessage text:@"" status:TUITranslationViewStatusHidden];
    [self removeFromSuperview];
    [self notifyTranslationViewHidden];
}

#pragma mark -- Notify
- (void)notifyTranslationViewShown {
    [self notifyTranslationChanged];
}

- (void)notifyTranslationViewHidden {
    [self notifyTranslationChanged];
}

- (void)notifyTranslationForward:(NSString *)text {
    NSDictionary *param = @{TUICore_TUITranslationNotify_WillForwardTranslationSubKey_Text:text};
    [TUICore notifyEvent:TUICore_TUITranslationNotify
                  subKey:TUICore_TUITranslationNotify_WillForwardTranslationSubKey
                  object:nil
                   param:param];
}

- (void)notifyTranslationChanged {
    NSDictionary *param = @{TUICore_TUITranslationNotify_DidChangeTranslationSubKey_Data: self.cellData,
                            TUICore_TUITranslationNotify_DidChangeTranslationSubKey_VC: self
    };
    [TUICore notifyEvent:TUICore_TUITranslationNotify
                  subKey:TUICore_TUITranslationNotify_DidChangeTranslationSubKey
                  object:nil
                   param:param];
}

@end
