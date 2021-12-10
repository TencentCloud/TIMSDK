
#import <Foundation/Foundation.h>
#import "TUIDefine.h"
#import "TUIVideoMessageCellData.h"
#import "TUIInputMoreCellData.h"
#import "TUIChatConversationModel.h"

@class TUIBaseChatViewController;
@class TUIChatDataProvider;
NS_ASSUME_NONNULL_BEGIN

@protocol TUIChatDataProviderForwardDelegate <NSObject>

@required
- (NSString *)dataProvider:(TUIChatDataProvider *)dataProvider
                mergeForwardTitleWithMyName:(NSString *)name;
- (NSString *)dataProvider:(TUIChatDataProvider *)dataProvider
                mergeForwardMsgAbstactForMessage:(V2TIMMessage *)message;

@end

@interface TUIChatDataProvider : NSObject

@property (nonatomic, weak) id<TUIChatDataProviderForwardDelegate> forwardDelegate;

- (void)getForwardMessageWithCellDatas:(NSArray<TUIMessageCellData *> *)uiMsgs
                             toTargets:(NSArray<TUIChatConversationModel *> *)targets
                                 Merge:(BOOL)merge
                           ResultBlock:(void(^)(TUIChatConversationModel *targetConversation, NSArray<V2TIMMessage *> *msgs))resultBlock
                                  fail:(nullable V2TIMFail)fail;

#pragma mark - CellData
+ (NSMutableArray<TUIInputMoreCellData *> *)moreMenuCellDataArray:(NSString *)groupID
                                                           userID:(NSString *)userID
                                                  isNeedVideoCall:(BOOL)isNeedVideoCall
                                                  isNeedAudioCall:(BOOL)isNeedAudioCall
                                                  isNeedGroupLive:(BOOL)isNeedGroupLive
                                                       isNeedLink:(BOOL)isNeedLink;

@end


#pragma mark - TUIChatDataProvider (IMSDK)
@interface TUIChatDataProvider (IMSDK)

+ (void)getTotalUnreadMessageCountWithSuccBlock:(void(^)(UInt64 totalCount))succ
                                           fail:(nullable V2TIMFail)fail;

+ (void)saveDraftWithConversationID:(NSString *)conversationId Text:(NSString *)text;

+ (void)findMessages:(NSArray *)msgIDs callback:(void(^)(BOOL succ, NSString *error_message, NSArray *msgs))callback;

#pragma mark - C2C
+ (void)getFriendInfoWithUserId:(nullable NSString *)userID
                      SuccBlock:(void(^)(V2TIMFriendInfoResult *friendInfoResult))succ
                      failBlock:(nullable V2TIMFail)fail;
+ (void)getUserInfoWithUserId:(NSString *)userID
                    SuccBlock:(void(^)(V2TIMUserFullInfo *userInfo))succ
                    failBlock:(nullable V2TIMFail)fail;

#pragma mark - Group
+ (void)getGroupInfoWithGroupID:(NSString *)groupID
                     SuccBlock:(void(^)(V2TIMGroupInfoResult *groupResult))succ
                     failBlock:(nullable V2TIMFail)fail;

@end

NS_ASSUME_NONNULL_END
