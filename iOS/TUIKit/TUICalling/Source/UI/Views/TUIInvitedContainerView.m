//
//  TUIInvitedContainerView.m
//  TUICalling
//
//  Created by noah on 2021/8/30.
//

#import "TUIInvitedContainerView.h"
#import <Masonry/Masonry.h>
#import "TUICommonUtil.h"
#import "TUICallingControlButton.h"
#import "CallingLocalized.h"
#import "UIColor+TUIHex.h"

@interface TUIInvitedContainerView ()

/// 拒接通话按钮
@property (nonatomic, strong) TUICallingControlButton *refuseBtn;

/// 接收通话按钮
@property (nonatomic, strong) TUICallingControlButton *acceptBtn;

@end

@implementation TUIInvitedContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.acceptBtn];
        [self addSubview:self.refuseBtn];
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    [self.refuseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(-80);
        make.bottom.equalTo(self);
        make.width.equalTo(@(100));
        make.height.equalTo(@(94));
    }];
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(80);
        make.bottom.equalTo(self);
        make.width.equalTo(@(100));
        make.height.equalTo(@(94));
    }];
}

- (void)configTitleColor:(UIColor *)titleColor {
    [_acceptBtn configTitleColor:titleColor];
    [_refuseBtn configTitleColor:titleColor];
}

#pragma mark - Event Action

- (void)acceptTouchEvent:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(acceptCalling)]) {
        [self.delegate acceptCalling];
    }
}

- (void)refuseTouchEvent:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(refuseCalling)]) {
        [self.delegate refuseCalling];
    }
}

#pragma mark - Lazy

- (TUICallingControlButton *)acceptBtn {
    if (!_acceptBtn) {
        _acceptBtn = [TUICallingControlButton createViewWithFrame:CGRectZero titleText:TUICallingLocalize(@"Demo.TRTC.Calling.answer") buttonAction:^(UIButton * _Nonnull sender) {
            [self acceptTouchEvent:sender];
        } imageSize:CGSizeMake(64, 64)];
        [_acceptBtn configTitleColor:[UIColor t_colorWithHexString:@"#666666"]];
        [_acceptBtn configBackgroundImage:[TUICommonUtil getBundleImageWithName:@"trtccalling_ic_dialing"]];
    }
    return _acceptBtn;
}

- (TUICallingControlButton *)refuseBtn {
    if (!_refuseBtn) {
        _refuseBtn = [TUICallingControlButton createViewWithFrame:CGRectZero titleText:TUICallingLocalize(@"Demo.TRTC.Calling.decline") buttonAction:^(UIButton * _Nonnull sender) {
            [self refuseTouchEvent:sender];
        } imageSize:CGSizeMake(64, 64)];
        [_refuseBtn configTitleColor:[UIColor t_colorWithHexString:@"#666666"]];
        [_refuseBtn configBackgroundImage:[TUICommonUtil getBundleImageWithName:@"ic_hangup"]];
    }
    
    return _refuseBtn;
}

@end
