//
//  TAlertView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TAlertView.h"
#import "THeader.h"

@interface TAlertView ()
@end

@implementation TAlertView

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if(self){
        [self setupViews];
        _titleLabel.text = title;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setupViews
{
    self.frame = [UIScreen mainScreen].bounds;
    
    self.backgroundColor = TAlertView_Background_Color;
    
    CGFloat containerWidth = Screen_Width * 2 / 3;
    CGFloat containerHeight = containerWidth / 2;
    _container = [[UIView alloc] initWithFrame:CGRectMake((Screen_Width - containerWidth) * 0.5, (Screen_Height - containerHeight) * 0.5, containerWidth, containerHeight)];
    _container.backgroundColor = [UIColor whiteColor];
    _container.layer.cornerRadius = 8;
    [_container.layer setMasksToBounds:YES];
    [self addSubview:_container];
    
    
    CGFloat buttonHeight = 50;
    CGFloat buttonWidth = (containerWidth - TAlertView_Line_Height_Width) * 0.5;
    
    _cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, containerHeight - buttonHeight, buttonWidth, buttonHeight)];
    [_cancel setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _cancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [_cancel addTarget:self action:@selector(didCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_container addSubview:_cancel];
    
    _hLine = [[UIView alloc] initWithFrame:CGRectMake(0, _cancel.frame.origin.y - TAlertView_Line_Height_Width, _container.frame.size.width, TAlertView_Line_Height_Width)];
    _hLine.backgroundColor = TAlertView_Line_Color;
    [_container addSubview:_hLine];
    
    _vLine = [[UIView alloc] initWithFrame:CGRectMake(_cancel.frame.origin.x + _cancel.frame.size.width, _cancel.frame.origin.y, TAlertView_Line_Height_Width, _cancel.frame.size.height)];
    _vLine.backgroundColor = TAlertView_Line_Color;
    [_container addSubview:_vLine];
    
    _confirm = [[UIButton alloc] initWithFrame:CGRectMake(_vLine.frame.origin.x + _vLine.frame.size.width, _cancel.frame.origin.y, buttonWidth, buttonHeight)];
    [_confirm setTitle:@"确定" forState:UIControlStateNormal];
    [_confirm setTitleColor:TAlertView_Confirm_Color forState:UIControlStateNormal];
    _confirm.titleLabel.font = [UIFont systemFontOfSize:15];
    [_confirm addTarget:self action:@selector(didConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [_container addSubview:_confirm];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _container.frame.size.width, _hLine.frame.origin.y)];
    _titleLabel.font = [UIFont systemFontOfSize:17];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_container addSubview:_titleLabel];
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
    if(_delegate && [_delegate respondsToSelector:@selector(didCancelInAlertView:)]){
        [_delegate didCancelInAlertView:self];
    }
    [self hide];
}

- (void)didConfirm:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(didConfirmInAlertView:)]){
        [_delegate didConfirmInAlertView:self];
    }
    [self hide];
}
@end
