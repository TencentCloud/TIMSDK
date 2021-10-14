//
//  TUILiveRoomTipsView.m
//  Pods
//
//  Created by harvy on 2020/9/25.
//

#import "Masonry.h"
#import "UIImageView+WebCache.h"
#import "TUILiveRoomTipsView.h"

@interface TUILiveRoomTipsView ()

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, copy) dispatch_block_t action;

@end

@implementation TUILiveRoomTipsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)updateTips:(NSString *)tips background:(NSString *)url action:(dispatch_block_t)action
{
    self.action = action;
    self.tipsLabel.text = tips;
    [self.backgroundView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"live_room_list_item_bg"]];
}

- (void)setupViews
{
    [self addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.tipsLabel];
    [self.backgroundView addSubview:self.actionButton];
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.backgroundView);
    }];
    
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.backgroundView).offset(-15);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.backgroundView.mas_safeAreaLayoutGuideBottom).offset(-10);
        }else {        
            make.bottom.mas_equalTo(self.backgroundView).offset(-10);
        }
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
}

- (void)close
{
    if (self.action) {
        self.action();
    }
}

- (UILabel *)tipsLabel
{
    if (_tipsLabel == nil) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textColor = [UIColor whiteColor];
    }
    return _tipsLabel;
}

- (UIImageView *)backgroundView
{
    if (_backgroundView == nil) {
        _backgroundView = [[UIImageView alloc] init];
        _backgroundView.userInteractionEnabled = YES;
    }
    return _backgroundView;
}

- (UIButton *)actionButton
{
    if (_actionButton == nil) {
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_actionButton setImage:[UIImage imageNamed:@"live_anchor_close"] forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        _actionButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _actionButton.layer.cornerRadius = 20;
        _actionButton.layer.masksToBounds = YES;
    }
    return _actionButton;
}

@end
