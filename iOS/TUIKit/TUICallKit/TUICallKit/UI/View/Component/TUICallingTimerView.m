//
//  TUICallingTimerView.m
//  TUICalling
//
//  Created by noah on 2022/5/16.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingTimerView.h"
#import "UIColor+TUICallingHex.h"
#import "Masonry.h"

@interface TUICallingTimerView ()

@property (nonatomic, strong) UILabel *timerLabel;

@end

@implementation TUICallingTimerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.timerLabel];
        
        [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)setTimerTextColor:(UIColor *)textColor {
    if (textColor) {
        self.timerLabel.textColor = textColor;
    }
}

- (void)updateTimerText:(NSString *)text {
    self.timerLabel.text = text;
}

#pragma mark - Lazy

- (UILabel *)timerLabel {
    if (!_timerLabel) {
        _timerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_timerLabel setTextColor:[UIColor t_colorWithHexString:@"#000000"]];
        [_timerLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_timerLabel setBackgroundColor:[UIColor clearColor]];
        [_timerLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _timerLabel;
}

@end
