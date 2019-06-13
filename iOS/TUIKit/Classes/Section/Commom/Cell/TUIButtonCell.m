//
//  TButtonCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIButtonCell.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"

@implementation TUIButtonCellData

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return TButtonCell_Height;
}
@end

@implementation TUIButtonCell
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
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    _button.layer.cornerRadius = 5;
    [_button.layer setMasksToBounds:YES];
    [_button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    _button.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.3].CGColor;
    _button.layer.borderWidth = 1;
    [self.contentView addSubview:_button];
    
    [self setSeparatorInset:UIEdgeInsetsMake(0, Screen_Width, 0, 0)];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}


- (void)fillWithData:(TUIButtonCellData *)data
{
    [super fillWithData:data];
    self.buttonData = data;
    [_button setTitle:data.title forState:UIControlStateNormal];


    
    switch (data.style) {
        case ButtonGreen: {
            [_button.titleLabel setTextColor:[UIColor whiteColor]];
            [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _button.backgroundColor = RGB(28, 185, 31);
        }
            break;
        case ButtonWhite: {
            [_button.titleLabel setTextColor:[UIColor blackColor]];
            [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _button.backgroundColor = [UIColor whiteColor];
        }
            break;
        case ButtonRedText: {
            [_button.titleLabel setTextColor:[UIColor redColor]];
            [_button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            _button.backgroundColor = [UIColor whiteColor];
            break;
        }
        default:
            break;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _button.mm_width(Screen_Width - 2 * TButtonCell_Margin)
    .mm_height(self.mm_h - TButtonCell_Margin)
    .mm_left(TButtonCell_Margin);
}

- (void)onClick:(UIButton *)sender
{
    if (self.buttonData.cbuttonSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.buttonData.cbuttonSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.buttonData.cbuttonSelector withObject:self];
#pragma clang diagnostic pop
        }
    }
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    if (subview != self.contentView) {
        [subview removeFromSuperview];
    }
}
@end
