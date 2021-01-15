//
//  EditInfoViewController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 annidyfeng. All rights reserved.
//

#import "TTextEditController.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"
#import "NSBundle+TUIKIT.h"

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

// MLeaksFinder 会对这个类误报，这里需要关闭一下

- (BOOL)willDealloc {
    return NO;
}

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TUILocalizableString(Save) style:UIBarButtonItemStylePlain target:self action:@selector(onSave)];
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];

    _inputTextField = [[TTextField alloc] initWithFrame:CGRectZero];
    _inputTextField.text = [self.textValue stringByTrimmingCharactersInSet:
                                           [NSCharacterSet illegalCharacterSet]];
    [(TTextField *)_inputTextField setMargin:10];
    _inputTextField.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
    _inputTextField.frame = CGRectMake(0, 10, self.view.frame.size.width, 40);
    _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_inputTextField];
}


- (void)onSave
{
    self.textValue = [self.inputTextField.text stringByTrimmingCharactersInSet:
                      [NSCharacterSet illegalCharacterSet]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
