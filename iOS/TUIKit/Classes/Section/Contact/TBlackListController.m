//
//  TBlackListController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TBlackListController.h"
#import "ReactiveObjC.h"
#import "TFriendProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
@import ImSDK;

@interface TBlackListController ()

@end

@implementation TBlackListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (!self.viewModel) {
        self.viewModel = TBlackListViewModel.new;
        [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(id finished) {
            if ([(NSNumber *)finished boolValue])
                [self.tableView reloadData];
        }];
        [self.viewModel loadBlackList];
    }
    
    [self.tableView registerClass:[TCommonContactCell class] forCellReuseIdentifier:@"FriendCell"];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.blackListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCommonContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    [cell fillWithData:self.viewModel.blackListData[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCommonContactCellData *data = self.viewModel.blackListData[indexPath.row];
    
    id<TFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TFriendProfileControllerServiceProtocol)];
    if ([vc isKindOfClass:[UIViewController class]]) {
        vc.friendProfile = data.friendProfile;
        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    }
}


@end
