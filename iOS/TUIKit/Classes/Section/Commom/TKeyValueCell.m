//
//  TTKeyValueCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TKeyValueCell.h"
#import "THeader.h"

@implementation TKeyValueCellData
@end


@implementation TKeyValueCell
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
    [self setSeparatorInset:UIEdgeInsetsMake(0, TKeyValueCell_Margin, 0, 0)];
    
    CGFloat height = [TKeyValueCell getHeight];
    
    _key = [[UILabel alloc] init];
    _key.font = [UIFont systemFontOfSize:15];
    _key.textColor = [UIColor blackColor];
    [self addSubview:_key];
    
    _value = [[UILabel alloc] init];
    _value.font = [UIFont systemFontOfSize:15];
    _value.textColor = [UIColor lightGrayColor];
    _value.textAlignment = NSTextAlignmentRight;
    [self addSubview:_value];
    
    CGSize indicatorSize = TKeyValueCell_Indicator_Size;
    _indicator = [[UIImageView alloc] initWithFrame:CGRectMake(Screen_Width - TKeyValueCell_Margin - indicatorSize.width, 0, indicatorSize.width, height)];
    _indicator.image = [UIImage imageNamed:TUIKitResource(@"right_arrow")];
    _indicator.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_indicator];
}

- (void)updateLayout:(TKeyValueCellData *)data
{
    
}


- (void)setData:(TKeyValueCellData *)data
{
    //set data
    _key.text = data.key;
    _value.text = data.value;
    //update layout
    CGFloat height = [TKeyValueCell getHeight];
    CGSize keySize = [_key sizeThatFits:CGSizeMake(Screen_Width, height)];
    _key.frame = CGRectMake(TKeyValueCell_Margin, 0, keySize.width, height);
    CGFloat valueWidth;
    if(!data.selector){
        valueWidth = Screen_Width - _key.frame.origin.x - _key.frame.size.width - 2 * TKeyValueCell_Margin;
        _indicator.hidden = YES;
    }
    else{
        valueWidth = _indicator.frame.origin.x - _key.frame.origin.x - _key.frame.size.width - 2 * TKeyValueCell_Margin;
        _indicator.hidden = NO;
    }
    _value.frame = CGRectMake(_key.frame.origin.x + _key.frame.size.width + TKeyValueCell_Margin, 0, valueWidth, height);
}

+ (CGFloat)getHeight
{
    return TKeyValueCell_Height;
}
@end
