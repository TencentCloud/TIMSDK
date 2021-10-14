//
//  TUILiveGiftBottomView.m
//  Pods
//
//  Created by harvy on 2020/9/16.
//

#import "Masonry.h"
#import "TUILiveGiftPanelBottomView.h"

@interface TUILiveGiftPanelBottomView ()

@property (nonatomic, strong) UIButton *chargeButton;   // 充值按钮

@end

@implementation TUILiveGiftPanelBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    [self addSubview:self.chargeButton];
    
    [self.chargeButton sizeToFit];
    [self.chargeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-10);
    }];
}

- (void)onCharge:(UIButton *)button
{
    if (self.onClick) {
        self.onClick(TUILiveGiftBottomBussinessTypeCharge, nil);
    }
}

- (UIButton *)chargeButton
{
    if (_chargeButton == nil) {
        _chargeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chargeButton setTitle:@"充值" forState:UIControlStateNormal];
        [_chargeButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        _chargeButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_chargeButton addTarget:self action:@selector(onCharge:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chargeButton;
}

@end
