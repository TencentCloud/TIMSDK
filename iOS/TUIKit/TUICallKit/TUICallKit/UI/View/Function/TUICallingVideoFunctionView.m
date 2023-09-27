//
//  TUICallingVideoFunctionView.m
//  TUICalling
//
//  Created by noah on 2022/5/16.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingVideoFunctionView.h"
#import "Masonry.h"

@interface TUICallingVideoFunctionView ()

@property (nonatomic, strong) TUICallingControlButton *muteBtn;
@property (nonatomic, strong) TUICallingControlButton *handsfreeBtn;
@property (nonatomic, strong) TUICallingControlButton *closeCameraBtn;
@property (nonatomic, strong) TUICallingControlButton *hangupBtn;
@property (nonatomic, strong) UIButton *switchCameraBtn;

@end

@implementation TUICallingVideoFunctionView

@synthesize localPreView = _localPreView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.muteBtn];
        [self addSubview:self.handsfreeBtn];
        [self addSubview:self.closeCameraBtn];
        [self addSubview:self.hangupBtn];
        [self addSubview:self.switchCameraBtn];
        
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    [self.muteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.handsfreeBtn.mas_leading);
        make.centerY.equalTo(self.handsfreeBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.handsfreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.hangupBtn.mas_top).offset(-10);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.closeCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.handsfreeBtn.mas_trailing);
        make.centerY.equalTo(self.handsfreeBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
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
    [self.muteBtn updateTitleColor:textColor];
    [self.handsfreeBtn updateTitleColor:textColor];
    [self.closeCameraBtn updateTitleColor:textColor];
    [self.hangupBtn updateTitleColor:textColor];
}

- (void)updateCameraOpenStatus {
    NSString *imageName = [TUICallingStatusManager shareInstance].isCloseCamera ? @"camera_off" : @"camera_on";
    [self.closeCameraBtn updateImage:[TUICallingCommon getBundleImageWithName:imageName]];
}

- (void)updateHandsFreeStatus {
    NSString *imageName = @"ic_handsfree_on";
    if ([TUICallingStatusManager shareInstance].audioPlaybackDevice == TUIAudioPlaybackDeviceEarpiece) {
        imageName = @"ic_handsfree";
    }
    [self.handsfreeBtn updateImage:[TUICallingCommon getBundleImageWithName:imageName]];
}

- (void)updateMicMuteStatus {
    NSString *imageName = [TUICallingStatusManager shareInstance].isMicMute ? @"ic_mute" : @"ic_mute_on";
    [self.muteBtn updateImage:[TUICallingCommon getBundleImageWithName:imageName]];
}

#pragma mark - Action Event

- (void)muteTouchEvent:(UIButton *)sender {
    if ([TUICallingStatusManager shareInstance].isMicMute) {
        [TUICallingAction closeMicrophone];
    } else {
        [TUICallingAction openMicrophone];
    }
}

- (void)closeCameraTouchEvent:(UIButton *)sender {
    if (![TUICallingStatusManager shareInstance].isCloseCamera) {
        [TUICallingAction closeCamera];
    } else {
        [TUICallingAction openCamera:[TUICallingStatusManager shareInstance].camera videoView:_localPreView];
    }
}

- (void)hangsfreeTouchEvent:(UIButton *)sender {
    [TUICallingAction selectAudioPlaybackDevice];
}

- (void)hangupTouchEvent:(UIButton *)sender {
    [TUICallingAction hangup];
}

- (void)switchCameraTouchEvent:(UIButton *)sender {
    [TUICallingAction switchCamera];
}

#pragma mark - Lazy

- (TUICallingControlButton *)muteBtn {
    if (!_muteBtn) {
        __weak typeof(self) weakSelf = self;
        _muteBtn = [TUICallingControlButton createWithFrame:CGRectZero
                                                  titleText:TUICallingLocalize(@"Demo.TRTC.Calling.mic")
                                               buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf muteTouchEvent:sender];
        } imageSize:kBtnSmallSize];
        [_muteBtn updateImage:[TUICallingCommon getBundleImageWithName:@"ic_mute"]];
    }
    return _muteBtn;
}

- (TUICallingControlButton *)closeCameraBtn {
    if (!_closeCameraBtn) {
        __weak typeof(self) weakSelf = self;
        _closeCameraBtn = [TUICallingControlButton createWithFrame:CGRectZero
                                                         titleText:TUICallingLocalize(@"Demo.TRTC.Calling.camera")
                                                      buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf closeCameraTouchEvent:sender];
        } imageSize:kBtnSmallSize];
        [_closeCameraBtn updateTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
        [_closeCameraBtn updateImage:[TUICallingCommon getBundleImageWithName:@"camera_on"]];
    }
    return _closeCameraBtn;
}

- (TUICallingControlButton *)handsfreeBtn {
    if (!_handsfreeBtn) {
        __weak typeof(self) weakSelf = self;
        _handsfreeBtn = [TUICallingControlButton createWithFrame:CGRectZero
                                                       titleText:TUICallingLocalize(@"Demo.TRTC.Calling.speaker")
                                                    buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf hangsfreeTouchEvent:sender];
        } imageSize:kBtnSmallSize];
        [_handsfreeBtn updateImage:[TUICallingCommon getBundleImageWithName:@"ic_handsfree"]];
    }
    return _handsfreeBtn;
}

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
