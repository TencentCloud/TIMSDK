//
//  TPopCell.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/14.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TPopCell.h"
#import "THeader.h"

@implementation TPopCellData
@end

@implementation TPopCell

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
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat headHeight = TPopCell_Height - 2 * TPopCell_Padding;
    _image = [[UIImageView alloc] initWithFrame:CGRectMake(TPopCell_Padding, TPopCell_Padding, headHeight, headHeight)];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_image];
    
    CGFloat titleWidth = self.frame.size.width - 2 * TPopCell_Padding - TPopCell_Margin - _image.frame.size.width;
    _title = [[UILabel alloc] initWithFrame:CGRectMake(_image.frame.origin.x + _image.frame.size.width + TPopCell_Margin, TPopCell_Padding, titleWidth, headHeight)];
    _title.font = [UIFont systemFontOfSize:15];
    _title.textColor = [UIColor blackColor];
    [self addSubview:_title];
    
    [self setSeparatorInset:UIEdgeInsetsMake(0, TPopCell_Padding, 0, 0)];
}

- (void)setData:(TPopCellData *)data
{
    _image.image = [UIImage imageNamed:data.image];
    _title.text = data.title;
}

+ (CGFloat)getHeight
{
    return TPopCell_Height;
}
@end
