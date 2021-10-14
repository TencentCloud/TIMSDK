//
//  TDateEditController.m
//  KVOController
//
//  Created by annidyfeng on 2019/5/6.
//

#import "TUIDateEditController.h"
#import "TUIDefine.h"

@interface TUIDateEditController ()

@end

@implementation TUIDateEditController

- (instancetype)initWithDate:(NSDate *)date
{
    if (self = [super init]) {
        _dateValue = date;
        if (_dateValue == nil)
            _dateValue = [NSDate date];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TUIKitLocalizableString(Save)  style:UIBarButtonItemStylePlain target:self action:@selector(onSave)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TUIKitLocalizableString(Cancel) style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];

    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.datePicker];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.date = _dateValue;

    self.datePicker.mm_width(self.view.mm_w).mm_height(self.view.mm_h/2).mm_top(10);
}


- (void)onSave
{
    self.dateValue = self.datePicker.date;

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
