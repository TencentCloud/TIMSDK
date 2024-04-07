//
//  TUIGroupManageDataProvider_Minimalist.m
//  TUIGroup
//
//  Created by wyl on 2023/1/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGroupManageDataProvider_Minimalist.h"
#import <ImSDK_Plus/ImSDK_Plus.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TUICore/TUIGlobalization.h>
#import "TUIMemberInfoCellData_Minimalist.h"
#import "TUISelectGroupMemberCell.h"

@interface TUIGroupManageDataProvider_Minimalist ()

@property(nonatomic, strong) NSMutableArray *datas;

@property(nonatomic, strong) NSMutableArray *groupInfoDatasArray;
@property(nonatomic, strong) NSMutableArray *muteMembersDataArray;

@property(nonatomic, strong) V2TIMGroupInfo *groupInfo;

@end

@implementation TUIGroupManageDataProvider_Minimalist

- (void)mutedAll:(BOOL)mute completion:(void (^)(int, NSString *))completion {
    __weak typeof(self) weakSelf = self;
    V2TIMGroupInfo *groupInfo = [[V2TIMGroupInfo alloc] init];
    groupInfo.groupID = self.groupID;
    groupInfo.allMuted = mute;
    [V2TIMManager.sharedInstance setGroupInfo:groupInfo
        succ:^{
          weakSelf.muteAll = mute;
          if (completion) {
              completion(0, nil);
          }
        }
        fail:^(int code, NSString *desc) {
          weakSelf.muteAll = !mute;
          if (completion) {
              completion(code, desc);
          }
        }];
}

- (void)mute:(BOOL)mute user:(TUIUserModel *)user {
    if (!NSThread.isMainThread) {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
          @strongify(self);
          [self mute:mute user:user];
        });
        return;
    }
    __weak typeof(self) weakSelf = self;
    void (^callback)(int, NSString *, BOOL) = ^(int code, NSString *desc, BOOL mute) {
      dispatch_async(dispatch_get_main_queue(), ^{
        TUIMemberInfoCellData_Minimalist *existData = nil;
        for (TUIMemberInfoCellData_Minimalist *data in weakSelf.muteMembersDataArray) {
            if ([data.identifier isEqualToString:user.userId]) {
                existData = data;
                break;
            }
        }

        if (code == 0 && mute) {
            // mute succ
            if (!existData) {
                TUIMemberInfoCellData_Minimalist *cellData = [[TUIMemberInfoCellData_Minimalist alloc] init];
                cellData.identifier = user.userId;
                cellData.name = user.name ?: user.userId;
                cellData.avatarUrl = user.avatar;
                [weakSelf.muteMembersDataArray addObject:cellData];
            }
        } else if (code == 0 && !mute) {
            // unmute succ
            if (existData) {
                [weakSelf.muteMembersDataArray removeObject:existData];
            }
        } else {
            // fail
            if ([weakSelf.delegate respondsToSelector:@selector(onError:desc:operate:)]) {
                [weakSelf.delegate onError:code
                                      desc:desc
                                   operate:mute ? 
                                    TIMCommonLocalizableString(TUIKitGroupShutupOption) :
                                    TIMCommonLocalizableString(TUIKitGroupDisShutupOption)
                ];
            }
        }

        if ([weakSelf.delegate respondsToSelector:@selector(reloadData)]) {
            [weakSelf.delegate reloadData];
        }
      });
    };

    [V2TIMManager.sharedInstance muteGroupMember:self.groupID
        member:user.userId
        muteTime:mute ? 365 * 24 * 3600 : 0
        succ:^{
          callback(0, nil, mute);
        }
        fail:^(int code, NSString *desc) {
          callback(code, desc, mute);
        }];
}

- (void)loadData {
    self.groupInfoDatasArray = [NSMutableArray array];
    self.muteMembersDataArray = [NSMutableArray array];
    self.datas = [NSMutableArray arrayWithArray:@[ self.groupInfoDatasArray, self.muteMembersDataArray ]];

    @weakify(self);
    [V2TIMManager.sharedInstance getGroupsInfo:@[ self.groupID ?: @"" ]
        succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
          @strongify(self);
          V2TIMGroupInfoResult *result = groupResultList.firstObject;
          if (result == nil || result.resultCode != 0) {
              return;
          }

          V2TIMGroupInfo *groupInfo = result.info;
          self.groupInfo = groupInfo;
          [self setupGroupInfo:groupInfo];
          self.muteAll = groupInfo.allMuted;
          self.currentGroupTypeSupportSettingAdmin = [self canSupportSettingAdminAtThisGroupType:groupInfo.groupType];
          self.currentGroupTypeSupportAddMemberOfBlocked = [self canSupportAddMemberOfBlockedAtThisGroupType:groupInfo.groupType];
        }
        fail:^(int code, NSString *desc) {
          @strongify(self);
          [self setupGroupInfo:nil];
        }];

    [self loadMuteMembers];
}

- (void)loadMuteMembers {
    if (!NSThread.isMainThread) {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
          @strongify(self);
          [self loadMuteMembers];
        });
    }

    [self.muteMembersDataArray removeAllObjects];
    if ([self.delegate respondsToSelector:@selector(reloadData)]) {
        [self.delegate reloadData];
    }

    TUIMemberInfoCellData_Minimalist *add = [[TUIMemberInfoCellData_Minimalist alloc] init];
    add.avatar = TUIGroupCommonBundleImage(@"icon_group_Add");
    add.name = TIMCommonLocalizableString(TUIKitGroupAddShutupMember);
    add.style = TUIMemberInfoCellStyleAdd;
    [self.muteMembersDataArray addObject:add];

    if ([self.delegate respondsToSelector:@selector(insertRowsAtIndexPaths:withRowAnimation:)]) {
        [self.delegate insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
    }

    [self setupGroupMembers:0 first:YES];
}

- (void)setupGroupMembers:(uint64_t)seq first:(uint64_t)first {
    if (seq == 0 && !first) {
        return;
    }

    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance
        getGroupMemberList:self.groupID
                    filter:V2TIM_GROUP_MEMBER_FILTER_ALL
                   nextSeq:0
                      succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
                        NSMutableArray *indexPaths = [NSMutableArray array];
                        for (V2TIMGroupMemberFullInfo *info in memberList) {
                            if (info.muteUntil && info.muteUntil > [NSDate.new timeIntervalSince1970]) {
                                TUIMemberInfoCellData_Minimalist *member = [[TUIMemberInfoCellData_Minimalist alloc] init];
                                member.avatarUrl = info.faceURL;
                                member.name = (info.nameCard ?: info.nickName) ?: info.userID;
                                member.identifier = info.userID;
                                BOOL exist = NO;
                                for (TUIMemberInfoCellData_Minimalist *data in weakSelf.muteMembersDataArray) {
                                    if ([data.identifier isEqualToString:info.userID]) {
                                        exist = YES;
                                        break;
                                    }
                                }

                                BOOL isSuper = (info.role == V2TIM_GROUP_MEMBER_ROLE_SUPER);
                                BOOL isAdMin = (info.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN);
                                BOOL allowShowInMuteList = YES;
                                if (isSuper || isAdMin) {
                                    allowShowInMuteList = NO;
                                }
                                if (!exist && allowShowInMuteList) {
                                    [weakSelf.muteMembersDataArray addObject:member];
                                    [indexPaths addObject:[NSIndexPath indexPathForRow:[weakSelf.muteMembersDataArray indexOfObject:member] inSection:1]];
                                }
                            }
                        }

                        if (indexPaths.count) {
                            if ([weakSelf.delegate respondsToSelector:@selector(insertRowsAtIndexPaths:withRowAnimation:)]) {
                                [weakSelf.delegate insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                            }
                        }

                        [weakSelf setupGroupMembers:nextSeq first:NO];
                      }
                      fail:^(int code, NSString *desc){

                      }];
}

- (void)setupGroupInfo:(V2TIMGroupInfo *)groupInfo {
    if (!NSThread.isMainThread) {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
          @strongify(self);
          [self setupGroupInfo:groupInfo];
        });
        return;
    }

    if (groupInfo == nil) {
        return;
    }
    [self.groupInfoDatasArray removeAllObjects];

    TUICommonTextCellData *adminSetting = [[TUICommonTextCellData alloc] init];
    adminSetting.key = TIMCommonLocalizableString(TUIKitGroupManageAdminSetting);
    adminSetting.value = @"";
    adminSetting.showAccessory = YES;
    adminSetting.cselector = @selector(onSettingAdmin:);
    //    [self.groupInfoDatasArray addObject:adminSetting];

    TUICommonSwitchCellData *shutupAll = [[TUICommonSwitchCellData alloc] init];
    shutupAll.title = TIMCommonLocalizableString(TUIKitGroupManageShutAll);
    shutupAll.on = groupInfo.allMuted;
    shutupAll.cswitchSelector = @selector(onMutedAll:);
    [self.groupInfoDatasArray addObject:shutupAll];

    if ([self.delegate respondsToSelector:@selector(reloadData)]) {
        [self.delegate reloadData];
    }
}

//- (void)onMutedAll:(TUICommonSwitchCellData *)switchData
//{
//    if ([self.delegate respondsToSelector:@selector(onMutedAll:)]) {
//        [self.delegate onMutedAll:switchData.isOn];
//    }
//}

- (void)updateMuteMembersFilterAdmins {
    [self loadMuteMembers];
}
- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

- (BOOL)canSupportSettingAdminAtThisGroupType:(NSString *)grouptype {
    if ([grouptype isEqualToString:@"Work"] || [grouptype isEqualToString:@"AVChatRoom"]) {
        return NO;
    }
    return YES;
}

- (BOOL)canSupportAddMemberOfBlockedAtThisGroupType:(NSString *)grouptype {
    if ([grouptype isEqualToString:@"Work"]) {
        return NO;
    }
    return YES;
}

@end
