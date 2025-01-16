
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.


@import Foundation;
@import UIKit;
@import ImSDK_Plus;

@class TUICommonCellData;
@class TUICommonTextCell;
@class TUICommonSwitchCell;
@class TUIButtonCell;
@class TUIProfileCardCellData;
@class TUIProfileCardCell;
@class TUIGroupMemberCellData;
@class TUIGroupMembersCellData;

NS_ASSUME_NONNULL_BEGIN

@protocol TUIGroupInfoDataProviderDelegate <NSObject>
- (UINavigationController *)pushNavigationController;
- (void)didSelectMembers;
- (void)didSelectGroupNick:(TUICommonTextCell *)cell;
- (void)didSelectAddOption:(UITableViewCell *)cell;
- (void)didSelectCommon;
- (void)didSelectOnNotDisturb:(TUICommonSwitchCell *)cell;
- (void)didSelectOnTop:(TUICommonSwitchCell *)cell;
- (void)didSelectOnFoldConversation:(TUICommonSwitchCell *)cell;
- (void)didSelectOnChangeBackgroundImage:(TUICommonTextCell *)cell;
- (void)didDeleteGroup:(TUIButtonCell *)cell;
- (void)didClearAllHistory:(TUIButtonCell *)cell;
- (void)didSelectGroupNotice;
@end

@interface TUIGroupInfoDataProvider : NSObject
@property(nonatomic, weak) id<TUIGroupInfoDataProviderDelegate> delegate;
@property(nonatomic, strong) V2TIMGroupInfo *groupInfo;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) NSMutableArray<TUIGroupMemberCellData *> *membersData;
@property(nonatomic, strong) TUIGroupMembersCellData *groupMembersCellData;
@property(nonatomic, strong, readonly) V2TIMGroupMemberFullInfo *selfInfo;
@property(nonatomic, strong, readonly) TUIProfileCardCellData *profileCellData;

- (instancetype)initWithGroupID:(NSString *)groupID;
- (void)loadData;
- (void)updateGroupInfo;
- (void)setGroupAddOpt:(V2TIMGroupAddOpt)opt;
- (void)setGroupApproveOpt:(V2TIMGroupAddOpt)opt;
- (void)setGroupReceiveMessageOpt:(V2TIMReceiveMessageOpt)opt Succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;
- (void)setGroupName:(NSString *)groupName;
- (void)setGroupNotification:(NSString *)notification;
- (void)setGroupMemberNameCard:(NSString *)nameCard;
- (void)dismissGroup:(V2TIMSucc)succ fail:(V2TIMFail)fail;
- (void)quitGroup:(V2TIMSucc)succ fail:(V2TIMFail)fail;
- (void)clearAllHistory:(V2TIMSucc)succ fail:(V2TIMFail)fail;
- (void)updateGroupAvatar:(NSString *)url succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;
- (void)transferGroupOwner:(NSString *)groupID member:(NSString *)userID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;
+ (BOOL)isMeOwner:(V2TIMGroupInfo *)groupInfo;
@end

NS_ASSUME_NONNULL_END
