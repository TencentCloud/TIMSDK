//
//  TPopCell.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/14.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TPopCell.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"

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

    _image = [[UIImageView alloc] init];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_image];

    _title = [[UILabel alloc] init];
    _title.font = [UIFont systemFontOfSize:15];
    _title.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    _title.numberOfLines = 0;
    [self addSubview:_title];

    [self setSeparatorInset:UIEdgeInsetsMake(0, TPopCell_Padding, 0, 0)];
}

- (void)layoutSubviews
{
    CGFloat headHeight = TPopCell_Height - 2 * TPopCell_Padding;
    self.image.frame = CGRectMake(TPopCell_Padding, TPopCell_Padding, headHeight, headHeight);
    self.image.center = CGPointMake(self.image.center.x, self.contentView.center.y);
    
    CGFloat titleWidth = self.frame.size.width - 2 * TPopCell_Padding - TPopCell_Margin - _image.frame.size.width;
    self.title.frame = CGRectMake(_image.frame.origin.x + _image.frame.size.width + TPopCell_Margin, TPopCell_Padding, titleWidth, self.contentView.bounds.size.height);
    self.title.center = CGPointMake(self.title.center.x, self.contentView.center.y);
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
