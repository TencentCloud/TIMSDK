//
//  TUIGroupManageDataProvider_Minimalist.h
//  TUIGroup
//
//  Created by wyl on 2023/1/9.
//

#import <Foundation/Foundation.h>
@class TUIUserModel;

NS_ASSUME_NONNULL_BEGIN

@protocol TUIGroupManageDataProviderDelegate_Minimalist <NSObject>

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadData;
- (void)showCoverViewWhenMuteAll:(BOOL)show;

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

- (void)onError:(int)code desc:(NSString *)desc operate:(NSString *)operate;

@end

@interface TUIGroupManageDataProvider_Minimalist : NSObject

@property (nonatomic, assign) BOOL muteAll;
@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, assign) BOOL currentGroupTypeSupportSettingAdmin;
@property (nonatomic, assign) BOOL currentGroupTypeSupportAddMemberOfBlocked;
@property (nonatomic, weak) id<TUIGroupManageDataProviderDelegate_Minimalist> delegate;
@property (nonatomic, strong, readonly) NSMutableArray *datas;

- (void)loadData;

- (void)mutedAll:(BOOL)mute completion:(void(^)(int, NSString *))completion;
- (void)mute:(BOOL)mute user:(TUIUserModel *)user;

- (void)updateMuteMembersFilterAdmins;
@end

NS_ASSUME_NONNULL_END
