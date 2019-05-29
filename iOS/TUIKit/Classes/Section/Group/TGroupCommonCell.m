//
//  TGroupCommonCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TGroupCommonCell.h"
#import "THeader.h"


@implementation TGroupCommonCellData
@end

@implementation TGroupCommonCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    CGFloat height = [TGroupCommonCell getHeight];
    CGSize headSize = TGroupCommonCell_Image_Size;
    _head = [[UIImageView alloc] initWithFrame:CGRectMake(TGroupCommonCell_Margin, TGroupCommonCell_Margin, headSize.width, headSize.height)];
    _head.layer.cornerRadius = 5;
    [_head.layer setMasksToBounds:YES];
    _head.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_head];
    _groupName = [[UILabel alloc] init];
    [_groupName setFont:[UIFont systemFontOfSize:15]];
    [_groupName setTextColor:[UIColor blackColor]];
    [self addSubview:_groupName];
    
    _groupId = [[UILabel alloc] init];
    [_groupId setFont:[UIFont systemFontOfSize:14]];
    [_groupId setTextColor:[UIColor grayColor]];
    [self addSubview:_groupId];
    
    _notification = [[UILabel alloc] init];
    [_notification setFont:[UIFont systemFontOfSize:14]];
    [_notification setTextColor:[UIColor grayColor]];
    [self addSubview:_notification];
    
    CGSize indicatorSize = TGroupCommonCell_Indicator_Size;
    _indicator = [[UIImageView alloc] initWithFrame:CGRectMake(Screen_Width - TGroupCommonCell_Margin - indicatorSize.width, 0, indicatorSize.width, height)];
    _indicator.image = [UIImage imageNamed:TUIKitResource(@"right_arrow")];
    _indicator.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_indicator];
    
}


- (void)setData:(TGroupCommonCellData *)data
{
    //set data
    _groupName.text = data.groupName;
    _groupId.text = data.groupId;
    _notification.text = data.notification;
    _head.image = [UIImage imageNamed:data.head];
    //update layout
    CGFloat height = [TGroupCommonCell getHeight];
    CGFloat originX = _head.frame.origin.x + _head.frame.size.width + TGroupCommonCell_Margin;
    CGFloat maxWidth = _indicator.frame.origin.x - originX;
    CGFloat textHeight = (_head.frame.size.height - 4) / 3;
    _groupName.frame = CGRectMake(originX, TGroupCommonCell_Margin + 2, maxWidth, textHeight);
    _notification.frame = CGRectMake(originX, height - textHeight - TGroupCommonCell_Margin - 2, maxWidth, textHeight);
    _groupId.frame = CGRectMake(originX, (_groupName.frame.origin.y + _notification.frame.origin.y) * 0.5, maxWidth, textHeight);
}

+ (CGFloat)getHeight
{
    return TGroupCommonCell_Image_Size.height + 2 * TGroupCommonCell_Margin;
}
@end
