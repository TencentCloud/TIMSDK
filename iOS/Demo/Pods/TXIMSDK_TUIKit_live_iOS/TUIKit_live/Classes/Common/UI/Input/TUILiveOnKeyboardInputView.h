//
//  TUILiveOnKeyboardInputView.h
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUILiveOnKeyboardInputView;
typedef BOOL(^TUILiveOnKeyboardInputViewBlock)(TUILiveOnKeyboardInputView *view, NSString *text);
typedef void(^TUILiveOnKeyboardInputViewClickBlock)(TUILiveOnKeyboardInputView *view, UIButton *sender);

@interface TUILiveOnKeyboardInputView : UIView
@property(nonatomic, strong) UIButton *bulletBtn;
@property(nonatomic, strong) UITextField *msgInputFeild;
@property(nonatomic, strong) TUILiveOnKeyboardInputViewBlock textReturnBlock;
@property(nonatomic, strong) TUILiveOnKeyboardInputViewClickBlock onBullteClick;
@property(nonatomic, assign) NSInteger maxInputLenght;
@end

NS_ASSUME_NONNULL_END
