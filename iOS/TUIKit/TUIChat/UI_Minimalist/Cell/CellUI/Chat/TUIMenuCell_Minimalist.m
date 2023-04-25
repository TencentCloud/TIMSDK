//
//  InputMenuCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIMenuCell_Minimalist.h"
#import <TUICore/TUIThemeManager.h>
#import <TIMCommon/TIMDefine.h>

@implementation TUIMenuCell_Minimalist
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
    self.backgroundColor = [UIColor whiteColor];
    _menu = [[UIImageView alloc] init];
    _menu.backgroundColor = [UIColor clearColor];
    [self addSubview:_menu];
}

- (void)defaultLayout
{
}

- (void)setData:(TUIMenuCellData_Minimalist *)data
{
    //set data
    _menu.image = [[TUIImageCache sharedInstance] getFaceFromCache:data.path];
    if(data.isSelected){
        _menu.layer.borderWidth = 1;
        _menu.layer.borderColor = RGBA(20, 122, 255, 1).CGColor;
    }
    else{
        _menu.layer.borderWidth = 0;
    }
    //update layout
    CGSize size = self.frame.size;
    _menu.frame = CGRectMake(TMenuCell_Margin, TMenuCell_Margin, size.width - 2 * TMenuCell_Margin, size.height - 2 * TMenuCell_Margin);
    _menu.contentMode = UIViewContentModeScaleAspectFit;

}
@end
