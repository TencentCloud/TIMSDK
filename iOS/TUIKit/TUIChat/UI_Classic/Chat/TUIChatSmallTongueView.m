//
//  TUIChatSmallTongue.m
//  TUIChat
//
//  Created by xiangzhang on 2022/1/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatSmallTongueView.h"
#import <TUICore/NSString+TUIUtil.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIChatConfig.h"
#import <TIMCommon/TIMDefine.h>
#define TongueHeight 35.f
#define TongueImageWidth 12.f
#define TongueImageHeight 12.f
#define TongueLeftSpace 10.f
#define TongueMiddleSpace 5.f
#define TongueRightSpace 10.f
#define TongueFontSize 13

@interface TUIChatSmallTongueView ()

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UILabel *label;

@end

@implementation TUIChatSmallTongueView {
    TUIChatSmallTongue *_tongue;
}

+ (void)load {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onThemeChanged:) name:TUIDidApplyingThemeChangedNotfication object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = TUIChatDynamicColor(@"chat_small_tongue_bg_color", @"#FFFFFF");
        // border
        self.layer.borderWidth = 0.2;
        self.layer.borderColor = TUIChatDynamicColor(@"chat_small_tongue_line_color", @"#E5E5E5").CGColor;
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
        // shadow
        self.layer.shadowColor = RGBA(0, 0, 0, 0.15).CGColor;
        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 2;
        self.clipsToBounds = NO;
        //  tap
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

    if (!self.label) {
        self.label = [[UILabel alloc] init];
        self.label.font = [UIFont systemFontOfSize:TongueFontSize];
        [self addSubview:self.label];
    }
    self.label.text = [TUIChatSmallTongueView getTongueText:tongue];
    self.label.rtlAlignment = TUITextRTLAlignmentLeading;
    self.label.textColor = TUIChatDynamicColor(@"chat_drop_down_color", @"#147AFF");
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(TongueImageWidth);
        make.leading.mas_equalTo(TongueLeftSpace);
        make.top.mas_equalTo(10);
    }];
    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_lessThanOrEqualTo(self.mas_trailing).mas_offset(-TongueRightSpace);
        make.height.mas_equalTo(TongueImageHeight);
        make.leading.mas_equalTo(self.imageView.mas_trailing).mas_offset(TongueMiddleSpace);
        make.top.mas_equalTo(10);
    }];
}

+ (CGFloat)getTongueWidth:(TUIChatSmallTongue *)tongue {
    NSString *tongueText = [self getTongueText:tongue];
    CGSize titleSize = [tongueText boundingRectWithSize:CGSizeMake(MAXFLOAT, TongueHeight)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:TongueFontSize]}
                                                context:nil]
                           .size;
    CGFloat tongueWidth = TongueLeftSpace + TongueImageWidth + TongueMiddleSpace + ceil(titleSize.width) + TongueRightSpace;
    return tongueWidth;
}

+ (NSString *)getTongueText:(TUIChatSmallTongue *)tongue {
    static NSMutableDictionary *titleCacheFormat;
    if (titleCacheFormat == nil) {
        titleCacheFormat = [NSMutableDictionary dictionary];
        [titleCacheFormat setObject:TIMCommonLocalizableString(TUIKitChatBackToLatestLocation) forKey:@(TUIChatSmallTongueType_ScrollToBoom)];
        [titleCacheFormat setObject:TIMCommonLocalizableString(TUIKitChatNewMessages) forKey:@(TUIChatSmallTongueType_ReceiveNewMsg)];
    }
    
    if (tongue.type == TUIChatSmallTongueType_SomeoneAt) {
        NSString *atMeStr = TIMCommonLocalizableString(TUIKitConversationTipsAtMe);
        NSString *atAllStr = TIMCommonLocalizableString(TUIKitConversationTipsAtAll);
        if ([tongue.atTipsStr tui_containsString:atMeStr]) {
            atMeStr = [atMeStr stringByReplacingOccurrencesOfString:@"[" withString:@""];
            atMeStr = [atMeStr stringByReplacingOccurrencesOfString:@"]" withString:@""];
            [titleCacheFormat setObject:atMeStr forKey:@(TUIChatSmallTongueType_SomeoneAt)];
        } else if ([tongue.atTipsStr tui_containsString:atAllStr]) {
            atAllStr = [atAllStr stringByReplacingOccurrencesOfString:@"[" withString:@""];
            atAllStr = [atAllStr stringByReplacingOccurrencesOfString:@"]" withString:@""];
            [titleCacheFormat setObject:atAllStr forKey:@(TUIChatSmallTongueType_SomeoneAt)];
        }
    }

    if (tongue.type == TUIChatSmallTongueType_ReceiveNewMsg) {
        return [NSString stringWithFormat:[titleCacheFormat objectForKey:@(TUIChatSmallTongueType_ReceiveNewMsg)],
                                          tongue.unreadMsgCount > 99 ? @"99+" : @(tongue.unreadMsgCount)];
    } else {
        return [titleCacheFormat objectForKey:@(tongue.type)];
    }
}

static NSMutableDictionary *gImageCache;
+ (UIImage *)getTongueImage:(TUIChatSmallTongue *)tongue {
    if (gImageCache == nil) {
        gImageCache = [NSMutableDictionary dictionary];
        [gImageCache setObject:TUIChatBundleThemeImage(@"chat_drop_down_img", @"drop_down") ?: UIImage.new forKey:@(TUIChatSmallTongueType_ScrollToBoom)];
        [gImageCache setObject:TUIChatBundleThemeImage(@"chat_drop_down_img", @"drop_down") ?: UIImage.new forKey:@(TUIChatSmallTongueType_ReceiveNewMsg)];
        [gImageCache setObject:TUIChatBundleThemeImage(@"chat_pull_up_img", @"pull_up") ?: UIImage.new forKey:@(TUIChatSmallTongueType_SomeoneAt)];
    }
    return [gImageCache objectForKey:@(tongue.type)];
}

+ (void)onThemeChanged:(NSNotification *)notice {
    gImageCache = nil;
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

static TUIChatSmallTongueView *gTongueView = nil;
static TUIChatSmallTongue *gTongue = nil;
static CGFloat gBottomMargin = 0;

@implementation TUIChatSmallTongueManager

+ (void)showTongue:(TUIChatSmallTongue *)tongue delegate:(id<TUIChatSmallTongueViewDelegate>)delegate {
    if (tongue.type == gTongue.type 
        && tongue.parentView == gTongue.parentView
        && tongue.unreadMsgCount == gTongue.unreadMsgCount
        && tongue.atMsgSeqs == gTongue.atMsgSeqs
        && !gTongueView.hidden) {
        return;
    }
    gTongue = tongue;

    if (!gTongueView) {
        gTongueView = [[TUIChatSmallTongueView alloc] init];
    } else {
        [gTongueView removeFromSuperview];
    }
    CGFloat tongueWidth = [TUIChatSmallTongueView getTongueWidth:gTongue];
    if(isRTL()) {
        gTongueView.frame =
            CGRectMake(16,
                       tongue.parentView.mm_h - Bottom_SafeHeight - TTextView_Height - 20 - TongueHeight - gBottomMargin,
                       tongueWidth, TongueHeight);
    }
    else {
        gTongueView.frame =
            CGRectMake(tongue.parentView.mm_w - tongueWidth - 16,
                       tongue.parentView.mm_h - Bottom_SafeHeight - TTextView_Height - 20 - TongueHeight - gBottomMargin,
                       tongueWidth, TongueHeight);
    }
    
    gTongueView.delegate = delegate;
    [gTongueView setTongue:gTongue];
    [tongue.parentView addSubview:gTongueView];
}

+ (void)removeTongue:(TUIChatSmallTongueType)type {
    if (type != gTongue.type) {
        return;
    }
    [self removeTongue];
}

+ (void)removeTongue {
    gTongue = nil;
    if (gTongueView) {
        [gTongueView removeFromSuperview];
        gTongueView = nil;
    }
}

+ (void)hideTongue:(BOOL)isHidden {
    if (gTongueView) {
        gTongueView.hidden = isHidden;
    }
}

+ (void)adaptTongueBottomMargin:(CGFloat)margin {
    gBottomMargin = margin;
}

@end
