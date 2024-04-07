//
//  TUIFindContactViewDataProvider.m
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFindContactViewDataProvider_Minimalist.h"
#import <ImSDK_Plus/ImSDK_Plus.h>
#import <TUICore/TUIGlobalization.h>
#import "TUIFindContactCellModel_Minimalist.h"

@interface TUIFindContactViewDataProvider_Minimalist ()
@property(nonatomic, strong) NSArray<TUIFindContactCellModel_Minimalist *> *users;
@property(nonatomic, strong) NSArray<TUIFindContactCellModel_Minimalist *> *groups;
@end

@implementation TUIFindContactViewDataProvider_Minimalist

- (void)findUser:(NSString *)userID completion:(dispatch_block_t)completion {
    if (!completion) {
        return;
    }
    if (userID == nil) {
        self.users = @[];
        completion();
        return;
    }

    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getUsersInfo:@[ userID ]
        succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
          V2TIMUserFullInfo *userInfo = infoList.firstObject;
          if (userInfo) {
              TUIFindContactCellModel_Minimalist *cellModel = [[TUIFindContactCellModel_Minimalist alloc] init];
              cellModel.avatarUrl = [NSURL URLWithString:userInfo.faceURL];
              cellModel.mainTitle = userInfo.nickName ?: userInfo.userID;
              cellModel.subTitle = userInfo.userID ?: userInfo.userID;
              cellModel.desc = @"";
              cellModel.type = TUIFindContactTypeC2C_Minimalist;
              cellModel.contactID = userInfo.userID;
              cellModel.userInfo = userInfo;
              weakSelf.users = @[ cellModel ];
          }
          completion();
        }
        fail:^(int code, NSString *msg) {
          weakSelf.users = @[];
          completion();
        }];
}

- (void)findGroup:(NSString *)groupID completion:(dispatch_block_t)completion {
    if (!completion) {
        return;
    }
    if (groupID == nil) {
        self.groups = @[];
        completion();
        return;
    }

    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getGroupsInfo:@[ groupID ]
        succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
          V2TIMGroupInfoResult *result = groupResultList.firstObject;
          if (result && result.resultCode == 0) {
              V2TIMGroupInfo *info = result.info;
              TUIFindContactCellModel_Minimalist *cellModel = [[TUIFindContactCellModel_Minimalist alloc] init];
              cellModel.avatarUrl = [NSURL URLWithString:info.faceURL];
              cellModel.mainTitle = info.groupName;
              cellModel.subTitle = info.groupID;
              cellModel.desc = [NSString stringWithFormat:@"%@: %@",TIMCommonLocalizableString(TUIKitGroupProfileType),info.groupType];
              cellModel.type = TUIFindContactTypeGroup_Minimalist;
              cellModel.contactID = info.groupID;
              cellModel.groupInfo = info;
              weakSelf.groups = @[ cellModel ];
          } else {
              weakSelf.groups = @[];
          }
          completion();
        }
        fail:^(int code, NSString *desc) {
          weakSelf.groups = @[];
          completion();
        }];
}

- (NSString *)getMyUserIDDescription {
    NSString *loginUser = V2TIMManager.sharedInstance.getLoginUser;
    return [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitAddContactMyUserIDFormat), loginUser];
}

- (void)clear {
    self.users = @[];
    self.groups = @[];
}

@end
