//
//  TUICallingSingleVideoUserView.m
//  TUICalling
//
//  Created by noah on 2021/8/30.
//  Copyright © 2021 Tencent. All rights reserved
//

#import "TUICallingSingleVideoUserView.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "TUICallEngineHeader.h"
#import "TUICallingUserModel.h"
#import <TUICore/TUIGlobalization.h>

@interface TUICallingSingleVideoUserView ()

@property (nonatomic, strong) UIImageView *userHeadImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *waitingInviteLabel;

@end

@implementation TUICallingSingleVideoUserView

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
        make.top.trailing.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userHeadImageView.mas_top);
        make.leading.equalTo(self);
        make.trailing.equalTo(self.userHeadImageView.mas_leading).offset(-20);
    }];
    [self.waitingInviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameLabel.mas_bottom).offset(8.0f);
        make.leading.equalTo(self);
        make.trailing.equalTo(self.userHeadImageView.mas_leading).offset(-20);
    }];
}

#pragma mark - TUICallingUserViewProtocol

- (void)updateUserInfo:(CallingUserModel *)userModel hint:(NSString *)hint {
    [self.userHeadImageView sd_setImageWithURL:[NSURL URLWithString:userModel.avatar]
                              placeholderImage:[TUICallingCommon getBundleImageWithName:@"userIcon"]];
    [_userNameLabel setText:userModel.name ?: userModel.userId];
    self.waitingInviteLabel.text = hint;
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
        [_userNameLabel setTextAlignment:(isRTL() ? NSTextAlignmentLeft : NSTextAlignmentRight)];
    }
    return _userNameLabel;
}

- (UILabel *)waitingInviteLabel {
    if (!_waitingInviteLabel) {
        _waitingInviteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_waitingInviteLabel setBackgroundColor:[UIColor clearColor]];
        [_waitingInviteLabel setTextColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
        [_waitingInviteLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_waitingInviteLabel setTextAlignment:(isRTL() ? NSTextAlignmentLeft : NSTextAlignmentRight)];
    }
    return _waitingInviteLabel;
}

@end
