//
//  EditInfoViewController.m
//  TIMChat
//
//  Created by AlexiChen on 16/3/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TEditInfoViewController.h"
#import "THeader.h"
#import "UIView+MMLayout.h"

typedef enum : NSUInteger {
    TEditInfo_Text1,
} TEditInfoType;

@interface TEditInfoViewController ()
@property TEditInfoType infoType;
@end

@implementation TEditInfoViewController

- (instancetype)initWithText:(NSString *)text;
{
    if (self = [super init]) {
        _infoType = TEditInfo_Text1;
        _origText = text;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(onSave)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    
    self.view.backgroundColor = TSettingController_Background_Color;
    
    switch (self.infoType) {
        case TEditInfo_Text1:
            _inputTextField = [[UITextField alloc] initWithFrame:CGRectZero];
            _inputTextField.text = self.origText;
            _inputTextField.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:_inputTextField];
            _inputTextField.m_top(80).m_height(40).m_flexToRight(0);
            break;
            
        default:
            break;
    }
}


- (void)onSave
{
    if (_completion)
    {
        _completion(self, YES);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onCancel
{
    if (_completion)
    {
        _completion(self, NO);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
