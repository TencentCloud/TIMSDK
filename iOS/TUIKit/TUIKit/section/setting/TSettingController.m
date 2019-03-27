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
#import "TRichMenuCell.h"
#import "THeader.h"
#import "TAlertView.h"
#import "IMMessageExt.h"
#import "TMyProfileController.h"
#import "UIView+MMLayout.h"

@interface TSettingController () <TButtonCellDelegate, TAlertViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property TRichMenuCell  *allowCell;
@property TMyProfileController *profileController;
@end

@implementation TSettingController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [[TIMFriendshipManager sharedInstance] getSelfProfile:^(TIMUserProfile *profile) {
        self.profile = profile;
        [self setupData];
        [self.tableView reloadData];
    } fail:^(int code, NSString *msg) {
        
    }];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    
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
    
    TRichMenuCellData *friendApply = [[TRichMenuCellData alloc] init];
    friendApply.valueAlignment = NSTextAlignmentRight;
    friendApply.margin = 20;
    friendApply.descColor = [UIColor blackColor];
    friendApply.valueColor = [UIColor grayColor];
    friendApply.desc = @"好友申请";
    friendApply.type = ERichCell_TextNext;
    if (self.profile.allowType == TIM_FRIEND_ALLOW_ANY) {
        friendApply.value = @"同意任何用户加好友";
    }
    if (self.profile.allowType == TIM_FRIEND_NEED_CONFIRM) {
        friendApply.value = @"需要验证";
    }
    if (self.profile.allowType == TIM_FRIEND_DENY_ANY) {
        friendApply.value = @"拒绝任何人加好友";
    }
    @m_weakify(self)
    friendApply.action = ^(TRichMenuCellData *menu, TRichMenuCell *cell) {
        @m_strongify(self)
        [self onEditFriendApply:menu cell:cell];
    };
    [_data addObject:@[friendApply]];
    
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
    else if([data isKindOfClass:[TRichMenuCellData class]]){
        return [TRichMenuCell heightOf:(TRichMenuCellData *)data];
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    SEL selector = 0;
    if ([data isKindOfClass:[TPersonalCommonCellData class]]){
        selector = ((TPersonalCommonCellData *)data).selector;
    }
    if (selector){
        [self performSelector:selector];
    }
    if  ([data isKindOfClass:[TRichMenuCellData class]]){
        [[(TRichMenuCellData *)data assignCell] doAction];;
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
    }  else if([data isKindOfClass:[TRichMenuCellData class]]) {
        TRichMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:[(TRichMenuCellData *)data reuseIndentifier]];
        if(!cell){
            cell = [[TRichMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[(TRichMenuCellData *)data reuseIndentifier]];
        }
        [cell setData:(TRichMenuCellData *)data];
        return cell;
    }
    return nil;
}

- (void)didSelectCommon
{
    self.profileController = [[TMyProfileController alloc] init];
    self.profileController.identifier = self.profile.identifier;
    self.profileController.title = @"我的资料";
    [self.navigationController pushViewController:self.profileController animated:YES];
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

- (void)onEditFriendApply:(TRichMenuCellData *)menu cell:(TRichMenuCell *)cell
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    
    [sheet addButtonWithTitle:@"同意任何用户加好友"];
    [sheet addButtonWithTitle:@"需要验证"];
    [sheet addButtonWithTitle:@"拒绝任何人加好友"];
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:@"取消"]];
    [sheet setDelegate:self];
    [sheet showInView:self.view];
    
    self.allowCell = cell;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= 3)
        return;
    
    self.profile.allowType = buttonIndex;
    TRichMenuCellData *old = self.allowCell.data;
    old.value = [actionSheet buttonTitleAtIndex:buttonIndex];
    self.allowCell.data = old;
    [[TIMFriendshipManager sharedInstance] modifySelfProfile:@{TIMProfileTypeKey_AllowType:[NSNumber numberWithInteger:self.profile.allowType]} succ:nil fail:nil];
}
@end
