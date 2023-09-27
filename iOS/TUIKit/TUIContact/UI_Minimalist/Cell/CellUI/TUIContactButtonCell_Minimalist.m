//
//  TUIContactButtonCell.m
//  TUIContact
//
//  Created by wyl on 2022/12/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactButtonCell_Minimalist.h"
#import <TUICore/TUIThemeManager.h>

@implementation TUIContactButtonCell_Minimalist {
    UIView *_line;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor tui_colorWithHex:@"#f9f9f9"];
    self.contentView.backgroundColor = [UIColor tui_colorWithHex:@"#f9f9f9"];

    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button.titleLabel setFont:[UIFont systemFontOfSize:16]];

    [_button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:_button];

    [self setSeparatorInset:UIEdgeInsetsMake(0, Screen_Width, 0, 0)];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.changeColorWhenTouched = YES;

    _line = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_line];
    _line.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
}

- (void)fillWithData:(TUIContactButtonCellData_Minimalist *)data {
    [super fillWithData:data];
    self.buttonData = data;
    [_button setTitle:data.title forState:UIControlStateNormal];
    if(isRTL()) {
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    else {
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    _button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    switch (data.style) {
        case ButtonGreen: {
            [_button setTitleColor:TIMCommonDynamicColor(@"form_green_button_text_color", @"#FFFFFF") forState:UIControlStateNormal];
            _button.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");
            [_button setBackgroundImage:[self imageWithColor:TIMCommonDynamicColor(@"", @"#f9f9f9")] forState:UIControlStateHighlighted];
        } break;
        case ButtonWhite: {
            [_button setTitleColor:TIMCommonDynamicColor(@"form_white_button_text_color", @"#000000") forState:UIControlStateNormal];
            _button.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");
        } break;
        case ButtonRedText: {
            [_button setTitleColor:TIMCommonDynamicColor(@"form_redtext_button_text_color", @"#FF0000") forState:UIControlStateNormal];
            _button.backgroundColor = TIMCommonDynamicColor(@"", @"#f9f9f9");

            break;
        }
        case ButtonBule: {
            [_button.titleLabel setTextColor:[UIColor tui_colorWithHex:@"147AFF"]];
            _button.backgroundColor = [UIColor tui_colorWithHex:@"#f9f9f9"];
            _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            _button.layer.cornerRadius = kScale390(10);
            _button.layer.masksToBounds = YES;
            self.backgroundColor = [UIColor clearColor];
            self.contentView.backgroundColor = [UIColor clearColor];
        } break;
        default:
            break;
    }

    if (data.textColor) {
        [_button setTitleColor:data.textColor forState:UIControlStateNormal];
    }

    _line.hidden = data.hideSeparatorLine;
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    [self.button mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(kScale390(20));
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(- kScale390(20));
        make.top.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    [_line mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(20);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(0.2);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

}

- (void)onClick:(UIButton *)sender {
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

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    if (subview != self.contentView) {
        [subview removeFromSuperview];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
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
