//
//  TPickView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TPickView.h"
#import "THeader.h"

@interface TPickView ()<UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation TPickView
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
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = TPickView_Background_Color;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    
    
    CGFloat height = self.frame.size.height / 3;
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - height, self.frame.size.width, height)];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    
    CGSize buttonSize = TPickView_Button_Size;
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(TPickView_Margin, TPickView_Margin, buttonSize.width, buttonSize.height)];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_cancelButton];
    
    _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - TPickView_Margin - buttonSize.width, TPickView_Margin, buttonSize.width, buttonSize.height)];
    [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    _confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_confirmButton setTitleColor:TPickView_Confirm_Color forState:UIControlStateNormal];
    [_confirmButton addTarget:self action:@selector(onConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_confirmButton];
    
    _line = [[UIView alloc] initWithFrame:CGRectMake(0, _confirmButton.frame.origin.y + _confirmButton.frame.size.height + TPickView_Margin, self.frame.size.width, TPickView_Line_Height)];
    _line.backgroundColor = TPickView_Line_Color;
    [_contentView addSubview:_line];

    CGFloat originY = _line.frame.origin.y + _line.frame.size.height + TPickView_Margin;
    _pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, originY, self.frame.size.width, _contentView.frame.size.height - originY - TPickView_Margin)];
    _pickView.delegate = self;
    _pickView.dataSource = self;
    _pickView.showsSelectionIndicator = YES;
    [_contentView addSubview:_pickView];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _data.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedIndex = row;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _data[row];
}

- (void)setData:(NSMutableArray *)data
{
    _data = data;
    [_pickView reloadAllComponents];
}

- (void)showInWindow:(UIWindow *)window
{
    [window addSubview:self];
    CGRect frame = _contentView.frame;
    CGRect newFrame = frame;
    frame.origin.y = self.frame.size.height;
    _contentView.frame = frame;
    __weak typeof(self) ws = self;
    ws.alpha = 0;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.alpha = 1;
        ws.contentView.frame = newFrame;
    } completion:nil];
}

- (void)onTap:(UIGestureRecognizer *)recognizer
{
    [self hide];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view == _contentView){
        return NO;
    }
    return YES;
}

- (void)onCancel:(UIButton *)sender
{
    [self hide];
}

- (void)onConfirm:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(pickView:didSelectRowAtIndex:)]){
        [_delegate pickView:self didSelectRowAtIndex:_selectedIndex];
    }
    [self hide];
}

- (void)hide
{
    CGRect frame = _contentView.frame;
    frame.origin.y = self.frame.size.height;
    __weak typeof(self) ws = self;
    
    self.alpha = 1;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.alpha = 0;
        ws.contentView.frame = frame;
    } completion:^(BOOL finished) {
        if([ws superview]){
            [ws removeFromSuperview];
        }
    }];
}
@end
