//
//  EditInfoViewController.m
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019 annidyfeng. All rights reserved.
//

#import "TUITextEditController.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

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

@interface TUITextEditController ()

@end

@implementation TUITextEditController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TIMCommonLocalizableString(Save)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onSave)];
    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");

    _inputTextField = [[TTextField alloc] initWithFrame:CGRectZero];
    _inputTextField.text = [self.textValue stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
    [(TTextField *)_inputTextField setMargin:10];
    _inputTextField.backgroundColor = TIMCommonDynamicColor(@"search_textfield_bg_color", @"#FEFEFE");
    _inputTextField.frame = CGRectMake(0, 10, self.view.frame.size.width, 40);
    _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_inputTextField];
}

- (void)onSave {
    self.textValue = [self.inputTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
