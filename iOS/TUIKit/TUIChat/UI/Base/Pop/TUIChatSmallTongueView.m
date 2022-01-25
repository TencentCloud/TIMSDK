//
//  TUIChatSmallTongue.m
//  TUIChat
//
//  Created by xiangzhang on 2022/1/6.
//

#import "TUIChatSmallTongueView.h"
#import "TUIThemeManager.h"
#import "TUIDarkModel.h"

#define TongueHeight 35.f
#define TongueImageWidth 12.f
#define TongueImageHeight 12.f
#define TongueLeftSpace 10.f
#define TongueMiddleSpace 5.f
#define TongueRightSpace 10.f
#define TongueFontSize 13

@interface TUIChatSmallTongueView()
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UILabel *label;
@end

@implementation TUIChatSmallTongueView
{
    TUIChatSmallTongue *_tongue;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGB(255, 255, 255);
        // 边框
        self.layer.borderWidth = 1;
        self.layer.borderColor = RGB(229, 229, 229).CGColor;
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
        // 阴影
        self.layer.shadowColor = RGBA(0, 0, 0, 0.15).CGColor;
        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 2;
        self.clipsToBounds = NO;
        // 点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)onTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onChatSmallTongueClick:)]) {
        [self.delegate onChatSmallTongueClick:_tongue];
    }
}

- (void)setTongue:(TUIChatSmallTongue *)tongue {
    _tongue = tongue;
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
    }
    self.imageView.image = [TUIChatSmallTongueView getTongueImage:tongue];
    self.imageView.mm_width(TongueImageWidth).mm_height(TongueImageHeight).mm_left(TongueLeftSpace).mm_top(10);

    if (!self.label) {
        self.label = [[UILabel alloc] init];
        self.label.font = [UIFont systemFontOfSize:TongueFontSize];
        [self addSubview:self.label];
    }
    self.label.text = [TUIChatSmallTongueView getTongueText:tongue];
    self.label.textColor = TUIChatDynamicColor(@"chat_drop_down_color", @"#147AFF");
    self.label.mm_flexToRight(TongueRightSpace).mm_height(TongueImageHeight).mm_left(self.imageView.mm_maxX + TongueMiddleSpace).mm_top(10);
}

+ (CGFloat)getTongueWidth:(TUIChatSmallTongue *)tongue {
    NSString *tongueText = [self getTongueText:tongue];
    CGSize titleSize = [tongueText boundingRectWithSize:CGSizeMake(MAXFLOAT,TongueHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:TongueFontSize]} context:nil].size;
    CGFloat tongueWidth = TongueLeftSpace + TongueImageWidth + TongueMiddleSpace + titleSize.width + TongueRightSpace;
    return tongueWidth;
}

+ (NSString *)getTongueText:(TUIChatSmallTongue *)tongue {
    NSString *tongueText = nil;
    switch (tongue.type) {
        case TUIChatSmallTongueType_ScrollToBoom:
        {
            tongueText = TUIKitLocalizableString(TUIKitChatBackToLatestLocation);
        }
            break;
        case TUIChatSmallTongueType_ReceiveNewMsg:
        {
            tongueText = [NSString stringWithFormat:TUIKitLocalizableString(TUIKitChatNewMessages),tongue.unreadMsgCount > 99 ? @"99+" : @(tongue.unreadMsgCount)];
            break;
        }
        case TUIChatSmallTongueType_SomeoneAtMe:
        {
            tongueText = TUIKitLocalizableString(TUIKitChatTipsAtMe);
        }
            break;
        default:
            break;
    }
    return tongueText;
}

+ (UIImage *)getTongueImage:(TUIChatSmallTongue *)tongue {
    UIImage *tongueImage = nil;
    switch (tongue.type) {
        case TUIChatSmallTongueType_ScrollToBoom:
        {
            tongueImage = TUIChatDynamicImage(@"chat_drop_down_img", [UIImage d_imageNamed:@"drop_down" bundle:TUIChatBundle]);
        }
            break;
        case TUIChatSmallTongueType_ReceiveNewMsg:
        {
            tongueImage = TUIChatDynamicImage(@"chat_drop_down_img", [UIImage d_imageNamed:@"drop_down" bundle:TUIChatBundle]);
            break;
        }
        case TUIChatSmallTongueType_SomeoneAtMe:
        {
            tongueImage = TUIChatDynamicImage(@"chat_pull_up_img", [UIImage d_imageNamed:@"pull_up" bundle:TUIChatBundle]);
        }
            break;
        default:
            break;
    }
    return tongueImage;
}

@end


@implementation TUIChatSmallTongue
- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = TUIChatSmallTongueType_None;
    }
    return self;
}
@end

static TUIChatSmallTongueView *g_tongueView = nil;
static TUIChatSmallTongue *g_tongue = nil;
static UIWindow *g_window = nil;
static UIWindow *keyWindow = nil;   // 保存真正的 keyWindow

@implementation TUIChatSmallTongueManager
+ (void)showTongue:(TUIChatSmallTongue *)tongue delegate:(id<TUIChatSmallTongueViewDelegate>) delegate {
    if (tongue.type == g_tongue.type
        && tongue.unreadMsgCount == g_tongue.unreadMsgCount
        && tongue.atMsgSeqs == g_tongue.atMsgSeqs) {
        return;
    }
    g_tongue = tongue;
    
    if (!g_window) {
        g_window = [[UIWindow alloc] initWithFrame:CGRectZero];
        g_window.windowLevel = UIWindowLevelAlert;
        g_window.backgroundColor = [UIColor clearColor];
        
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    g_window.windowScene = windowScene;
                    break;
                }
            }
        }
    }
    CGFloat tongueWidth = [TUIChatSmallTongueView getTongueWidth:g_tongue];
    g_window.frame = CGRectMake(Screen_Width -  tongueWidth - 16, Screen_Height - Bottom_SafeHeight - TTextView_Height - 20 - TongueHeight, tongueWidth, TongueHeight);

    if (!g_tongueView) {
        g_tongueView = [[TUIChatSmallTongueView alloc] initWithFrame:CGRectZero];
        [g_window addSubview:g_tongueView];
        keyWindow = UIApplication.sharedApplication.keyWindow;
        [g_window makeKeyAndVisible];
        [keyWindow makeKeyWindow];
    }
    g_tongueView.frame = g_window.bounds;
    g_tongueView.delegate = delegate;
    [g_tongueView setTongue:g_tongue];
}

+ (void)removeTongue:(TUIChatSmallTongueType)type {
    if (type != g_tongue.type) {
        return;
    }
    [self removeTongue];
}

+ (void)removeTongue {
    g_tongue = nil;
    g_tongueView =  nil;
    g_window = nil;
    [keyWindow makeKeyWindow];
    keyWindow = nil;
}

+ (void)hideTongue:(BOOL)isHidden {
    if (g_tongueView) {
        g_tongueView.hidden = isHidden;
        if (isHidden) {
            [keyWindow makeKeyWindow];
        } else {
            [g_window makeKeyWindow];
        }
    }
}

@end
