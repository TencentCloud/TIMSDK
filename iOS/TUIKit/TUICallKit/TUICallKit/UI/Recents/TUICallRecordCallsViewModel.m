//
//  TUICallRecordCallsViewModel.m
//  TUICallKit
//
//  Created by noah on 2023/2/28.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICallRecordCallsViewModel.h"
#import "TUICallEngineHeader.h"
#import "TUIDefine.h"
#import "TUICore.h"
#import "TUICallRecordCallsCellViewModel.h"
#import "TUICallKit.h"
#import "TUICallKitOfflinePushInfoConfig.h"
#import "TUICallKitConstants.h"

@interface TUICallRecordCallsViewModel()

@property (nonatomic, strong) NSMutableArray<TUICallRecordCallsCellViewModel *> *dataSource;
@property (nonatomic, strong) NSMutableArray<TUICallRecordCallsCellViewModel *> *allDataSource;
@property (nonatomic, strong) NSMutableArray<TUICallRecordCallsCellViewModel *> *missedDataSource;
@property (nonatomic, assign) TUICallRecordCallsType recordCallsType;

@end

@implementation TUICallRecordCallsViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _recordCallsType = TUICallRecordCallsTypeAll;
        _recordCallsUIStyle = TUICallKitRecordCallsUIStyleMinimalist;
    }
    return self;
}

- (void)repeatCall:(NSIndexPath *)indexPath {
    TUICallRecordCallsCellViewModel *cellViewModel = self.dataSource[indexPath.row];
    if (!cellViewModel.callRecord) {
        return;
    }
    if (TUICallSceneSingle == cellViewModel.callRecord.scene) {
        [self repeatSingleCall:cellViewModel.callRecord];
    }
}

- (void)repeatSingleCall:(TUICallRecords *)callRecord {
    NSString *userId = [callRecord.inviteList firstObject];
    if (TUICallRoleCalled == callRecord.role) {
        userId = callRecord.inviter;
    }
    if (!userId || userId.length <= 0) {
        return;
    }
    [[TUICallKit createInstance] call:userId callMediaType:callRecord.mediaType];
}

- (void)jumpUserInfoController:(NSIndexPath *)indexPath navigationController:(UINavigationController *)nav {
    TUICallRecordCallsCellViewModel *cellViewModel = self.dataSource[indexPath.row];
    
    if (!cellViewModel.callRecord) {
        return;
    }
    
    NSString *groupId = cellViewModel.callRecord.groupId;
    NSString *userId = cellViewModel.callRecord.inviter;
    
    if (TUICallRoleCall == cellViewModel.callRecord.role) {
        userId = [cellViewModel.callRecord.inviteList firstObject];
    }
    
    if (groupId && groupId.length > 0) {
        NSDictionary *param = @{
            TUICore_TUIGroupObjectFactory_GetGroupInfoVC_GroupID:groupId
        };
        
        if (TUICallKitRecordCallsUIStyleClassic == self.recordCallsUIStyle) {
            [nav pushViewController:TUICore_TUIGroupObjectFactory_GetGroupInfoVC_Classic
                              param:param
                          forResult:nil];
        } else {
            [nav pushViewController:TUICore_TUIGroupObjectFactory_GetGroupInfoVC_Minimalist
                              param:param
                          forResult:nil];
        }
    } else if (userId && userId.length > 0) {
        [self getUserOrFriendProfileVCWithUserID:userId
                                       succBlock:^(UIViewController * _Nonnull viewController) {
            [nav pushViewController:viewController animated:YES];
        } failBlock:^(int code, NSString * _Nonnull desc) {
            [TUITool makeToastError:code msg:desc];
        }];
    }
}

- (void)getUserOrFriendProfileVCWithUserID:(NSString *)userID
                                 succBlock:(void(^)(UIViewController *vc))succ
                                 failBlock:(nullable V2TIMFail)fail {
    NSDictionary *param = @{
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey: userID ? : @"",
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey: succ ? : ^(UIViewController *vc){},
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey: fail ? : ^(int code, NSString * desc){}
    };
    
    if (TUICallKitRecordCallsUIStyleClassic == self.recordCallsUIStyle) {
        [TUICore createObject:TUICore_TUIContactObjectFactory
                          key:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod
                        param:param];
    } else {
        [TUICore createObject:TUICore_TUIContactObjectFactory_Minimalist
                          key:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod
                        param:param];
    }
}

- (void)queryRecentCalls {
    TUICallRecentCallsFilter *filter = [[TUICallRecentCallsFilter alloc] init];
    __weak __typeof(self) weakSelf = self;
    [[TUICallEngine createInstance] queryRecentCalls:filter succ:^(NSArray<TUICallRecords *> * _Nonnull callRecord) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSMutableArray *viewModelList = @[].mutableCopy;
        [callRecord enumerateObjectsUsingBlock:^(TUICallRecords * _Nonnull callRecord, NSUInteger idx, BOOL * _Nonnull stop) {
            TUICallRecordCallsCellViewModel *viewModel = [[TUICallRecordCallsCellViewModel alloc] initWithCallRecord:callRecord];
            if (viewModel) {
                [viewModelList addObject:viewModel];
            }
        }];
        [strongSelf updateDataSourceWith:[viewModelList copy]];
        [strongSelf reloadDataSource];
    } fail:^{
    }];
}

- (void)switchRecordCallsType:(TUICallRecordCallsType)recordCallsType {
    self.recordCallsType = recordCallsType;
    [self reloadDataSource];
}

- (void)deleteRecordCall:(NSIndexPath *)indexPath {
    TUICallRecordCallsCellViewModel *cellViewModel = self.dataSource[indexPath.row];
    
    if (!cellViewModel) {
        return;
    }
    
    [self removeObject:cellViewModel];
    [self reloadDataSource:NO];
    
    if (cellViewModel.callRecord.callId) {
        [[TUICallEngine createInstance] deleteRecordCalls:@[cellViewModel.callRecord.callId] succ:^(NSArray<NSString *> * _Nonnull succList) {
        } fail:^{
        }];
    }
}

- (void)clearAllRecordCalls {
    NSArray *callIdList = [self getCallIdListWith:self.dataSource];
    if (!callIdList || callIdList.count <= 0) {
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    [[TUICallEngine createInstance] deleteRecordCalls:[callIdList copy] succ:^(NSArray<NSString *> * _Nonnull succList) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.dataSource enumerateObjectsUsingBlock:^(TUICallRecordCallsCellViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([succList containsObject:obj.callRecord.callId]) {
                [strongSelf removeObject:obj];
            }
        }];
        [strongSelf.dataSource removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf reloadDataSource];
        });
    } fail:^{
    }];
}

#pragma mark - private method

- (void)removeObject:(TUICallRecordCallsCellViewModel *)viewModel {
    if (!viewModel) {
        return;
    }
    [self.allDataSource removeObject:viewModel];
    [self.missedDataSource removeObject:viewModel];
}

- (void)removeAllObject {
    [self.dataSource removeAllObjects];
    [self.allDataSource removeAllObjects];
    [self.missedDataSource removeAllObjects];
}

- (void)updateDataSourceWith:(NSArray *)viewModelList {
    if (!viewModelList || viewModelList.count <= 0) {
        return;
    }
    [self removeAllObject];
    self.allDataSource = viewModelList.mutableCopy;
    [viewModelList enumerateObjectsUsingBlock:^(TUICallRecordCallsCellViewModel *viewModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (viewModel.callRecord && TUICallRecordCallsTypeMissed == viewModel.callRecord.result) {
            [self.missedDataSource addObject:viewModel];
        }
    }];
}

- (void)reloadDataSource {
    [self reloadDataSource:YES];
}

- (void)reloadDataSource:(BOOL)isNeedObserved{
    switch (self.recordCallsType) {
        case TUICallRecordCallsTypeAll:
            if (isNeedObserved){
                self.dataSource = [NSMutableArray arrayWithArray:self.allDataSource];
            } else {
                _dataSource = [NSMutableArray arrayWithArray:self.allDataSource];
            }
            break;
        case TUICallRecordCallsTypeMissed:
            if (isNeedObserved){
                self.dataSource = [NSMutableArray arrayWithArray:self.missedDataSource];
            } else {
                _dataSource = [NSMutableArray arrayWithArray:self.missedDataSource];
            }
            break;
        default:
            break;
    }
}

- (NSArray *)getCallIdListWith:(NSArray<TUICallRecordCallsCellViewModel *> *)cellViewModelArray {
    if (!cellViewModelArray || cellViewModelArray.count <= 0) {
        return @[];
    }
    
    NSMutableArray *callIdList = @[].mutableCopy;
    [cellViewModelArray enumerateObjectsUsingBlock:^(TUICallRecordCallsCellViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.callRecord && obj.callRecord.callId) {
            [callIdList addObject:obj.callRecord.callId];
        }
    }];
    
    return [callIdList copy];
}

#pragma mark - getter and setter

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (NSMutableArray *)allDataSource {
    if (_allDataSource == nil) {
        _allDataSource = [[NSMutableArray alloc] init];
    }
    return _allDataSource;
}

- (NSMutableArray *)missedDataSource {
    if (_missedDataSource == nil) {
        _missedDataSource = [[NSMutableArray alloc] init];
    }
    return _missedDataSource;
}

@end
