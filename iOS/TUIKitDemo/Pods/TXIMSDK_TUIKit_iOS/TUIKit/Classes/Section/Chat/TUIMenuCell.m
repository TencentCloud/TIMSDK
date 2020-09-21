//
//  InputMenuCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIMenuCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "UIColor+TUIDarkMode.h"

@implementation TMenuCellData
@end

@implementation TUIMenuCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor d_colorWithColorLight:TMenuCell_Background_Color dark:TMenuCell_Background_Color_Dark];
    _menu = [[UIImageView alloc] init];
    _menu.backgroundColor = [UIColor clearColor];
    [self addSubview:_menu];
}

- (void)defaultLayout
{
}

- (void)setData:(TMenuCellData *)data
{
    //set data
    _menu.image = [[TUIImageCache sharedInstance] getFaceFromCache:data.path];
    if(data.isSelected){
        self.backgroundColor = [UIColor d_colorWithColorLight:TMenuCell_Selected_Background_Color dark:TMenuCell_Selected_Background_Color_Dark];
    }
    else{
        self.backgroundColor = [UIColor d_colorWithColorLight:TMenuCell_Background_Color dark:TMenuCell_Background_Color_Dark];
    }
    //update layout
    CGSize size = self.frame.size;
    _menu.frame = CGRectMake(TMenuCell_Margin, TMenuCell_Margin, size.width - 2 * TMenuCell_Margin, size.height - 2 * TMenuCell_Margin);
    _menu.contentMode = UIViewContentModeScaleAspectFit;

}
@end
