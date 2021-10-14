/**
 * Module: TUILiveMsgListTableView
 *
 * Function: 聊天室UI
 */

#import <UIKit/UIKit.h>
#import "TUILiveMsgModel.h"
#import "TUILiveMsgListCell.h"

@class TRTCLiveRoomInfo;
/**
 *  消息列表
 */
@interface TUILiveMsgListTableView : UITableView <UITableViewDelegate, UITableViewDataSource>
/**
 *  给消息列表发一条消息展示
 *  @param msgModel 消息 model
 */
- (void)bulletNewMsg:(TUILiveMsgModel *)msgModel;
@end


@protocol TCAudienceListDelegate <NSObject>

- (void)onFetchGroupMemberList:(int)errCode memberCount:(int)memberCount;

@end

/**
 *  观众列表
 */
@interface TCAudienceListTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,weak) id<TCAudienceListDelegate> audienceListDelegate;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style liveInfo:(TRTCLiveRoomInfo *)liveInfo;

/**
 *  判断是否已经在头像列表中了，如果已经在列表中，则数量不必再加1
 *
 *  @param model 消息model
 *
 *  @return 在列表中 YES 否者 NO
 */
- (BOOL)isAlreadyInAudienceList:(TUILiveMsgModel *)model;

/**
 *  通过TUILiveMsgModel 判断哪位观众进入或则退出房间
 */
- (void)refreshAudienceList:(TUILiveMsgModel *)model;

@end
