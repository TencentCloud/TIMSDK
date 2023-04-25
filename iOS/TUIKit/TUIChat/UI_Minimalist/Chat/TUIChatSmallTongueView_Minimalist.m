//
//  TUIChatSmallTongue.m
//  TUIChat
//
//  Created by xiangzhang on 2022/1/6.
//

#import "TUIChatSmallTongueView_Minimalist.h"
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUIDarkModel.h>
#import <TIMCommon/TIMDefine.h>

#define TongueMiddleSpace 5.f
#define TongueRightSpace 10.f
#define TongueFontSize 14

@interface TUIChatSmallTongueView_Minimalist()

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UILabel *label;

@end

@implementation TUIChatSmallTongueView_Minimalist
{
    TUIChatSmallTongue_Minimalist *_tongue;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 阴影
        self.layer.shadowColor = RGBA(0, 0, 0, 0.15).CGColor;
        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 2;
        self.clipsToBounds = NO;
        
        // 背景图
        UIImageView *backgroudView = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:backgroudView];
        backgroudView.mm_fill();
        backgroudView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UIImage *bkImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"small_tongue_bk")];
        backgroudView.image = [bkImage resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{5,12,5,5}") resizingMode:UIImageResizingModeStretch];
        
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

- (void)setTongue:(TUIChatSmallTongue_Minimalist *)tongue {
    _tongue = tongue;
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
    }
    self.imageView.image = [TUIChatSmallTongueView_Minimalist getTongueImage:tongue];
    self.imageView.mm_width(kScale390(18)).mm_height(kScale390(18)).mm_left(kScale390(18)).mm_top(kScale390(5));

    if (!self.label) {
        self.label = [[UILabel alloc] init];
        self.label.font = [UIFont systemFontOfSize:TongueFontSize];
        [self addSubview:self.label];
    }
    NSString *text = [TUIChatSmallTongueView_Minimalist getTongueText:tongue];;
    if(text) {
        self.label.hidden = NO;
        self.label.text = text;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = TUIChatDynamicColor(@"chat_drop_down_color", @"#147AFF");
        self.label.mm_width(kScale390(16)).mm_height(kScale390(20)).mm_top(self.imageView.mm_b + kScale390(2)).mm__centerX(self.imageView.mm_centerX);
    } else {
        self.label.hidden = YES;
    }
}

+ (CGFloat)getTongueWidth:(TUIChatSmallTongue_Minimalist *)tongue {
    return kScale390(54);
}

+ (CGFloat)getTongueHeight:(TUIChatSmallTongue_Minimalist *)tongue {
    CGFloat tongueHeight = 0;
    switch (tongue.type) {
        case TUIChatSmallTongueType_ScrollToBoom:
        {
            tongueHeight = kScale390(29);
        }
            break;
        case TUIChatSmallTongueType_ReceiveNewMsg:
        {
            tongueHeight = kScale390(47);
        }
            break;
        case TUIChatSmallTongueType_SomeoneAtMe:
        {
            tongueHeight = kScale390(47);
        }
            break;
        default:
            break;
    }
    return tongueHeight;
}

+ (NSString *)getTongueText:(TUIChatSmallTongue_Minimalist *)tongue {
    NSString *tongueText = nil;
    switch (tongue.type) {
        case TUIChatSmallTongueType_ScrollToBoom:
        {
            tongueText = nil;
        }
            break;
        case TUIChatSmallTongueType_ReceiveNewMsg:
        {
            tongueText = [NSString stringWithFormat:@"%@",tongue.unreadMsgCount > 99 ? @"99+" : @(tongue.unreadMsgCount)];
        }
            break;
        case TUIChatSmallTongueType_SomeoneAtMe:
        {
            tongueText = [NSString stringWithFormat:@"%@",tongue.atMsgSeqs.count > 99 ? @"99+" : @(tongue.atMsgSeqs.count)];
        }
            break;
        default:
            break;
    }
    return tongueText;
}

+ (UIImage *)getTongueImage:(TUIChatSmallTongue_Minimalist *)tongue {
    UIImage *tongueImage = nil;
    switch (tongue.type) {
        case TUIChatSmallTongueType_ScrollToBoom:
        {
            tongueImage =  [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"small_tongue_scroll_to_boom")];
        }
            break;
        case TUIChatSmallTongueType_ReceiveNewMsg:
        {
            tongueImage =  [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"small_tongue_scroll_to_boom")];
            break;
        }
        case TUIChatSmallTongueType_SomeoneAtMe:
        {
            tongueImage =  [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"small_tongue_someone_at_me")];
        }
            break;
        default:
            break;
    }
    return tongueImage;
}

@end


@implementation TUIChatSmallTongue_Minimalist

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = TUIChatSmallTongueType_None;
    }
    return self;
}

@end

static TUIChatSmallTongueView_Minimalist *g_tongueView = nil;
static TUIChatSmallTongue_Minimalist *g_tongue = nil;
static UIWindow *g_window = nil;

@implementation TUIChatSmallTongueManager_Minimalist

+ (void)showTongue:(TUIChatSmallTongue_Minimalist *)tongue delegate:(id<TUIChatSmallTongueViewDelegate_Minimalist>) delegate {
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
    
    CGFloat tongueWidth = [TUIChatSmallTongueView_Minimalist getTongueWidth:g_tongue];
    CGFloat tongueHeight = [TUIChatSmallTongueView_Minimalist getTongueHeight:g_tongue];
    g_window.frame = CGRectMake(Screen_Width -  kScale390(54), Screen_Height - Bottom_SafeHeight - TTextView_Height - 20 - tongueHeight, tongueWidth, tongueHeight);

    if (!g_tongueView) {
        g_tongueView = [[TUIChatSmallTongueView_Minimalist alloc] initWithFrame:CGRectZero];
        [g_window addSubview:g_tongueView];
        g_window.hidden = NO;
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
}

+ (void)hideTongue:(BOOL)isHidden {
    if (g_tongueView) {
        g_tongueView.hidden = isHidden;
    }
}

@end
