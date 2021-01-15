//
//  TUIBlackListController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TUIBlackListController.h"
#import "ReactiveObjC.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"
#import "NSBundle+TUIKIT.h"

@import ImSDK;

@interface TUIBlackListController ()

@end

@implementation TUIBlackListController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    self.title = TUILocalizableString(TUIKitContactsBlackList); // @"黑名单";
    self.tableView.delaysContentTouches = NO;

    if (!self.viewModel) {
        self.viewModel = TUIBlackListViewModel.new;
        @weakify(self)
        [RACObserve(self.viewModel, isLoadFinished) subscribeNext:^(id finished) {
            @strongify(self)
            if ([(NSNumber *)finished boolValue])
                [self.tableView reloadData];
        }];
        [self.viewModel loadBlackList];
    }

    [self.tableView registerClass:[TCommonContactCell class] forCellReuseIdentifier:@"FriendCell"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = self.view.backgroundColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBlackListChanged:) name:TUIKitNotification_onBlackListAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBlackListChanged:) name:TUIKitNotification_onBlackListDeleted object:nil];
}

- (void)onBlackListChanged:(NSNotification *)no {
    [self.viewModel loadBlackList];
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
    TCommonContactCellData *data = self.viewModel.blackListData[indexPath.row];
    data.cselector = @selector(didSelectBlackList:);
    [cell fillWithData:data];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCommonContactCellData *data = self.viewModel.blackListData[indexPath.row];

    id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
    if ([vc isKindOfClass:[UIViewController class]]) {
        vc.friendProfile = data.friendProfile;
        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    }
}
 */

-(void)didSelectBlackList:(TCommonContactCell *)cell
{
    TCommonContactCellData *data = cell.contactData;

    id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
    if ([vc isKindOfClass:[UIViewController class]]) {
        vc.friendProfile = data.friendProfile;
        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    }
}

@end
