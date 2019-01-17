//
//  TPersonalCommonCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TPersonalCommonCell.h"
#import "THeader.h"


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
    
    _identifier = [[UILabel alloc] init];
    [_identifier setFont:[UIFont systemFontOfSize:15]];
    [_identifier setTextColor:[UIColor blackColor]];
    [self addSubview:_identifier];
    
    _nick = [[UILabel alloc] init];
    [_nick setFont:[UIFont systemFontOfSize:14]];
    [_nick setTextColor:[UIColor grayColor]];
    [self addSubview:_nick];
    
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
    _identifier.text = data.identifier;
    _nick.text = data.nick;
    _signature.text = data.signature;
    _head.image = [UIImage imageNamed:data.head];
    //update layout
    CGFloat height = [TPersonalCommonCell getHeight];
    CGFloat originX = _head.frame.origin.x + _head.frame.size.width + TPersonalCommonCell_Margin;
    CGFloat maxWidth = _indicator.frame.origin.x - originX;
    CGFloat textHeight = (_head.frame.size.height - 4) / 3;
    _identifier.frame = CGRectMake(originX, TPersonalCommonCell_Margin + 2, maxWidth, textHeight);
    _signature.frame = CGRectMake(originX, height - textHeight - TPersonalCommonCell_Margin - 2, maxWidth, textHeight);
    _nick.frame = CGRectMake(originX, (_identifier.frame.origin.y + _signature.frame.origin.y) * 0.5, maxWidth, textHeight);
}

+ (CGFloat)getHeight
{
    return TPersonalCommonCell_Image_Size.height + 2 * TPersonalCommonCell_Margin;
}
@end
