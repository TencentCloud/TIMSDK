//
//  TUIAudioUserContainerView.m
//  TUICalling
//
//  Created by noah on 2021/8/30.
//

#import "TUIAudioUserContainerView.h"
#import <Masonry/Masonry.h>
#import "TRTCCallingModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+TUIHex.h"
#import "CallingLocalized.h"
#import "TUICommonUtil.h"

@interface TUIAudioUserContainerView ()

/// 用户头像视图
@property (nonatomic, strong) UIImageView *userHeadImageView;

/// 用户名称视图
@property (nonatomic, strong) UILabel *userNameLabel;

/// 用户正在准备接通视图
@property (nonatomic, strong) UILabel *waitingInviteLabel;

@end

@implementation TUIAudioUserContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.userHeadImageView];
        [self addSubview:self.userNameLabel];
        [self addSubview:self.waitingInviteLabel];
        
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    [self.userHeadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(120, 120));
    }];
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userHeadImageView.mas_bottom).offset(20);
        make.centerX.bottom.equalTo(self);
        make.leading.greaterThanOrEqualTo(self);
        make.trailing.lessThanOrEqualTo(self);
    }];
    
    [self.waitingInviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom).offset(5);
        make.centerX.equalTo(self);
        make.leading.greaterThanOrEqualTo(self).offset(20);
        make.trailing.lessThanOrEqualTo(self).offset(-20);
    }];
}

- (void)setUserNameTextColor:(UIColor *)textColor {
    if (textColor) {
        self.userNameLabel.textColor = textColor;
    }
}

- (void)configUserInfoViewWith:(CallUserModel *)userModel showWaitingText:(NSString *)text {
    [self.userHeadImageView sd_setImageWithURL:[NSURL URLWithString:userModel.avatar] placeholderImage:[TUICommonUtil getBundleImageWithName:@"userIcon"]];
    [_userNameLabel setText:userModel.name ?: userModel.userId];
    self.waitingInviteLabel.text = text;
}

#pragma mark - Lazy

- (UIImageView *)userHeadImageView {
    if (!_userHeadImageView) {
        _userHeadImageView = [[UIImageView alloc] initWithFrame: CGRectZero];
        _userHeadImageView.layer.masksToBounds = YES;
        _userHeadImageView.layer.cornerRadius = 5.0;
    }
    return _userHeadImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_userNameLabel setTextColor:[UIColor t_colorWithHexString:@"#000000"]];
        [_userNameLabel setFont:[UIFont boldSystemFontOfSize:24.0f]];
        [_userNameLabel setBackgroundColor:[UIColor clearColor]];
        [_userNameLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _userNameLabel;
}

- (UILabel *)waitingInviteLabel {
    if (!_waitingInviteLabel) {
        _waitingInviteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_waitingInviteLabel setTextColor:[UIColor t_colorWithHexString:@"#999999"]];
        [_waitingInviteLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_waitingInviteLabel setBackgroundColor:[UIColor clearColor]];
        [_waitingInviteLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _waitingInviteLabel;
}

@end
