//
//  TUICallingVideoInviteFunctionView.m
//  TUICalling
//
//  Created by noah on 2022/5/16.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingVideoInviteFunctionView.h"
#import "Masonry.h"

@interface TUICallingVideoInviteFunctionView ()

@property (nonatomic, strong) TUICallingControlButton *hangupBtn;
@property (nonatomic, strong) UIButton *switchCameraBtn;

@end

@implementation TUICallingVideoInviteFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.hangupBtn];
        [self addSubview:self.switchCameraBtn];
        
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    [self.hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.hangupBtn);
        make.leading.equalTo(self.hangupBtn.mas_trailing).offset(20);
        make.size.equalTo(@(CGSizeMake(36, 36)));
    }];
}

#pragma mark - TUICallingFunctionViewProtocol

- (void)updateTextColor:(UIColor *)textColor {
    [self.hangupBtn updateTitleColor:textColor];
}

#pragma mark - Action Event

- (void)hangupTouchEvent:(UIButton *)sender {
    [TUICallingAction hangup];
}

- (void)switchCameraTouchEvent:(UIButton *)sender {
    [TUICallingAction switchCamera];
}

#pragma mark - Lazy

- (TUICallingControlButton *)hangupBtn {
    if (!_hangupBtn) {
        __weak typeof(self) weakSelf = self;
        _hangupBtn = [TUICallingControlButton createWithFrame:CGRectZero
                                                    titleText:TUICallingLocalize(@"Demo.TRTC.Calling.hangup")
                                                 buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf hangupTouchEvent:sender];
        } imageSize:kBtnLargeSize];
        [_hangupBtn updateImage:[TUICallingCommon getBundleImageWithName:@"ic_hangup"]];
    }
    return _hangupBtn;
}

- (UIButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        _switchCameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_switchCameraBtn setBackgroundImage:[TUICallingCommon getBundleImageWithName:@"switch_camera"] forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

@end
