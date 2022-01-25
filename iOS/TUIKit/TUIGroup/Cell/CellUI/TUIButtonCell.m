//
//  TButtonCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIButtonCell.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

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
    self.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
    self.contentView.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");

    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];

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
            [_button setTitleColor:TUICoreDynamicColor(@"form_green_button_text_color", @"#FFFFFF") forState:UIControlStateNormal];
            _button.backgroundColor = TUICoreDynamicColor(@"form_green_button_bg_color", @"#232323");
            //对于背景色为绿色的按钮，高亮颜色比原本略深（原本的5/6）。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
            [_button setBackgroundImage:[self imageWithColor:TUICoreDynamicColor(@"form_green_button_highlight_bg_color", @"#179A1A")] forState:UIControlStateHighlighted];
        }
            break;
        case ButtonWhite: {
            [_button setTitleColor:TUICoreDynamicColor(@"form_white_button_text_color", @"#000000") forState:UIControlStateNormal];
            _button.backgroundColor = TUICoreDynamicColor(@"form_white_button_bg_color", @"#FFFFFF");
        }
            break;
        case ButtonRedText: {
            [_button setTitleColor:TUICoreDynamicColor(@"form_redtext_button_text_color", @"#FF0000") forState:UIControlStateNormal];
            _button.backgroundColor = TUICoreDynamicColor(@"form_redtext_button_bg_color", @"#FFFFFF");

            break;
        }
        case ButtonBule:{
            [_button.titleLabel setTextColor:TUICoreDynamicColor(@"form_blue_button_text_color", @"#FFFFFF")];
            _button.backgroundColor = TUICoreDynamicColor(@"form_blue_button_bg_color", @"#1E90FF");
            //对于背景色为蓝色的按钮，高亮颜色比原本略深（原本的5/6）。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
            [_button setBackgroundImage:[self imageWithColor:TUICoreDynamicColor(@"form_blue_button_highlight_bg_color", @"#1978D5")] forState:UIControlStateHighlighted];
        }
            break;
        default:
            break;
    }
    
    if (data.textColor) {
        [_button setTitleColor:data.textColor forState:UIControlStateNormal];
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
