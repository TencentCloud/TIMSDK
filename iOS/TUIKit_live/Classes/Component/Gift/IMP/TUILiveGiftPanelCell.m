//
//  TUILiveGiftInfoCell.m
//  Pods
//
//  Created by harvy on 2020/9/16.
//

#import "Masonry.h"
#import "UIImageView+WebCache.h"

#import "TUILiveGiftPanelCell.h"
#import "TUILiveGiftInfo.h"

@interface TUILiveGiftPanelCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation TUILiveGiftPanelCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.valueLabel];
    [self.contentView addSubview:self.sendButton];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerX.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView.mas_centerY).offset(-5);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView.mas_centerY).offset(5);
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(5);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)updateSelected:(BOOL)selected
{
    self.sendButton.hidden = !selected;
    self.nameLabel.text = selected?[NSString stringWithFormat:@"游戏币%zd", self.giftInfo.value]:self.giftInfo.title;
    self.valueLabel.hidden = selected;
}

- (void)setGiftInfo:(TUILiveGiftInfo *)giftInfo
{
    _giftInfo = giftInfo;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:giftInfo.giftPicUrl]];
    self.nameLabel.text = giftInfo.title;
    self.valueLabel.text = [NSString stringWithFormat:@"游戏币%zd", giftInfo.value];
    
    [self updateSelected:giftInfo.selected];
}

- (void)onSendGift:(UIButton *)sender
{
    if (self.onSendGift) {
        self.onSendGift(self.giftInfo);
    }
}

#pragma mark - Lazy
- (UIImageView *)iconView
{
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = @"火箭";
        [_nameLabel sizeToFit];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:13.0];
    }
    return _nameLabel;
}

- (UILabel *)valueLabel
{
    if (_valueLabel == nil) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.text = @"游戏币2989";
        _valueLabel.textColor = [UIColor whiteColor];
        _valueLabel.font = [UIFont systemFontOfSize:13.0];
    }
    return _valueLabel;
}

- (UIButton *)sendButton
{
    if (_sendButton == nil) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setTitle:@"赠送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _sendButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        _sendButton.layer.cornerRadius = 4.0;
        _sendButton.layer.borderWidth = 2;
        _sendButton.layer.borderColor = [UIColor redColor].CGColor;
        [_sendButton setContentEdgeInsets:UIEdgeInsetsMake(64, 0, 0, 0)];
        _sendButton.hidden = YES;
        [_sendButton addTarget:self action:@selector(onSendGift:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

@end
