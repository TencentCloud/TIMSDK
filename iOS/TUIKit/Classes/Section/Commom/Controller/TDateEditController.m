//
//  TDateEditController.m
//  KVOController
//
//  Created by annidyfeng on 2019/5/6.
//

#import "TDateEditController.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"

@interface TDateEditController ()

@end

@implementation TDateEditController

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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(onSave)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    
    self.view.backgroundColor = TSettingController_Background_Color;
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
