//
//  TUILiveOnKeyboardInputView.m
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveOnKeyboardInputView.h"
#import "UIView+Additions.h"
#import "TUILiveColor.h"
#import "Masonry.h"

// 发送框
#define MSG_TEXT_SEND_VIEW_HEIGHT          45
#define MSG_TEXT_SEND_FEILD_HEIGHT         25
#define MSG_TEXT_SEND_BTN_WIDTH            35
#define MSG_TEXT_SEND_BULLET_BTN_WIDTH     55

@interface TUILiveOnKeyboardInputView ()<UITextFieldDelegate> {
}
@end

@implementation TUILiveOnKeyboardInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.maxInputLenght = 50;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [self constructViewHierarchy];
    };
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)constructViewHierarchy {
    self.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    imageView.image = [UIImage imageNamed:@"input_comment"];
    
    UIButton *bulletBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bulletBtn.frame = CGRectMake(10, (self.height - MSG_TEXT_SEND_FEILD_HEIGHT)/2, MSG_TEXT_SEND_BULLET_BTN_WIDTH, MSG_TEXT_SEND_FEILD_HEIGHT);
    [bulletBtn setImage:[UIImage imageNamed:@"live_input_switch_off"] forState:UIControlStateNormal];
    [bulletBtn setImage:[UIImage imageNamed:@"live_input_switch_on"] forState:UIControlStateSelected];
    [bulletBtn addTarget:self action:@selector(clickBullet:) forControlEvents:UIControlEventTouchUpInside];
    self.bulletBtn = bulletBtn;
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(self.width - 15 - MSG_TEXT_SEND_BTN_WIDTH, (self.height - MSG_TEXT_SEND_FEILD_HEIGHT)/2, MSG_TEXT_SEND_BTN_WIDTH, MSG_TEXT_SEND_FEILD_HEIGHT);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [sendBtn setTitleColor:UIColorFromRGB(0x0ACCAC) forState:UIControlStateNormal];
    [sendBtn setBackgroundColor:[UIColor clearColor]];
    [sendBtn addTarget:self action:@selector(clickSend) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *msgInputFeildLine1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_input_vertical_line"]];
    msgInputFeildLine1.frame = CGRectMake(bulletBtn.right + 10, sendBtn.y, 1, MSG_TEXT_SEND_FEILD_HEIGHT);
    
    UIImageView *msgInputFeildLine2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_input_vertical_line"]];
    msgInputFeildLine2.frame = CGRectMake(sendBtn.left - 10, sendBtn.y, 1, MSG_TEXT_SEND_FEILD_HEIGHT);
    
    _msgInputFeild = [[UITextField alloc] initWithFrame:CGRectMake(msgInputFeildLine1.right + 10,sendBtn.y,msgInputFeildLine2.left - msgInputFeildLine1.right - 20,MSG_TEXT_SEND_FEILD_HEIGHT)];
    _msgInputFeild.backgroundColor = [UIColor clearColor];
    _msgInputFeild.returnKeyType = UIReturnKeySend;
    _msgInputFeild.placeholder = @"和大家说点什么吧";
    _msgInputFeild.delegate = self;
    _msgInputFeild.textColor = [UIColor blackColor];
    _msgInputFeild.font = [UIFont systemFontOfSize:14];
    [_msgInputFeild addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self addSubview:imageView];
    [self addSubview:_msgInputFeild];
    [self addSubview:bulletBtn];
    [self addSubview:sendBtn];
    [self addSubview:msgInputFeildLine1];
    [self addSubview:msgInputFeildLine2];
    self.hidden = YES;
}

//监听键盘高度变化
- (void)keyboardFrameDidChange:(NSNotification *)notice {
    if (!self.superview) {
        return;
    }
    [self.superview bringSubviewToFront:self];
    NSDictionary * userInfo = notice.userInfo;
    NSValue * endFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = endFrameValue.CGRectValue;
    BOOL shouldHidden = CGRectGetMinY(endFrame) >= [UIScreen mainScreen].bounds.size.height;
    if (!shouldHidden) {
        self.hidden = NO;
    }
    endFrame = [self.superview convertRect:endFrame fromView:nil];
    [UIView animateWithDuration:0.25 animations:^{
        if (shouldHidden) {
            self.y = endFrame.origin.y;
        }else{
            self.y =  endFrame.origin.y - self.height;
        }
    } completion:^(BOOL finished) {
        if (shouldHidden) {
            self.hidden = YES;
        }
    }];
}

#pragma mark - actions
- (void)clickSend {
     [self textFieldShouldReturn:_msgInputFeild];
}

- (void)clickBullet:(UIButton *)btn {
    self.bulletBtn.selected = !self.bulletBtn.selected;
    if (self.onBullteClick) {
        self.onBullteClick(self, btn);
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _msgInputFeild.text = @"";
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _msgInputFeild.text = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *textMsg = [textField.text stringByTrimmingCharactersInSet:[NSMutableCharacterSet whitespaceCharacterSet]];
    [_msgInputFeild resignFirstResponder];
    if ([textMsg length] == 0) {
        textField.text = @"";
    }
    if (self.textReturnBlock) {
        return self.textReturnBlock(self, textMsg);
    }
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if(textField == self.msgInputFeild){
        NSInteger kMaxLength = 10;
        NSString *toBeString = textField.text;
        NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage; //ios7之前使用[UITextInputMode currentInputMode].primaryLanguage
        if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
            UITextRange *selectedRange = [textField markedTextRange];
            //获取高亮部分
            UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
            if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
                if (toBeString.length > self.maxInputLenght) {
                    textField.text = [toBeString substringToIndex:kMaxLength];
                }
            }
            else{//有高亮选择的字符串，则暂不对文字进行统计和限制
                
            }
        } else {//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
            if (toBeString.length > self.maxInputLenght) {
                textField.text = [toBeString substringToIndex:self.maxInputLenght];
            }
        }
    }
}

@end
