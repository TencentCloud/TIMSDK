//
//  TUILiveLottieAnimator.m
//  Pods
//
//  Created by harvy on 2020/9/17.
//

#import "Lottie.h"
#import "Masonry.h"

#import "TUILiveGiftAnimator.h"
#import "TUILiveGiftAnimationManager.h"
#import "TUILiveBulletGiftView.h"

#define kMaxBulletGift 3
#define kScale UIScreen.mainScreen.bounds.size.width / 375.0


@interface TUILiveGiftAnimator () <TUILiveGiftAnimationManagerDelegate>

// 礼物动画管理器: 大礼物
@property (nonatomic, strong) TUILiveGiftAnimationManager *bigGiftManager;

// 动画容器
@property (nonatomic, weak) UIView *animationContainerView;

@property (nonatomic, assign) NSInteger bulletGiftCount;

@end

@implementation TUILiveGiftAnimator


- (instancetype)initWithAnimationContainerView:(UIView *)animationContainerView
{
    if (self = [super init]) {
        self.animationContainerView = animationContainerView;
        self.bulletGiftCount = 0;
    }
    return self;
}

- (void)show:(TUILiveGiftInfo *)giftInfo
{
    /**
     将礼物播放动画事件加入到礼物动画播放管理器中(内含播放队列)，管理器会控制代理进行动画的播放，可通过completion来实现动画按顺序拉取播放
     */
    
    // 弹幕礼物
    [self playBulletGiftAnimation:giftInfo completion:nil];
    
    if (giftInfo.type == 1) {
        // 大礼物
        [self.bigGiftManager onRecevieGiftInfo:giftInfo];
    }
}

- (UIView *)canvasView
{
    return self.animationContainerView;
}

// 播放大礼物特效
- (void)playBigGiftAnimation:(TUILiveGiftInfo *)giftInfo completion:(dispatch_block_t)completion
{
    if (giftInfo.lottieUrl.length == 0) {
        return;
    }
    NSURL *URL = [NSURL URLWithString:giftInfo.lottieUrl];
    LOTAnimationView *animationView = [[LOTAnimationView alloc] initWithContentsOfURL:URL];
    animationView.userInteractionEnabled = NO;
    [self.canvasView addSubview:animationView];
    CGFloat wh = self.canvasView.bounds.size.width;
    animationView.bounds = CGRectMake(0, 0, wh, wh);
    // 向上偏移，与安卓保持一致
    CGPoint center = self.canvasView.center;
    center.y = self.canvasView.bounds.size.height - 270 * kScale - 0.5 * wh;
    animationView.center = center;
    [animationView playWithCompletion:^(BOOL animationFinished) {
        if (animationFinished) {
            if (completion) {
                completion();
            }
            [animationView removeFromSuperview];
        }
    }];
}

// 播放小礼物特效
- (void)playBulletGiftAnimation:(TUILiveGiftInfo *)giftInfo completion:(dispatch_block_t)completion
{
    TUILiveBulletGiftView *bulletGiftAnimation = [[TUILiveBulletGiftView alloc] init];
    bulletGiftAnimation.giftInfo = giftInfo;
    [self.canvasView addSubview:bulletGiftAnimation];
    if (self.bulletGiftCount <= 0) {
        self.bulletGiftCount = 0;
    }
    self.bulletGiftCount++;
    [bulletGiftAnimation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.canvasView).offset(10);
        make.bottom.mas_equalTo(self.canvasView).offset(-270);
    }];
    [self.canvasView layoutIfNeeded];
    [bulletGiftAnimation playWithCompletion:^{
        bulletGiftAnimation.hidden = YES;
        if (completion) {
            completion();
        }
    }];

    int i = 0;
    TUILiveBulletGiftView *first = nil;
    for (TUILiveBulletGiftView *giftView in self.canvasView.subviews) {
        if (![giftView isKindOfClass:TUILiveBulletGiftView.class]) {
            continue;
        }


        if (i == 0) {
            first = giftView;
        }

        [giftView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.canvasView).offset(- 270 - (self.bulletGiftCount - 1 - i) * 55);
        }];
        i++;
    }


    if (self.bulletGiftCount > kMaxBulletGift && first) {
        [first removeFromSuperview];
        self.bulletGiftCount--;
    }

    [UIView animateWithDuration:0.25 animations:^{
        [self.canvasView layoutIfNeeded];
    }];
}


#pragma mark - TUILiveGiftAnimationManagerDelegate
- (void)giftAnimationManager:(TUILiveGiftAnimationManager *)mamager handleGiftAnimation:(TUILiveGiftInfo *)gift completion:(void (^)(void))completion
{
    if ([mamager isEqual:self.bigGiftManager]) {
        // 播放大礼物特效
        [self playBigGiftAnimation:gift completion:^{
            if (completion) {
                completion();
            }
        }];
    }
}

- (TUILiveGiftAnimationManager *)bigGiftManager
{
    if (_bigGiftManager == nil) {
        _bigGiftManager = [[TUILiveGiftAnimationManager alloc] init];
        _bigGiftManager.delegate = self;
    }
    return _bigGiftManager;
}
@end
