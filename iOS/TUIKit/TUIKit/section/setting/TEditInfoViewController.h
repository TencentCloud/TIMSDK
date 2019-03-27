//
//  EditInfoViewController.h
//  TIMChat
//
//  Created by AlexiChen on 16/3/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TEditInfoViewController;
typedef void (^TEditInfoCompletionBlock)(TEditInfoViewController *sender, BOOL isFinished);

@interface TEditInfoViewController : UIViewController
{

}

@property (nonatomic, copy) TEditInfoCompletionBlock completion;

- (instancetype)initWithText:(NSString *)text;

@property UITextField *inputTextField;
@property NSString *origText;

@end


