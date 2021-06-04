//
//  TUIGroupPendencyController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/18.
//

#import "TUIGroupPendencyController.h"
#import "TUIGroupPendencyCell.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "Toast/Toast.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "NSBundle+TUIKIT.h"
#import "THeader.h"

@interface TUIGroupPendencyController ()

@end

@implementation TUIGroupPendencyController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[TUIGroupPendencyCell class] forCellReuseIdentifier:@"PendencyCell"];

    self.tableView.tableFooterView = [UIView new];

    self.title = TUILocalizableString(TUIKitGroupApplicant);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIGroupPendencyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PendencyCell" forIndexPath:indexPath];
    TUIGroupPendencyCellData *data = self.viewModel.dataList[indexPath.row];
    data.cselector = @selector(cellClick:);
    data.cbuttonSelector = @selector(btnClick:);
    [cell fillWithData:data];

    return cell;
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [self.tableView beginUpdates];
        TUIGroupPendencyCellData *data = self.viewModel.dataList[indexPath.row];
        [self.viewModel removeData:data];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)btnClick:(TUIGroupPendencyCell *)cell
{
    [self.viewModel acceptData:cell.pendencyData];
    [self.tableView reloadData];
}

- (void)cellClick:(TUIGroupPendencyCell *)cell
{
    id<TUIUserProfileControllerServiceProtocol> controller = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
    if ([controller isKindOfClass:[UIViewController class]]) {
        [[V2TIMManager sharedInstance] getUsersInfo:@[cell.pendencyData.fromUser] succ:^(NSArray<V2TIMUserFullInfo *> *profiles) {
            controller.userFullInfo = profiles.firstObject;
            controller.groupPendency = cell.pendencyData;
            controller.actionType = PCA_GROUP_CONFIRM;
            [self.navigationController pushViewController:(UIViewController *)controller animated:YES];
        } fail:nil];
    }
}

@end
