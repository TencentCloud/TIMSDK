//
//  TUIBlackListViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TUIBlackListViewDataProvider.h"
#import <TIMCommon/TIMDefine.h>

@interface TUIBlackListViewDataProvider()
@property NSArray<TUICommonContactCellData *> *blackListData;
@property BOOL isLoadFinished;
@property BOOL isLoading;
@end

@implementation TUIBlackListViewDataProvider

- (void)loadBlackList
{
    if (self.isLoading)
        return;
    self.isLoading = YES;
    self.isLoadFinished = NO;
    @weakify(self)
    [[V2TIMManager sharedInstance] getBlackList:^(NSArray<V2TIMFriendInfo *> *infoList) {
        @strongify(self)
        NSMutableArray *list = @[].mutableCopy;
        for (V2TIMFriendInfo *fd in infoList) {
            TUICommonContactCellData *data = [[TUICommonContactCellData alloc] initWithFriend:fd];
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
