//
//  TUIMergeMessageCell.m
//  Pods
//
//  Created by harvy on 2020/12/9.
//

#import "TUIMergeMessageCell_Minimalist.h"
#import <TUICore/TUIThemeManager.h>
#import <TIMCommon/TIMDefine.h>

@implementation TUIMergeMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.container.backgroundColor = RGBA(249, 249, 249, 0.94);
    
    _relayTitleLabel = [[UILabel alloc] init];
    _relayTitleLabel.text = @"Chat history";
    _relayTitleLabel.font = [UIFont systemFontOfSize:12];
    _relayTitleLabel.textColor = RGBA(0, 0, 0, 0.8);
    [self.container addSubview:_relayTitleLabel];

    _abstractLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _abstractLabel.text = @"Me: ******";
    _abstractLabel.font = [UIFont systemFontOfSize:12];
    _abstractLabel.numberOfLines = 0;
    _abstractLabel.textColor = RGBA(153, 153, 153, 1);
    [self.container addSubview:_abstractLabel];

    _separtorView = [[UIView alloc] init];
    _separtorView.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
    [self.container addSubview:_separtorView];
    
    _bottomTipsLabel = [[UILabel alloc] init];
    _bottomTipsLabel.text = TIMCommonLocalizableString(TUIKitRelayChatHistory);
    _bottomTipsLabel.textColor = RGBA(153, 153, 153, 1);
    _bottomTipsLabel.font = [UIFont systemFontOfSize:10];
    [self.container addSubview:_bottomTipsLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.relayTitleLabel.mm_sizeToFit().mm_top(10).mm_left(10).mm_flexToRight(10);
    self.abstractLabel.frame = CGRectMake(10, 3 + self.relayTitleLabel.mm_maxY, self.relayData.abstractSize.width, self.relayData.abstractSize.height);
    self.separtorView.frame = CGRectMake(10, self.abstractLabel.mm_maxY, self.container.mm_w - 20, 1);
    self.bottomTipsLabel.frame = CGRectMake(10, CGRectGetMaxY(self.separtorView.frame) + 5, self.abstractLabel.mm_w, 20);
}

- (void)fillWithData:(TUIMergeMessageCellData_Minimalist *)data
{
    [super fillWithData:data];
    self.relayData = data;
    self.relayTitleLabel.text = data.title;
    self.abstractLabel.attributedText = [self.relayData abstractAttributedString];
}


@end
