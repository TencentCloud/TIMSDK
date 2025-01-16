//
//  TUISettingAdminDataProvider.h
//  TUIGroup
//
//  Created by harvy on 2021/12/28.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TUIUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUISettingAdminDataProvider : NSObject

@property(nonatomic, copy) NSString *groupID;

@property(nonatomic, strong, readonly) NSMutableArray *datas;
@property(nonatomic, strong, readonly) NSMutableArray *owners;
@property(nonatomic, strong, readonly) NSMutableArray *admins;

- (void)loadData:(void (^)(int, NSString *))callback;

- (void)removeAdmin:(NSString *)userID callback:(void (^)(int, NSString *))callback;
- (void)settingAdmins:(NSArray<TUIUserModel *> *)userModels callback:(void (^)(int, NSString *))callback;

@end

NS_ASSUME_NONNULL_END
