//
//  TUIMergeMessageCell.m
//  Pods
//
//  Created by harvy on 2020/12/9.
//

#import "TUIMergeMessageCell.h"
#import "UIColor+TUIDarkMode.h"
#import "THeader.h"
#import "UIView+MMLayout.h"

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
    _relayTitleLabel.font = [UIFont systemFontOfSize:15];
    _relayTitleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    [self.container addSubview:_relayTitleLabel];

    _abstractLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _abstractLabel.text = @"我: ******";
    _abstractLabel.numberOfLines = 0;
    _abstractLabel.font = [UIFont systemFontOfSize:10];
    _abstractLabel.textColor = [UIColor d_systemGrayColor];
    [self.container addSubview:_abstractLabel];

    [self.container.layer setMasksToBounds:YES];
    [self.container.layer setBorderColor:[UIColor d_systemGrayColor].CGColor];
    [self.container.layer setBorderWidth:1];
    [self.container.layer setCornerRadius:5];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.relayTitleLabel.mm_sizeToFit().mm_top(10).mm_left(10).mm_flexToRight(10);
    self.abstractLabel.frame = CGRectMake(10, 3 + self.relayTitleLabel.mm_maxY, self.relayData.abstractSize.width, self.relayData.abstractSize.height);
}

- (void)fillWithData:(TUIMergeMessageCellData *)data
{
    [super fillWithData:data];
    self.relayData = data;
    self.relayTitleLabel.text = data.title;
    self.abstractLabel.attributedText = [self.relayData abstractAttributedString];
}

@end
