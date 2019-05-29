//
//  TPersonalCommonCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TPersonalCommonCell.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"


@implementation TPersonalCommonCellData
@end

@implementation TPersonalCommonCell
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
    CGFloat height = [TPersonalCommonCell getHeight];
    CGSize headSize = TPersonalCommonCell_Image_Size;
    _head = [[UIImageView alloc] initWithFrame:CGRectMake(TPersonalCommonCell_Margin, TPersonalCommonCell_Margin, headSize.width, headSize.height)];
    _head.layer.cornerRadius = 5;
    [_head.layer setMasksToBounds:YES];
    _head.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_head];

    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont systemFontOfSize:15]];
    [_name setTextColor:[UIColor blackColor]];
    [self addSubview:_name];
    
    _identifier = [[UILabel alloc] init];
    [_identifier setFont:[UIFont systemFontOfSize:14]];
    [_identifier setTextColor:[UIColor grayColor]];
    [self addSubview:_identifier];
    
    _signature = [[UILabel alloc] init];
    [_signature setFont:[UIFont systemFontOfSize:14]];
    [_signature setTextColor:[UIColor grayColor]];
    [self addSubview:_signature];
    
    CGSize indicatorSize = TPersonalCommonCell_Indicator_Size;
    _indicator = [[UIImageView alloc] initWithFrame:CGRectMake(Screen_Width - TPersonalCommonCell_Margin - indicatorSize.width, 0, indicatorSize.width, height)];
    _indicator.image = [UIImage imageNamed:@"right_arrow"];
    _indicator.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_indicator];
    
}


- (void)setData:(TPersonalCommonCellData *)data
{
    //set data
    _identifier.text = [@"ID: " stringByAppendingString:data.identifier];
    _name.text = data.name;
    _signature.text = data.signature;
    _head.image = [UIImage imageNamed:data.head];
    //update layout
    CGFloat originX = _head.frame.origin.x + _head.frame.size.width + TPersonalCommonCell_Margin;
    _name.mm_sizeToFit().mm_top(_head.mm_y + 2).mm_left(originX);
    _identifier.mm_sizeToFit().mm__centerY(_head.mm_centerY).mm_left(originX);
    _signature.mm_sizeToFit().mm_bottom(_head.mm_b + 2).mm_left(originX);
}

+ (CGFloat)getHeight
{
    return TPersonalCommonCell_Image_Size.height + 2 * TPersonalCommonCell_Margin;
}
@end
