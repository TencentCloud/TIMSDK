//
//  TUICallingUserView.m
//  TUICalling
//
//  Created by noah on 2021/8/30.
//  Copyright © 2021 Tencent. All rights reserved
//

#import "TUICallingUserView.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "TUICallEngineHeader.h"
#import "TUICallingUserModel.h"

@interface TUICallingUserView ()

@property (nonatomic, strong) UIImageView *userHeadImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *waitingInviteLabel;

@end

@implementation TUICallingUserView

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

#pragma mark - TUICallingUserViewProtocol

- (void)updateUserInfo:(CallingUserModel *)userModel hint:(NSString *)hint {
    [self.userHeadImageView sd_setImageWithURL:[NSURL URLWithString:userModel.avatar]
                              placeholderImage:[TUICallingCommon getBundleImageWithName:@"userIcon"]];
    [_userNameLabel setText:userModel.name ?: userModel.userId];
    self.waitingInviteLabel.text = hint;
}

- (void)updateTextColor:(UIColor *)textColor {
    if (textColor) {
        self.userNameLabel.textColor = textColor;
    }
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
