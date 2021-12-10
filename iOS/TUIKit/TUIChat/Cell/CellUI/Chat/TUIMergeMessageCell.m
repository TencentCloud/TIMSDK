//
//  TUIMergeMessageCell.m
//  Pods
//
//  Created by harvy on 2020/12/9.
//

#import "TUIMergeMessageCell.h"
#import "TUIDefine.h"

@interface TUIMergeMessageCell ()

@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *borderLayer;

@end

@implementation TUIMergeMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.container.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
    
    _relayTitleLabel = [[UILabel alloc] init];
    _relayTitleLabel.text = @"聊天记录";
    _relayTitleLabel.font = [UIFont systemFontOfSize:16];
    _relayTitleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    [self.container addSubview:_relayTitleLabel];

    _abstractLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _abstractLabel.text = @"我: ******";
    _abstractLabel.numberOfLines = 0;
    [self.container addSubview:_abstractLabel];
    
    _separtorView = [[UIView alloc] init];
    _separtorView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.container addSubview:_separtorView];
    
    _bottomTipsLabel = [[UILabel alloc] init];
    _bottomTipsLabel.text = TUIKitLocalizableString(TUIKitRelayChatHistory);
    _bottomTipsLabel.textColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1/1.0];
    _bottomTipsLabel.font = [UIFont systemFontOfSize:9];
    [self.container addSubview:_bottomTipsLabel];

    [self.container.layer insertSublayer:self.borderLayer atIndex:0];
    [self.container.layer setMask:self.maskLayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.relayTitleLabel.mm_sizeToFit().mm_top(10).mm_left(10).mm_flexToRight(10);
    self.abstractLabel.frame = CGRectMake(10, 3 + self.relayTitleLabel.mm_maxY, self.relayData.abstractSize.width, self.relayData.abstractSize.height);
    self.separtorView.frame = CGRectMake(10, self.abstractLabel.mm_maxY, self.container.mm_w - 20, 1);
    self.bottomTipsLabel.frame = CGRectMake(10, CGRectGetMaxY(self.separtorView.frame) + 5, self.abstractLabel.mm_w, 20);
    
    
    self.maskLayer.frame = self.container.bounds;
    self.borderLayer.frame = self.container.bounds;
    

    UIRectCorner corner = UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft;
    if (self.relayData.direction == MsgDirectionIncoming) {
        corner = UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight;
    }
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.container.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(10, 10)];
    self.maskLayer.path = bezierPath.CGPath;
    self.borderLayer.path = bezierPath.CGPath;
}

- (void)fillWithData:(TUIMergeMessageCellData *)data
{
    [super fillWithData:data];
    self.relayData = data;
    self.relayTitleLabel.text = data.title;
    self.abstractLabel.attributedText = [self.relayData abstractAttributedString];
}

- (CAShapeLayer *)maskLayer
{
    if (_maskLayer == nil) {
        _maskLayer = [CAShapeLayer layer];
    }
    return _maskLayer;
}

- (CAShapeLayer *)borderLayer
{
    if (_borderLayer == nil) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.lineWidth = 1.f;
        _borderLayer.strokeColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0].CGColor;
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _borderLayer;
}

@end
