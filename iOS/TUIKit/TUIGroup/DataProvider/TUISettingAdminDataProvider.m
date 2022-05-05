//
//  TUISettingAdminDataProvider.m
//  TUIGroup
//
//  Created by harvy on 2021/12/28.
//

#import "TUISettingAdminDataProvider.h"
#import <ImSDK_Plus/ImSDK_Plus.h>
#import "TUIMemberInfoCellData.h"
#import "TUIDefine.h"

@interface TUISettingAdminDataProvider ()

@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) NSMutableArray *owners;
@property (nonatomic, strong) NSMutableArray *admins;

@end

@implementation TUISettingAdminDataProvider

- (void)removeAdmin:(NSString *)userID callback:(void(^)(int, NSString *))callback
{
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance setGroupMemberRole:self.groupID member:userID newRole:V2TIM_GROUP_MEMBER_ROLE_MEMBER succ:^{
        TUIMemberInfoCellData *exist = [self existAdmin:userID];
        if (exist) {
            [weakSelf.admins removeObject:exist];
        }
        
        if (callback) {
            callback(0, nil);
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)settingAdmins:(NSArray<TUIUserModel *> *)userModels callback:(void(^)(int, NSString *))callback;
{
    NSMutableArray *validUsers = [NSMutableArray array];
    for (TUIUserModel *user in userModels) {
        TUIMemberInfoCellData *exist = [self existAdmin:user.userId];
        if (!exist) {
            TUIMemberInfoCellData *data = [[TUIMemberInfoCellData alloc] init];
            data.identifier = user.userId;
            data.name = user.name;
            data.avatarUrl = user.avatar;
            [validUsers addObject:data];
        }
    }
    
    if (validUsers.count == 0) {
        if (callback) {
            callback(0, nil);
        }
        return;
    }
    
    if (self.admins.count + validUsers.count > 11) {
        if (callback) {
            callback(-1, @"The number of administrator must be less than ten");
        }
        return;
    }
    
    __block int errorCode = 0;
    __block NSString *errorMsg = nil;
    NSMutableArray *results = [NSMutableArray array];
    
    dispatch_group_t group = dispatch_group_create();
    for (TUIMemberInfoCellData *data in validUsers) {
        dispatch_group_enter(group);
        [V2TIMManager.sharedInstance setGroupMemberRole:self.groupID member:data.identifier newRole:V2TIM_GROUP_MEMBER_ROLE_ADMIN succ:^{
            [results addObject:data];
            dispatch_group_leave(group);
        } fail:^(int code, NSString *desc) {
            if (errorCode == 0) {
                errorCode = code;
                errorMsg = desc;
            }
            dispatch_group_leave(group);
        }];
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [weakSelf.admins addObjectsFromArray:results];
        if (callback) {
            callback(errorCode, errorMsg);
        }
    });
}

- (void)loadData:(void(^)(int, NSString *))callback
{
    {
        TUIMemberInfoCellData *add = [[TUIMemberInfoCellData alloc] init];
        add.style = TUIMemberInfoCellStyleAdd;
        add.name = TUIKitLocalizableString(TUIKitGroupAddAdmins);
        add.avatar = TUIGroupCommonBundleImage(@"icon_add");
        [self.admins addObject:add];
    }
    
    __weak typeof(self) weakSelf = self;
    
    __block int errorCode = 0;
    __block NSString *errorMsg = nil;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [V2TIMManager.sharedInstance getGroupMemberList:self.groupID
                                             filter:V2TIM_GROUP_MEMBER_FILTER_OWNER
                                            nextSeq:0
                                               succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        for (V2TIMGroupMemberFullInfo *info in memberList) {
            TUIMemberInfoCellData *cellData = [[TUIMemberInfoCellData alloc] init];
            cellData.identifier = info.userID;
            cellData.name = (info.nameCard?:info.nickName)?:info.userID;
            cellData.avatarUrl = info.faceURL;
            if (info.role == V2TIM_GROUP_MEMBER_ROLE_SUPER) {
                // 群主
                [weakSelf.owners addObject:cellData];
            }
        }
        
        dispatch_group_leave(group);
    }
                                               fail:^(int code, NSString *desc) {
        if (errorCode == 0) {
            errorCode = code;
            errorMsg = desc;
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [V2TIMManager.sharedInstance getGroupMemberList:self.groupID filter:V2TIM_GROUP_MEMBER_FILTER_ADMIN nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        for (V2TIMGroupMemberFullInfo *info in memberList) {
            TUIMemberInfoCellData *cellData = [[TUIMemberInfoCellData alloc] init];
            cellData.identifier = info.userID;
            cellData.name = (info.nameCard?:info.nickName)?:info.userID;
            cellData.avatarUrl = info.faceURL;
            if (info.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN) {
                // 管理员
                [weakSelf.admins addObject:cellData];
            }
        }
        dispatch_group_leave(group);
    } fail:^(int code, NSString *desc) {
        if (errorCode == 0) {
            errorCode = code;
            errorMsg = desc;
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        weakSelf.datas = [NSMutableArray arrayWithArray:@[weakSelf.owners, weakSelf.admins]];
        if (callback) {
            callback(errorCode, errorMsg);
        }
    });
}

- (TUIMemberInfoCellData *)existAdmin:(NSString *)userID
{
    TUIMemberInfoCellData *exist = nil;
    for (TUIMemberInfoCellData *data in self.admins) {
        if ([data.identifier isEqual:userID]) {
            exist = data;
            break;
        }
    }
    
    return exist;
}

- (NSMutableArray *)datas
{
    if (_datas == nil) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

- (NSMutableArray *)owners
{
    if (_owners == nil) {
        _owners = [NSMutableArray array];
    }
    return _owners;
}

- (NSMutableArray *)admins
{
    if (_admins == nil) {
        _admins = [NSMutableArray array];
    }
    return _admins;
}


@end
