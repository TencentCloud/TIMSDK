

@import Foundation;
@import UIKit;
@import ImSDK_Plus;

@class TUICommonCellData;
@class TUICommonTextCell;
@class TUICommonSwitchCell;
@class TUIButtonCell;
@class TUIProfileCardCell;
@class TUIGroupMemberCellData;
@class TUIGroupMembersCellData;

NS_ASSUME_NONNULL_BEGIN

@protocol TUIGroupInfoDataProviderDelegate <NSObject>
- (void)didSelectMembers;
- (void)didSelectGroupNick:(TUICommonTextCell *)cell;
- (void)didSelectAddOption:(UITableViewCell *)cell;
- (void)didSelectCommon;
- (void)didSelectOnNotDisturb:(TUICommonSwitchCell *)cell;
- (void)didSelectOnTop:(TUICommonSwitchCell *)cell;
- (void)didDeleteGroup:(TUIButtonCell *)cell;
- (void)didClearAllHistory:(TUIButtonCell *)cell;
@end

@interface TUIGroupInfoDataProvider : NSObject
@property (nonatomic, weak) id<TUIGroupInfoDataProviderDelegate> delegate;
@property (nonatomic, strong) V2TIMGroupInfo *groupInfo;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) NSMutableArray<TUIGroupMemberCellData *> *membersData;
@property (nonatomic, strong) TUIGroupMembersCellData *groupMembersCellData;
@property (nonatomic, strong, readonly) V2TIMGroupMemberFullInfo *selfInfo;

- (instancetype)initWithGroupID:(NSString *)groupID;
- (void)loadData;
- (void)setGroupAddOpt:(V2TIMGroupAddOpt)opt;
- (void)setGroupReceiveMessageOpt:(V2TIMReceiveMessageOpt)opt;
- (void)setGroupName:(NSString *)groupName;
- (void)setGroupNotification:(NSString *)notification;
- (void)setGroupMemberNameCard:(NSString *)nameCard;
- (void)dismissGroup:(V2TIMSucc)succ fail:(V2TIMFail)fail;
- (void)quitGroup:(V2TIMSucc)succ fail:(V2TIMFail)fail;
- (void)clearAllHistory:(V2TIMSucc)succ fail:(V2TIMFail)fail;
- (void)updateGroupAvatar:(NSString *)url succ:(V2TIMSucc)succ fail:(V2TIMFail)fail;
/**
 *  判断当前用户在对与当前 TIMGroupInfo 来说是否是管理。
 *
 *  @return YES：是管理；NO：不是管理
 */
+ (BOOL)isMeOwner:(V2TIMGroupInfo *)groupInfo;
@end

NS_ASSUME_NONNULL_END
