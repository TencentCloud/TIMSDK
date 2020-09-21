//
//  TTextEditController.h
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 annidyfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTextEditController;

@interface TTextEditController : UIViewController
@property UITextField *inputTextField;
@property NSString *textValue;

- (instancetype)initWithText:(NSString *)text;

@end


