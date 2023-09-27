//
//  TUICallingAudioFunctionView.m
//  TUICalling
//
//  Created by noah on 2022/5/16.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingAudioFunctionView.h"
#import "TUICallingAction.h"
#import "Masonry.h"

@interface TUICallingAudioFunctionView ()

@property (nonatomic, strong) TUICallingControlButton *muteBtn;
@property (nonatomic, strong) TUICallingControlButton *hangupBtn;
@property (nonatomic, strong) TUICallingControlButton *handsfreeBtn;

@end

@implementation TUICallingAudioFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.muteBtn];
        [self addSubview:self.hangupBtn];
        [self addSubview:self.handsfreeBtn];
        
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    [self.muteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.hangupBtn.mas_leading).offset(-5);
        make.centerY.equalTo(self.hangupBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.handsfreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.hangupBtn.mas_trailing).offset(5);
        make.centerY.equalTo(self.hangupBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
}

#pragma mark - TUICallingFunctionViewProtocol

- (void)updateTextColor:(UIColor *)textColor {
    [self.muteBtn updateTitleColor:textColor];
    [self.handsfreeBtn updateTitleColor:textColor];
    [self.hangupBtn updateTitleColor:textColor];
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

- (void)hangupTouchEvent:(UIButton *)sender {
    [TUICallingAction hangup];
}

- (void)hangsfreeTouchEvent:(UIButton *)sender {
    [TUICallingAction selectAudioPlaybackDevice];
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

- (TUICallingControlButton *)handsfreeBtn {
    if (!_handsfreeBtn) {
        __weak typeof(self) weakSelf = self;
        _handsfreeBtn = [TUICallingControlButton createWithFrame:CGRectZero
                                                       titleText:TUICallingLocalize(@"Demo.TRTC.Calling.speaker")
                                                    buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf hangsfreeTouchEvent:sender];
        } imageSize:kBtnSmallSize];
        [_handsfreeBtn updateImage:[TUICallingCommon getBundleImageWithName:@"ic_handsfree_on"]];
        [_handsfreeBtn updateTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _handsfreeBtn;
}

@end
