//
//  EditInfoViewController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 annidyfeng. All rights reserved.
//

#import "TTextEditController.h"
#import "THeader.h"

@interface TTextField : UITextField
@property int margin;
@end


@implementation TTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    int margin = self.margin;
    CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y, bounds.size.width - margin, bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    int margin = self.margin;
    CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y, bounds.size.width - margin, bounds.size.height);
    return inset;
}

@end

@interface TTextEditController ()

@end

@implementation TTextEditController

- (instancetype)initWithText:(NSString *)text;
{
    if (self = [super init]) {
        _textValue = text;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(onSave)];
    
    self.view.backgroundColor = TSettingController_Background_Color;
    

    _inputTextField = [[TTextField alloc] initWithFrame:CGRectZero];
    _inputTextField.text = [self.textValue stringByTrimmingCharactersInSet:
                                           [NSCharacterSet illegalCharacterSet]];
    [(TTextField *)_inputTextField setMargin:10];
    _inputTextField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_inputTextField];
    _inputTextField.frame = CGRectMake(0, 10, self.view.frame.size.width, 40);
    _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
}


- (void)onSave
{
    self.textValue = [self.inputTextField.text stringByTrimmingCharactersInSet:
                      [NSCharacterSet illegalCharacterSet]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
