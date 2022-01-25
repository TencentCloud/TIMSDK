//
//  TModifyView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIModifyView.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

#define kContainerWidth Screen_Width
#define kContainerHeight kContainerWidth * 3 / 4

@implementation TModifyViewData
- (instancetype)init {
    if (self = [super init]) {
        self.enableNull = YES;
    }
    return self;
}
@end

@interface TUIModifyView () <UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL keyboardShowing;
@property (nonatomic, strong) TModifyViewData *data;
@end

@implementation TUIModifyView
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];

    self.frame = [UIScreen mainScreen].bounds;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];

    self.backgroundColor = TUIGroupDynamicColor(@"group_modify_view_bg_color", @"#FFFFFF7F");

    _container = [[UIView alloc] initWithFrame:CGRectMake(0, Screen_Height, kContainerWidth, kContainerHeight)];
    _container.backgroundColor = TUIGroupDynamicColor(@"group_modify_container_view_bg_color", @"#FFFFFF");// [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
    _container.layer.cornerRadius = 8;
    [_container.layer setMasksToBounds:YES];
    [self addSubview:_container];


    CGFloat buttonHeight = 46;
    CGFloat titleHeight = 60;

    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _container.frame.size.width, titleHeight)];
    _title.font = [UIFont systemFontOfSize:17];
    _title.textColor = TUIGroupDynamicColor(@"group_modify_title_color", @"#000000");
    _title.textAlignment = NSTextAlignmentCenter;
    [_container addSubview:_title];
    
    _hLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_title.frame), kContainerWidth, TLine_Heigh)];
    _hLine.backgroundColor = TUICoreDynamicColor(@"separtor_color", @"#BCBCBC99");
    [_container addSubview:_hLine];
    
    CGFloat contentMargin = 20;
    CGFloat contentWidth = _container.frame.size.width - 2 * contentMargin;
    CGFloat contentY = CGRectGetMaxY(_hLine.frame) + 17;
    CGFloat contentheight = 40;
    _content = [[UITextField alloc] initWithFrame:CGRectMake(contentMargin, contentY, contentWidth, contentheight)];
    _content.delegate = self;
    _content.backgroundColor = TUIGroupDynamicColor(@"group_modify_input_bg_color", @"#F5F5F5");
    _content.textColor = TUIGroupDynamicColor(@"group_modify_input_text_color", @"#000000");
    [_content setFont:[UIFont systemFontOfSize:16]];
    [_content.layer setMasksToBounds:YES];
    [_content.layer setCornerRadius:4.0f];
    [_content setReturnKeyType:UIReturnKeyDone];
    [_content addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [_container addSubview:_content];
    
    _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(_content.frame.origin.x, CGRectGetMaxY(_content.frame) + 17, contentWidth, contentheight)];
    _descLabel.textColor = TUIGroupDynamicColor(@"group_modify_desc_color", @"#888888");
    _descLabel.font = [UIFont systemFontOfSize:13.0];
    _descLabel.numberOfLines = 0;
    _descLabel.text = @"desc";
    [_container addSubview:_descLabel];
    
    _confirm = [[UIButton alloc] initWithFrame:CGRectMake(_content.frame.origin.x, CGRectGetMaxY(_descLabel.frame) + 30, contentWidth, buttonHeight)];
    [_confirm setTitle:TUIKitLocalizableString(Confirm) forState:UIControlStateNormal];
    [_confirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _confirm.titleLabel.font = [UIFont systemFontOfSize:15];
    _confirm.layer.cornerRadius = 3;
    _confirm.layer.masksToBounds = YES;
    _confirm.imageView.contentMode = UIViewContentModeScaleToFill;
    [self enableConfirmButton:self.data.enableNull];
    [_confirm addTarget:self action:@selector(didConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [_container addSubview:_confirm];
}

- (void)setData:(TModifyViewData *)data
{
    _title.text = data.title;
    _content.text = data.content;
    _descLabel.text = data.desc;
    _data = data;
 
    CGRect rect = [data.desc boundingRectWithSize:CGSizeMake(self.content.bounds.size.width, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0]}
                                          context:nil];
    CGRect frame = _descLabel.frame;
    frame.size.height = rect.size.height;
    _descLabel.frame = frame;
    
    [self textChanged];
}

- (void)showInWindow:(UIWindow *)window
{
    [window addSubview:self];
    [self layoutIfNeeded];
    CGFloat height = CGRectGetMaxY(self.confirm.frame) + 50;

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.container.frame = CGRectMake(0, Screen_Height - height, kContainerWidth, height);
    } completion:nil];
}

- (void)onTap:(UIGestureRecognizer *)recognizer
{
    [_content resignFirstResponder];
    
    // 延时处理
    if (!self.keyboardShowing) {
        [self hide];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return [touch.view isEqual:self];
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

- (void)textChanged
{
    [self enableConfirmButton:(self.content.text.length || self.data.enableNull)];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardShowing = keyboardFrame.size.height > 0;
    [self animateContainer:keyboardFrame.size.height];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self animateContainer:0];
}

- (void)keyboardDidHide:(NSNotification *)notice
{
    self.keyboardShowing = NO;
}

- (void)animateContainer:(CGFloat)keyboardHeight
{
    CGFloat height = CGRectGetMaxY(self.confirm.frame) + 50;
    CGRect frame = _container.frame;
    frame.origin.y = Screen_Height - height - keyboardHeight; //(self.frame.size.height - keyboardHeight - frame.size.height) * 0.5;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.container.frame = frame;
    } completion:nil];
}

- (void)enableConfirmButton:(BOOL)enable
{
    if (enable) {
        _confirm.backgroundColor = TUIGroupDynamicColor(@"group_modify_confirm_enable_bg_color", @"147AFF");
        _confirm.enabled = YES;
    } else {
        _confirm.backgroundColor = [TUIGroupDynamicColor(@"group_modify_confirm_enable_bg_color", @"147AFF") colorWithAlphaComponent:0.3];
        _confirm.enabled = NO;
    }
}

@end

