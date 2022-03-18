//
//  TUIVodeoUserContainerView.m
//  TUICalling
//
//  Created by noah on 2021/8/30.
//

#import "TUIVideoUserContainerView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import "TRTCCallingModel.h"
#import "UIColor+TUIHex.h"
#import "CallingLocalized.h"
#import "TUICommonUtil.h"

@interface TUIVideoUserContainerView ()

/// 用户头像视图
@property (nonatomic, strong) UIImageView *userHeadImageView;

/// 用户名称视图
@property (nonatomic, strong) UILabel *userNameLabel;

/// 用户正在准备接通视图
@property (nonatomic, strong) UILabel *waitingInviteLabel;

@end

@implementation TUIVideoUserContainerView

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
        make.top.right.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userHeadImageView.mas_top);
        make.left.equalTo(self);
        make.right.equalTo(self.userHeadImageView.mas_left).offset(-20);
    }];
    [self.waitingInviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameLabel.mas_bottom).offset(8.0f);
        make.left.equalTo(self);
        make.right.equalTo(self.userHeadImageView.mas_left).offset(-20);
    }];
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
        _userHeadImageView.layer.cornerRadius = 5.0f;
    }
    return _userHeadImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_userNameLabel setTextColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
        [_userNameLabel setFont:[UIFont boldSystemFontOfSize:24.0f]];
        [_userNameLabel setBackgroundColor:[UIColor clearColor]];
        [_userNameLabel setTextAlignment:NSTextAlignmentRight];
    }
    return _userNameLabel;
}

- (UILabel *)waitingInviteLabel {
    if (!_waitingInviteLabel) {
        _waitingInviteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_waitingInviteLabel setBackgroundColor:[UIColor clearColor]];
        [_waitingInviteLabel setTextColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
        [_waitingInviteLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_waitingInviteLabel setTextAlignment:NSTextAlignmentRight];
    }
    return _waitingInviteLabel;
}

@end
