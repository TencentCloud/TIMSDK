//
//  TSettingController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/26.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TSettingController.h"
#import "TPersonalCommonCell.h"
#import "TKeyValueCell.h"
#import "TButtonCell.h"
#import "THeader.h"
#import "TAlertView.h"
#import "IMMessageExt.h"

@interface TSettingController () <TButtonCellDelegate, TAlertViewDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation TSettingController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self setupData];
}

- (void)setupViews
{
    self.title = @"设置";
    self.parentViewController.title = @"设置";
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = TSettingController_Background_Color;
}

- (void)setupData
{
    _data = [NSMutableArray array];
    
    TPersonalCommonCellData *personal = [[TPersonalCommonCellData alloc] init];
    personal.identifier = [[TIMManager sharedInstance] getLoginUser];
    personal.head = TUIKitResource(@"default_head");
    personal.selector = @selector(didSelectCommon);
    [_data addObject:@[personal]];
    
    TButtonCellData *button =  [[TButtonCellData alloc] init];
    button.title = @"退 出";
    [_data addObject:@[button]];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _data.count;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TPersonalCommonCellData class]]){
        return [TPersonalCommonCell getHeight];
    }
    else if([data isKindOfClass:[TButtonCellData class]]){
        return [TButtonCell getHeight];
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    SEL selector;
    if([data isKindOfClass:[TPersonalCommonCellData class]]){
        selector = ((TPersonalCommonCellData *)data).selector;
    }
    if(selector){
        [self performSelector:selector];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TPersonalCommonCellData class]]){
        TPersonalCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:TPersonalCommonCell_ReuseId];
        if(!cell){
            cell = [[TPersonalCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TPersonalCommonCell_ReuseId];
        }
        [cell setData:(TPersonalCommonCellData *)data];
        return cell;
    }
    else if([data isKindOfClass:[TButtonCellData class]]){
        TButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:TButtonCell_ReuseId];
        if(!cell){
            cell = [[TButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TButtonCell_ReuseId];
            cell.delegate = self;
        }
        [cell setData:(TButtonCellData *)data];
        return cell;
    }
    return nil;
}

- (void)didSelectCommon
{
    
}

- (void)didTouchUpInsideInButtonCell:(TButtonCell *)cell
{
    TAlertView *alert = [[TAlertView alloc] initWithTitle:@"确定退出吗"];
    alert.delegate = self;
    [alert showInWindow:self.view.window];
}

- (void)didConfirmInAlertView:(TAlertView *)alertView
{
    __weak typeof(self) ws = self;
    [[TIMManager sharedInstance] logout:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ws.delegate && [ws.delegate respondsToSelector:@selector(didLogoutInSettingController:)]){
                [ws.delegate didLogoutInSettingController:self];
            }
        });
    } fail:^(int code, NSString *msg) {
        NSLog(@"");
    }];
}

@end
