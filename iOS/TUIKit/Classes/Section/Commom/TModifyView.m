//
//  TModifyView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TModifyView.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"
#import "NSBundle+TUIKIT.h"

@implementation TModifyViewData
@end

@interface TModifyView () <UITextViewDelegate>
@end

@implementation TModifyView
- (id)init
{
    self = [super init];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];

    self.frame = [UIScreen mainScreen].bounds;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tap];

    self.backgroundColor = [UIColor d_colorWithColorLight:TModifyView_Background_Color dark:TModifyView_Background_Color_Dark];

    CGFloat containerWidth = Screen_Width * 2 / 3;
    CGFloat containerHeight = containerWidth * 3 / 4;
    _container = [[UIView alloc] initWithFrame:CGRectMake((Screen_Width - containerWidth) * 0.5, (Screen_Height - containerHeight) * 0.5, containerWidth, containerHeight)];
    _container.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
    _container.layer.cornerRadius = 8;
    [_container.layer setMasksToBounds:YES];
    [self addSubview:_container];


    CGFloat buttonHeight = 50;
    CGFloat buttonWidth = (containerWidth - TLine_Heigh) * 0.5;
    CGFloat titleHeight = 60;

    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _container.frame.size.width, titleHeight)];
    _title.font = [UIFont systemFontOfSize:17];
    _title.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    _title.textAlignment = NSTextAlignmentCenter;
    [_container addSubview:_title];

    _cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, containerHeight - buttonHeight, buttonWidth, buttonHeight)];
    [_cancel setTitle:TUILocalizableString(Cancel) forState:UIControlStateNormal];
    [_cancel setTitleColor:[UIColor d_systemRedColor] forState:UIControlStateNormal];
    _cancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [_cancel addTarget:self action:@selector(didCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_container addSubview:_cancel];

    _hLine = [[UIView alloc] initWithFrame:CGRectMake(0, _cancel.frame.origin.y - TLine_Heigh, _container.frame.size.width, TLine_Heigh)];
    _hLine.backgroundColor = [UIColor d_colorWithColorLight:TLine_Color dark:TLine_Color_Dark];
    [_container addSubview:_hLine];

    _vLine = [[UIView alloc] initWithFrame:CGRectMake(_cancel.frame.origin.x + _cancel.frame.size.width, _cancel.frame.origin.y, TLine_Heigh, _cancel.frame.size.height)];
    _vLine.backgroundColor = [UIColor d_colorWithColorLight:TLine_Color dark:TLine_Color_Dark];
    [_container addSubview:_vLine];

    _confirm = [[UIButton alloc] initWithFrame:CGRectMake(_vLine.frame.origin.x + _vLine.frame.size.width, _cancel.frame.origin.y, buttonWidth, buttonHeight)];
    [_confirm setTitle:TUILocalizableString(Confirm) forState:UIControlStateNormal];
    [_confirm setTitleColor:[UIColor d_systemBlueColor] forState:UIControlStateNormal];
    _confirm.titleLabel.font = [UIFont systemFontOfSize:15];
    [_confirm addTarget:self action:@selector(didConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [_container addSubview:_confirm];

    CGFloat contentMargin = 20;
    CGFloat contentWidth = _container.frame.size.width - 2 * contentMargin;
    CGFloat contentY = _title.frame.origin.y + _title.frame.size.height;
    CGFloat contentheight = _hLine.frame.origin.y - contentY - contentMargin;
    _content = [[UITextView alloc] initWithFrame:CGRectMake(contentMargin, contentY, contentWidth, contentheight)];
    _content.delegate = self;
    [_content setFont:[UIFont systemFontOfSize:16]];
    [_content.layer setMasksToBounds:YES];
    [_content.layer setCornerRadius:4.0f];
    [_content.layer setBorderWidth:0.5f];
    [_content.layer setBorderColor:[UIColor d_colorWithColorLight:TLine_Color dark:TLine_Color_Dark].CGColor];
    [_content setReturnKeyType:UIReturnKeyDone];
    [_container addSubview:_content];
}


- (void)setData:(TModifyViewData *)data
{
    _title.text = data.title;
    _content.text = data.content;
}

- (void)showInWindow:(UIWindow *)window
{
    [window addSubview:self];

    __weak typeof(self) ws = self;
    self.alpha = 0;;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.alpha = 1;
    } completion:nil];
}

- (void)onTap:(UIGestureRecognizer *)recognizer
{
    [_content resignFirstResponder];
}


- (void)hide
{
    __weak typeof(self) ws = self;
    self.alpha = 1;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.alpha = 0;
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] removeObserver:ws];
        if([ws superview]){
            [ws removeFromSuperview];
        }
    }];
}

- (void)didCancel:(UIButton *)sender
{
    [self hide];
}

- (void)didConfirm:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(modifyView:didModiyContent:)]){
        [_delegate modifyView:self didModiyContent:_content.text];
    }
    [self hide];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self animateContainer:keyboardFrame.size.height];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self animateContainer:0];
}

- (void)animateContainer:(CGFloat)keyboardHeight
{
    CGRect frame = _container.frame;
    frame.origin.y = (self.frame.size.height - keyboardHeight - frame.size.height) * 0.5;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.container.frame = frame;
    } completion:nil];
}
@end

