//
//  LiveListViewController.m
//  TUILiveKit
//
//  Created by coddyliu on 2020/9/2.
//  Copyright © 2020 null. All rights reserved.
//

#import "LiveRoomListViewController.h"

@interface LiveRoomListViewController ()
@property(nonatomic, strong) NSArray *roomList;
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation LiveRoomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak typeof(self) weakSelf = self;
    [self.delegate loadLiveRoomList:^(NSArray * _Nonnull roomList, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.roomList = roomList;
            [weakSelf.tableView reloadData];
        });
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
