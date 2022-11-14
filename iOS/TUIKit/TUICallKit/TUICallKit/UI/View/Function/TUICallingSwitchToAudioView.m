//
//  TUICallingSwitchToAudioView.m
//  TUICalling
//
//  Created by noah on 2022/5/16.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingSwitchToAudioView.h"
#import "TUICallingControlButton.h"
#import "CallingLocalized.h"
#import "UIColor+TUICallingHex.h"
#import "TUICallingCommon.h"
#import "Masonry.h"
#import "TUICallingAction.h"

@interface TUICallingSwitchToAudioView ()

@property (nonatomic, strong) TUICallingControlButton *switchToAudioBtn;

@end

@implementation TUICallingSwitchToAudioView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.switchToAudioBtn];
        
        [self.switchToAudioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.equalTo(@(CGSizeMake(200, 46)));
        }];
    }
    return self;
}

- (void)switchToAudioTouchEvent:(UIButton *)sender {
    [TUICallingAction switchToAudioCall];
}

#pragma mark - Lazy

- (TUICallingControlButton *)switchToAudioBtn {
    if (!_switchToAudioBtn) {
        __weak typeof(self) weakSelf = self;
        _switchToAudioBtn = [TUICallingControlButton createWithFrame:CGRectZero
                                                           titleText:TUICallingLocalize(@"Demo.TRTC.Calling.switchtoaudio")
                                                        buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf switchToAudioTouchEvent:sender];
        } imageSize:CGSizeMake(28, 18)];
        [_switchToAudioBtn updateTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
        [_switchToAudioBtn updateImage:[TUICallingCommon getBundleImageWithName:@"switch2audio"]];
    }
    return _switchToAudioBtn;
}

@end
