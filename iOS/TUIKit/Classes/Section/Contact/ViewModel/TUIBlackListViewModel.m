//
//  TUIBlackListViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TUIBlackListViewModel.h"
#import "THeader.h"

@interface TUIBlackListViewModel()
@property NSArray<TCommonContactCellData *> *blackListData;
@property BOOL isLoadFinished;
@property BOOL isLoading;
@end

@implementation TUIBlackListViewModel

- (void)loadBlackList
{
    if (self.isLoading)
        return;
    self.isLoading = YES;
    self.isLoadFinished = NO;
    [[V2TIMManager sharedInstance] getBlackList:^(NSArray<V2TIMFriendInfo *> *infoList) {
        NSMutableArray *list = @[].mutableCopy;
        for (V2TIMFriendInfo *fd in infoList) {
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
