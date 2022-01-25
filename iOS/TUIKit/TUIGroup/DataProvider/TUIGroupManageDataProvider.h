//
//  TUIGroupManageDataProvider.h
//  TUIGroup
//
//  Created by harvy on 2021/12/24.
//

#import <Foundation/Foundation.h>
@class TUIUserModel;

NS_ASSUME_NONNULL_BEGIN

@protocol TUIGroupManageDataProviderDelegate <NSObject>

// 刷新群信息
- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadData;
- (void)showCoverViewWhenMuteAll:(BOOL)show;

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

- (void)onError:(int)code desc:(NSString *)desc operate:(NSString *)operate;

@end

@interface TUIGroupManageDataProvider : NSObject

@property (nonatomic, assign) BOOL muteAll;
@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, assign) BOOL currentGroupTypeSupportSettingAdmin;//当前群类型是否支持设置管理员
@property (nonatomic, assign) BOOL currentGroupTypeSupportAddMemberOfBlocked;//当前群类型是否支持设置管理员
@property (nonatomic, weak) id<TUIGroupManageDataProviderDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableArray *datas;

- (void)loadData;

// 全员禁言
- (void)mutedAll:(BOOL)mute completion:(void(^)(int, NSString *))completion;

// 禁言/取消禁言 指定人员
- (void)mute:(BOOL)mute user:(TUIUserModel *)user;

@end

NS_ASSUME_NONNULL_END
