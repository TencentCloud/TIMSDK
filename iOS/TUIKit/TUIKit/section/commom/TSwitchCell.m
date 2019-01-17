//
//  TSwitchCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TSwitchCell.h"
#import "THeader.h"

@implementation TSwitchCellData
@end


@implementation TSwitchCell
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
    _sw = [[UISwitch alloc] init];
    _sw.on = NO;
    [self addSubview:_sw];
    _title = [[UILabel alloc] init];
    _title.font = [UIFont systemFontOfSize:15];
    _title.textColor = [UIColor blackColor];
    [self addSubview:_title];
    [self setSeparatorInset:UIEdgeInsetsMake(0, TSwitchCell_Margin, 0, 0)];
}


- (void)setData:(TSwitchCellData *)data
{
    //set data
    _title.text = data.title;
    _sw.on = data.isOn;
    //update layout
    CGFloat height = [TSwitchCell getHeight];
    _title.frame = CGRectMake(TSwitchCell_Margin, 0, Screen_Width - TSwitchCell_Margin, height);
    CGSize swSize = CGSizeMake(51, 31);
    _sw.frame = CGRectMake(Screen_Width - TSwitchCell_Margin - swSize.width, (height - swSize.height) * 0.5, swSize.width, swSize.height);
}

+ (CGFloat)getHeight
{
    return TSwitchCell_Height;
}
@end
