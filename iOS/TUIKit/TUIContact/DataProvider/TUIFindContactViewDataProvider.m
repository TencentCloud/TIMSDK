//
//  TUIFindContactViewDataProvider.m
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//

#import "TUIFindContactViewDataProvider.h"
#import <ImSDK_Plus/ImSDK_Plus.h>
#import "TUIFindContactCellModel.h"
#import "TUIGlobalization.h"

@interface TUIFindContactViewDataProvider ()
@property (nonatomic, strong) NSArray<TUIFindContactCellModel *> *users;
@property (nonatomic, strong) NSArray<TUIFindContactCellModel *> *groups;
@end

@implementation TUIFindContactViewDataProvider

- (void)findUser:(NSString *)userID completion:(dispatch_block_t)completion
{
    if (!completion) {
        return;
    }
    if (userID == nil) {
        self.users = @[];
        completion();
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[userID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        V2TIMUserFullInfo *userInfo = infoList.firstObject;
        if (userInfo) {
            TUIFindContactCellModel *cellModel = [[TUIFindContactCellModel alloc] init];
            cellModel.avatarUrl = [NSURL URLWithString:userInfo.faceURL];
            cellModel.mainTitle = userInfo.nickName?:userInfo.userID;
            cellModel.subTitle = [NSString stringWithFormat:@"ID: %@", userInfo.userID];
            cellModel.desc = @"";
            cellModel.type = TUIFindContactTypeC2C;
            cellModel.contactID = userInfo.userID;
            cellModel.userInfo = userInfo;
            weakSelf.users = @[cellModel];
        }
        completion();
    } fail:^(int code, NSString *msg) {
        weakSelf.users = @[];
        completion();
    }];
}

- (void)findGroup:(NSString *)groupID completion:(dispatch_block_t)completion
{
    if (!completion) {
        return;
    }
    if (groupID == nil) {
        self.groups = @[];
        completion();
        return;
    }

    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getGroupsInfo:@[groupID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        V2TIMGroupInfoResult *result = groupResultList.firstObject;
        if (result && result.resultCode == 0) {
            V2TIMGroupInfo *info = result.info;
            TUIFindContactCellModel *cellModel = [[TUIFindContactCellModel alloc] init];
            cellModel.avatarUrl = [NSURL URLWithString:info.faceURL];
            cellModel.mainTitle = info.groupName;
            cellModel.subTitle = [NSString stringWithFormat:@"ID: %@", info.groupID];
            cellModel.desc = [NSString stringWithFormat:@"群类型: %@", info.groupType];
            cellModel.type = TUIFindContactTypeGroup;
            cellModel.contactID = info.groupID;
            cellModel.groupInfo = info;
            weakSelf.groups = @[cellModel];
        }
        else {
            weakSelf.groups = @[];
        }
        completion();
    } fail:^(int code, NSString *desc) {
        weakSelf.groups = @[];
        completion();
    }];
}

- (NSString *)getMyUserIDDescription
{
    NSString *loginUser = V2TIMManager.sharedInstance.getLoginUser;
    return [NSString stringWithFormat:TUIKitLocalizableString(TUIKitAddContactMyUserIDFormat), loginUser];
}

- (void)clear
{
    self.users = @[];
    self.groups = @[];
}

@end
