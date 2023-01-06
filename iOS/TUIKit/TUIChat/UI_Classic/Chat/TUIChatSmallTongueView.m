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

+ (void)load {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onThemeChanged:) name:TUIDidApplyingThemeChangedNotfication object:nil];
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = TUIChatDynamicColor(@"chat_small_tongue_bg_color", @"#FFFFFF");
        // 边框
        self.layer.borderWidth = 0.2;
        self.layer.borderColor = TUIChatDynamicColor(@"chat_small_tongue_line_color", @"#E5E5E5").CGColor;
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
    static NSMutableDictionary *titleCacheFormat;
    if (titleCacheFormat == nil) {
        titleCacheFormat = [NSMutableDictionary dictionary];
        [titleCacheFormat setObject:TUIKitLocalizableString(TUIKitChatBackToLatestLocation) forKey:@(TUIChatSmallTongueType_ScrollToBoom)];
        [titleCacheFormat setObject:TUIKitLocalizableString(TUIKitChatNewMessages) forKey:@(TUIChatSmallTongueType_ReceiveNewMsg)];
        [titleCacheFormat setObject:TUIKitLocalizableString(TUIKitChatTipsAtMe) forKey:@(TUIChatSmallTongueType_SomeoneAtMe)];
    }
    
    if (tongue.type == TUIChatSmallTongueType_ReceiveNewMsg) {
        return [NSString stringWithFormat:[titleCacheFormat objectForKey:@(TUIChatSmallTongueType_ReceiveNewMsg)], tongue.unreadMsgCount > 99 ? @"99+" : @(tongue.unreadMsgCount)];
    } else {
        return [titleCacheFormat objectForKey:@(tongue.type)];
    }
}

static NSMutableDictionary *imageCache;
+ (UIImage *)getTongueImage:(TUIChatSmallTongue *)tongue {
    if (imageCache == nil) {
        imageCache = [NSMutableDictionary dictionary];
        [imageCache setObject:TUIChatBundleThemeImage(@"chat_drop_down_img", @"drop_down")?:UIImage.new forKey:@(TUIChatSmallTongueType_ScrollToBoom)];
        [imageCache setObject:TUIChatBundleThemeImage(@"chat_drop_down_img", @"drop_down")?:UIImage.new forKey:@(TUIChatSmallTongueType_ReceiveNewMsg)];
        [imageCache setObject:TUIChatBundleThemeImage(@"chat_pull_up_img", @"pull_up")?:UIImage.new forKey:@(TUIChatSmallTongueType_SomeoneAtMe)];
    }
    return [imageCache objectForKey:@(tongue.type)];
}

+ (void)onThemeChanged:(NSNotification *)notice {
    imageCache = nil;
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
