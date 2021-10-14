//
//  TUILiveBulletGiftView.m
//  Pods
//
//  Created by harvy on 2020/9/17.
//

#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "TUILiveBulletGiftView.h"
#import "TUILiveGiftInfo.h"

@interface TUILiveBulletGiftView () <CAAnimationDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, strong) UILabel *giftNameLabel;
@property (nonatomic, strong) UIImageView *giftIconView;

@property (nonatomic, copy) dispatch_block_t animationCompletion;

@end

@implementation TUILiveBulletGiftView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setGiftInfo:(TUILiveGiftInfo *)giftInfo
{
    _giftInfo = giftInfo;
    
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:giftInfo.sendUserHeadIcon] placeholderImage:[UIImage imageNamed:@"live_anchor_default_avatar"]];
    self.nickNameLabel.text = giftInfo.sendUser;
    self.giftNameLabel.text = [NSString stringWithFormat:@"送出了%@", giftInfo.title];
    [self.giftIconView sd_setImageWithURL:[NSURL URLWithString:giftInfo.giftPicUrl]];
}

- (void)playWithCompletion:(dispatch_block_t)completion
{
    [self layoutIfNeeded];
    self.animationCompletion = completion;
    
    [self doAnimationContentEnter];
}

- (void)setupViews
{
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.nickNameLabel];
    [self.contentView addSubview:self.giftNameLabel];
    [self.contentView addSubview:self.giftIconView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(self);
    }];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.mas_equalTo(self.contentView).offset(5);
        make.top.mas_equalTo(self.contentView).offset(5);
        make.bottom.mas_equalTo(self.contentView).offset(-5);
    }];
    
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avatarView);
        make.right.mas_equalTo(self.giftIconView.mas_left).offset(-5);
        make.left.mas_equalTo(self.avatarView.mas_right).offset(10);
    }];
    
    [self.giftNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.avatarView);
        make.left.mas_equalTo(self.nickNameLabel);
        make.right.mas_equalTo(self.giftIconView.mas_left).offset(-5);
    }];
    
    [self.giftIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-5);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.layer.cornerRadius = 0.5 * self.contentView.bounds.size.height;
}

#pragma mark - 动画
- (void)doAnimationContentEnter
{
    CGFloat width = self.contentView.bounds.size.width;
    CAKeyframeAnimation *contentAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    contentAnimation.values = @[@(-width * 0.5), @(width * 0.5 + 20), @(width * 0.5)];
    contentAnimation.duration = 0.25;
    contentAnimation.delegate = self;
    contentAnimation.removedOnCompletion = NO;
    [self.contentView.layer addAnimation:contentAnimation forKey:@"contentAnimationShow"];
}

- (void)doAnimationGiftIconEnter
{
    _giftIconView.hidden = NO;
    CGFloat width = self.contentView.bounds.size.width;
    CAKeyframeAnimation *giftAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    giftAnimation.values = @[@(-width * 0.5), @(width  - 0.5 * self.giftIconView.bounds.size.width)];
    giftAnimation.duration = 0.25;
    giftAnimation.delegate = self;
    giftAnimation.removedOnCompletion = NO;
    [self.giftIconView.layer addAnimation:giftAnimation forKey:@"giftIconAnimation"];
}

- (void)doAnimationContentDismiss
{
    CAKeyframeAnimation *contentPositionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    contentPositionAnimation.values = @[@0, @(-self.contentView.bounds.size.height)];
    contentPositionAnimation.duration = 0.25;
    
    CABasicAnimation *contentAlphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    contentAlphaAnimation.fromValue = @(1.0);
    contentAlphaAnimation.toValue  = @(0.0);
    contentAlphaAnimation.duration = 0.25;
    
    CAAnimationGroup *contentHiddenAnimation = [CAAnimationGroup animation];
    contentHiddenAnimation.animations = @[contentPositionAnimation, contentAlphaAnimation];
    contentHiddenAnimation.delegate = self;
    contentHiddenAnimation.removedOnCompletion = NO;
    
    [self.contentView.layer addAnimation:contentHiddenAnimation forKey:@"contentViewHiddenAnimation"];
}

#pragma mark - 动画: CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([self.contentView.layer animationForKey:@"contentAnimationShow"]  == anim) {
        if (flag) {
            [self.contentView.layer removeAllAnimations];
            [self doAnimationGiftIconEnter];
        }
    }else if ([self.giftIconView.layer animationForKey:@"giftIconAnimation"] == anim) {
        if (flag) {
            [self.giftIconView.layer removeAllAnimations];
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf doAnimationContentDismiss];
                // 避免动画结束时view还没来得及移除，出现动画闪现的问题
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.contentView.hidden = YES;
                });
            });
        }
    } else if ([self.contentView.layer animationForKey:@"contentViewHiddenAnimation"] == anim) {
        if (flag) {
            [self.contentView.layer removeAllAnimations];
            if (self.animationCompletion) {
                self.animationCompletion();
            }
        }
    }
}

- (UIView *)contentView
{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _contentView;
}


- (UIImageView *)avatarView
{
    if (_avatarView == nil) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 20.0;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)nickNameLabel
{
    if (_nickNameLabel == nil) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.text = @"我";
        _nickNameLabel.textColor = [UIColor whiteColor];
        _nickNameLabel.font = [UIFont systemFontOfSize:13.0];
        _nickNameLabel.textAlignment = NSTextAlignmentLeft;
        [_nickNameLabel sizeToFit];
    }
    return _nickNameLabel;
}

- (UILabel *)giftNameLabel
{
    if (_giftNameLabel == nil) {
        _giftNameLabel = [[UILabel alloc] init];
        _giftNameLabel.text = @"送出火箭";
        _giftNameLabel.textColor = [UIColor whiteColor];
        _giftNameLabel.font = [UIFont systemFontOfSize:13.0];
        _giftNameLabel.textAlignment = NSTextAlignmentLeft;
        [_giftNameLabel sizeToFit];
    }
    return _giftNameLabel;
}

- (UIImageView *)giftIconView
{
    if (_giftIconView == nil) {
        _giftIconView = [[UIImageView alloc] init];
        _giftIconView.hidden = YES;
    }
    return _giftIconView;
}

@end
