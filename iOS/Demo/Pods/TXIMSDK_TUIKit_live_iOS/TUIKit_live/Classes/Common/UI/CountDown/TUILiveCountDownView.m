//
//  TUILiveCountDownView.m
//  Pods
//
//  Created by harvy on 2020/10/23.
//

#import <Masonry/Masonry.h>
#import "TUILiveCountDownView.h"

@interface TUILiveCountDownView ()

@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *countBackGroundView;

@end

@implementation TUILiveCountDownView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)beginCount:(NSInteger)count onEnd:(dispatch_block_t)onEnd
{
    __block NSInteger tmpCount = count;
    if (tmpCount == 0) {
        if (onEnd) {
            onEnd();
        }
        return;
    }
    self.countLabel.tag = count;
    self.countLabel.text = [NSString stringWithFormat:@"%zd", count];
    
    __weak typeof(self) weakSelf = self;
    self.countLabel.transform = CGAffineTransformMakeScale(0.3, 0.3);
    self.countBackGroundView.transform = CGAffineTransformMakeScale(0.3, 0.3);
    [UIView animateWithDuration:0.25 animations:^{
        self.countLabel.transform = CGAffineTransformIdentity;
        self.countBackGroundView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            tmpCount = tmpCount - 1;
            [weakSelf beginCount:tmpCount onEnd:onEnd];
        });
    }];
}

- (void)setupViews
{
    self.backgroundColor = [UIColor clearColor];
    self.countBackGroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_countdown"]];
    [self addSubview:self.countBackGroundView];
    [self addSubview:self.countLabel];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.height.mas_equalTo(172);
    }];
    [self.countBackGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.height.mas_equalTo(172);
    }];
}

- (UILabel *)countLabel
{
    if (_countLabel == nil) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.text = @"3";
        _countLabel.font = [UIFont systemFontOfSize:100.0];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        [_countLabel sizeToFit];
        _countLabel.tag = 3;
    }
    return _countLabel;
}

@end
