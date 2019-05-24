//
//  TButtonCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TButtonCell.h"
#import "THeader.h"

@implementation TButtonCellData
@end

@implementation TButtonCell
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
    
    CGFloat height = [TButtonCell getHeight];
    _button = [[UIButton alloc] initWithFrame:CGRectMake(TButtonCell_Margin, 0, Screen_Width - 2 * TButtonCell_Margin, height - TButtonCell_Margin)];
    [_button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_button.titleLabel setTextColor:[UIColor redColor]];
    _button.backgroundColor = [UIColor whiteColor];
    _button.layer.cornerRadius = 5;
    [_button.layer setMasksToBounds:YES];
    [_button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
    
    [self setSeparatorInset:UIEdgeInsetsMake(0, Screen_Width, 0, 0)];
}


- (void)setData:(TButtonCellData *)data
{
    [_button setTitle:data.title forState:UIControlStateNormal];
}

+ (CGFloat)getHeight
{
    return TButtonCell_Height;
}

- (void)onClick:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(didTouchUpInsideInButtonCell:)]){
        [_delegate didTouchUpInsideInButtonCell:self];
    }
}
@end
