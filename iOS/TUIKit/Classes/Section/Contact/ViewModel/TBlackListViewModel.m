//
//  TBlackListViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TBlackListViewModel.h"
@import ImSDK;

@interface TBlackListViewModel()
@property NSArray<TCommonContactCellData *> *blackListData;
@property BOOL isLoadFinished;
@property BOOL isLoading;
@end

@implementation TBlackListViewModel

- (void)loadBlackList
{
    if (self.isLoading)
        return;
    self.isLoading = YES;
    self.isLoadFinished = NO;
    [[TIMFriendshipManager sharedInstance] getBlackList:^(NSArray<TIMFriend *> *friends) {
        NSMutableArray *list = @[].mutableCopy;
        for (TIMFriend *fd in friends) {
            TCommonContactCellData *data = [[TCommonContactCellData alloc] initWithFriend:fd];
            [list addObject:data];
        }
        self.blackListData = list;
        self.isLoadFinished = YES;
        self.isLoading = NO;
    } fail:^(int code, NSString *msg) {
        self.isLoading = NO;
    }];
}

@end
