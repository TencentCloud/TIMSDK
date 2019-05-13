//
//  TConversationCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/14.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TConversationCell.h"
#import "THeader.h"

@implementation TConversationCellData
@end

@interface TConversationCell ()
@property (nonatomic, strong) TConversationCellData *data;
@end

@implementation TConversationCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

+ (CGSize)getSize;
{
    return CGSizeMake(Screen_Width, TConversationCell_Height);
}

- (void)setData:(TConversationCellData *)data
{
    _data = data;
    _headImageView.image = [UIImage imageNamed:_data.head];
    _timeLabel.text = _data.time;
    _titleLabel.text = _data.title;
    _subTitleLabel.text = _data.subTitle;
    [_unReadView setNum:_data.unRead];
    
    if (_data.isOnTop) {
        self.backgroundColor = RGB(245, 245, 248);
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    [self defaultLayout];
}

- (void)setupViews
{
    self.backgroundColor = [UIColor whiteColor];
    
    _headImageView = [[UIImageView alloc] init];
//    _headImageView.backgroundColor = self.backgroundColor;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = 5;
    [self addSubview:_headImageView];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor lightGrayColor];
    _timeLabel.layer.masksToBounds = YES;
    [self addSubview:_timeLabel];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.layer.masksToBounds = YES;
    [self addSubview:_titleLabel];
    
    _unReadView = [[TUnReadView alloc] init];
    [self addSubview:_unReadView];

    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.layer.masksToBounds = YES;
    _subTitleLabel.font = [UIFont systemFontOfSize:14];
    _subTitleLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_subTitleLabel];
    
    [self setSeparatorInset:UIEdgeInsetsMake(0, TConversationCell_Margin, 0, 0)];
}

- (void)defaultLayout
{
    CGSize size = [TConversationCell getSize];
    _headImageView.frame = CGRectMake(TConversationCell_Margin, TConversationCell_Margin, size.height - TConversationCell_Margin * 2, size.height - TConversationCell_Margin * 2);
    
    [_timeLabel sizeToFit];
    _timeLabel.frame = CGRectMake(size.width - TConversationCell_Margin - _timeLabel.frame.size.width, TConversationCell_Margin_Text, _timeLabel.frame.size.width, _timeLabel.frame.size.height);

    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(_headImageView.frame.origin.x + _headImageView.frame.size.width + TConversationCell_Margin, TConversationCell_Margin_Text, size.width - _timeLabel.frame.size.width - _headImageView.frame.size.width - 4 * TConversationCell_Margin, _titleLabel.frame.size.height);
    
    _unReadView.frame = CGRectMake(size.width - TConversationCell_Margin - _unReadView.frame.size.width, size.height - TConversationCell_Margin_Text - _unReadView.frame.size.height, _unReadView.frame.size.width, _unReadView.frame.size.height);
    
    [_subTitleLabel sizeToFit];
    _subTitleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, size.height - TConversationCell_Margin_Text - _subTitleLabel.frame.size.height, size.width - _headImageView.frame.size.width - 4 * TConversationCell_Margin - _unReadView.frame.size.width, _subTitleLabel.frame.size.height);
}

@end
