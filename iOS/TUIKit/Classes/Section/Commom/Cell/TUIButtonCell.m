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
#import "UIColor+TUIDarkMode.h"

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
        self.changeColorWhenTouched = YES;
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
    self.changeColorWhenTouched = YES;
}


- (void)fillWithData:(TUIButtonCellData *)data
{
    [super fillWithData:data];
    self.buttonData = data;
    [_button setTitle:data.title forState:UIControlStateNormal];
    switch (data.style) {
        case ButtonGreen: {
            [_button.titleLabel setTextColor:[UIColor d_colorWithColorLight:[UIColor whiteColor] dark:RGB(180, 180, 180)]];
            [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _button.backgroundColor = [UIColor d_colorWithColorLight:RGB(28, 185, 31) dark:RGB(35, 35, 35)];
            //对于背景色为绿色的按钮，高亮颜色比原本略深（原本的5/6）。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
            [_button setBackgroundImage:[self imageWithColor:[UIColor d_colorWithColorLight:RGB(23, 154, 26) dark:RGB(47, 47, 47)]] forState:UIControlStateHighlighted];
        }
            break;
        case ButtonWhite: {
            [_button.titleLabel setTextColor:[UIColor blackColor]];
            [_button setTitleColor:[UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark] forState:UIControlStateNormal];
            _button.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
            //对于原本白色背景色的按钮，高亮颜色保持和白色 cell 统一。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
            [_button setBackgroundImage:[self imageWithColor:self.colorWhenTouched] forState:UIControlStateHighlighted];
        }
            break;
        case ButtonRedText: {
            [_button.titleLabel setTextColor:[UIColor systemRedColor]];
            [_button setTitleColor:[UIColor d_systemRedColor] forState:UIControlStateNormal];
            _button.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
            //对于原本白色背景色的按钮，高亮颜色保持和白色 cell 统一。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
            [_button setBackgroundImage:[self imageWithColor:self.colorWhenTouched] forState:UIControlStateHighlighted];

            break;
        }
        case ButtonBule:{
            [_button.titleLabel setTextColor:[UIColor d_colorWithColorLight:[UIColor whiteColor] dark:RGB(180, 180, 180)]];
            _button.backgroundColor = [UIColor d_colorWithColorLight:RGB(30, 144, 255) dark:RGB(35, 35, 35)];
            //对于背景色为蓝色的按钮，高亮颜色比原本略深（原本的5/6）。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
            [_button setBackgroundImage:[self imageWithColor:[UIColor d_colorWithColorLight:RGB(25, 120, 213) dark:RGB(47, 47, 47)]] forState:UIControlStateHighlighted];
        }
            break;
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

//本函数实现了生成纯色背景的功能，从而配合 setBackgroundImage: forState: 来实现高亮时纯色按钮的点击反馈。
- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}




@end
