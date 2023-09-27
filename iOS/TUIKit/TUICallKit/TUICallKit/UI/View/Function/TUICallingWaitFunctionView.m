//
//  TUICallingWaitFunctionView.m
//  TUICalling
//
//  Created by noah on 2021/8/30.
//  Copyright © 2021 Tencent. All rights reserved
//

#import "TUICallingWaitFunctionView.h"
#import "Masonry.h"
#import <TUICore/TUIGlobalization.h>

@interface TUICallingWaitFunctionView ()

@property (nonatomic, strong) TUICallingControlButton *rejectBtn;
@property (nonatomic, strong) TUICallingControlButton *acceptBtn;

@end

@implementation TUICallingWaitFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.rejectBtn];
        [self addSubview:self.acceptBtn];
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    [self.rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(isRTL() ? 80 : -80);
        make.bottom.equalTo(self);
        make.width.equalTo(@(100));
        make.height.equalTo(@(94));
    }];
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(isRTL() ? -80 : 80);
        make.bottom.equalTo(self);
        make.width.equalTo(@(100));
        make.height.equalTo(@(94));
    }];
}

#pragma mark - TUICallingFunctionViewProtocol

- (void)updateTextColor:(UIColor *)textColor {
    [self.rejectBtn updateTitleColor:textColor];
    [self.acceptBtn updateTitleColor:textColor];
}

#pragma mark - Event Action

- (void)rejectTouchEvent:(UIButton *)sender {
    [TUICallingAction reject];
}

- (void)acceptTouchEvent:(UIButton *)sender {
    [TUICallingAction accept];
}

#pragma mark - Lazy

- (TUICallingControlButton *)acceptBtn {
    if (!_acceptBtn) {
        __weak typeof(self) weakSelf = self;
        _acceptBtn = [TUICallingControlButton createWithFrame:CGRectZero
                                                    titleText:TUICallingLocalize(@"Demo.TRTC.Calling.answer")
                                                 buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf acceptTouchEvent:sender];
        } imageSize:CGSizeMake(64, 64)];
        [_acceptBtn updateTitleColor:[UIColor t_colorWithHexString:@"#666666"]];
        [_acceptBtn updateImage:[TUICallingCommon getBundleImageWithName:@"trtccalling_ic_dialing"]];
    }
    return _acceptBtn;
}

- (TUICallingControlButton *)rejectBtn {
    if (!_rejectBtn) {
        __weak typeof(self) weakSelf = self;
        _rejectBtn = [TUICallingControlButton createWithFrame:CGRectZero
                                                    titleText:TUICallingLocalize(@"Demo.TRTC.Calling.decline")
                                                 buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf rejectTouchEvent:sender];
        } imageSize:CGSizeMake(64, 64)];
        [_rejectBtn updateTitleColor:[UIColor t_colorWithHexString:@"#666666"]];
        [_rejectBtn updateImage:[TUICallingCommon getBundleImageWithName:@"ic_hangup"]];
    }
    
    return _rejectBtn;
}

@end
