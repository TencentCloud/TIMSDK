//
//  TUIMergeMessageCell.m
//  Pods
//
//  Created by harvy on 2020/12/9.
//

#import "TUIMergeMessageCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@interface TUIMergeMessageCell ()

@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *borderLayer;

@end

@implementation TUIMergeMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];
    }
    return self;
}

- (void)setupViews
{
    self.container.backgroundColor = TUIChatDynamicColor(@"chat_merge_message_bg_color", @"#FFFFFF");
    
    _relayTitleLabel = [[UILabel alloc] init];
    _relayTitleLabel.text = @"Chat history";
    _relayTitleLabel.font = [UIFont systemFontOfSize:16];
    _relayTitleLabel.textColor = TUIChatDynamicColor(@"chat_merge_message_title_color", @"#000000");
    [self.container addSubview:_relayTitleLabel];

    _abstractLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _abstractLabel.text = @"Me: ******";
    _abstractLabel.numberOfLines = 0;
    _abstractLabel.textColor = TUIChatDynamicColor(@"chat_merge_message_content_color", @"#d5d5d5");
    [self.container addSubview:_abstractLabel];


    _separtorView = [[UIView alloc] init];
    _separtorView.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
    [self.container addSubview:_separtorView];
    
    _bottomTipsLabel = [[UILabel alloc] init];
    _bottomTipsLabel.text = TIMCommonLocalizableString(TUIKitRelayChatHistory);
    _bottomTipsLabel.textColor = TUIChatDynamicColor(@"chat_merge_message_content_color", @"#d5d5d5");
    _bottomTipsLabel.font = [UIFont systemFontOfSize:9];
    [self.container addSubview:_bottomTipsLabel];

    [self.container.layer insertSublayer:self.borderLayer atIndex:0];
    [self.container.layer setMask:self.maskLayer];
    
    [self prepareReactTagUI:self.container];

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
        _borderLayer.lineWidth = 1.0;
        _borderLayer.strokeColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB").CGColor;
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _borderLayer;
}

//MARK: ThemeChanged
- (void)applyBorderTheme {
    if (_borderLayer) {
        _borderLayer.strokeColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB").CGColor;
    }
}

- (void)onThemeChanged {
    [self applyBorderTheme];
}

@end
