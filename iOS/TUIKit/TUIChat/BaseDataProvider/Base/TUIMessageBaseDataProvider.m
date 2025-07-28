//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <AVFoundation/AVFoundation.h>

#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIMessageCell.h>
#import <TIMCommon/TUISystemMessageCellData.h>
#import <TIMCommon/TUIRelationUserModel.h>
#import <TUICore/NSString+TUIUtil.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import <TUICore/TUITool.h>
#import <TUICore/OfflinePushExtInfo.h>
#import "TUIChatConfig.h"
#import "TUICloudCustomDataTypeCenter.h"
#import "TUIMessageBaseDataProvider.h"
#import "TUIMessageProgressManager.h"
#import "TUITypingStatusCellData.h"
#import "TUIAIPlaceholderTypingMessageManager.h"

/**
 * Date time interval above the message in the UIMessageCell, in seconds, default is (5 * 60)
 */
#define MaxDateMessageDelay 5 * 60

@interface TUIMessageBaseDataProvider () <V2TIMAdvancedMsgListener, V2TIMGroupListener,TUIMessageProgressManagerDelegate>
@property(nonatomic, strong) TUIChatConversationModel *conversationModel;
@property(nonatomic, strong) NSMutableArray<TUIMessageCellData *> *uiMsgs_;
@property(nonatomic, strong) NSMutableSet<NSString *> *sentReadGroupMsgSet;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *heightCache_;
@property(nonatomic, assign) BOOL isLoadingData;
@property(nonatomic, assign) BOOL isNoMoreMsg;
@property(nonatomic, assign) BOOL isFirstLoad;
@property(nonatomic, strong) V2TIMMessage *lastMsg;
@property(nonatomic, strong) V2TIMMessage *msgForDate;
@property(nonatomic, strong) V2TIMGroupMemberFullInfo *groupSelfInfo;
@property(nonatomic, strong) NSMutableArray<V2TIMMessage *> *groupPinList;
@property(nonatomic, assign) V2TIMGroupMemberRole changedRole;
@property(nonatomic, strong) V2TIMGroupInfo *groupInfo;
@end

@implementation TUIMessageBaseDataProvider

- (instancetype)initWithConversationModel:(TUIChatConversationModel *)conversationModel {
    self = [super init];
    if (self) {
        _conversationModel = conversationModel;
        _isLoadingData = NO;
        _isNoMoreMsg = NO;
        _pageCount = 20;
        _isFirstLoad = YES;
        [self registerTUIKitNotification];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableSet<NSString *> *)sentReadGroupMsgSet {
    if (_sentReadGroupMsgSet == nil) {
        _sentReadGroupMsgSet = [NSMutableSet setWithCapacity:10];
    }
    return _sentReadGroupMsgSet;
}

- (NSMutableArray<TUIMessageCellData *> *)uiMsgs_ {
    if (_uiMsgs_ == nil) {
        _uiMsgs_ = [NSMutableArray array];
    }
    return _uiMsgs_;
}

- (NSMutableDictionary<NSString *, NSNumber *> *)heightCache_ {
    if (_heightCache_ == nil) {
        _heightCache_ = [NSMutableDictionary dictionary];
    }
    return _heightCache_;
}

- (NSArray<TUIMessageCellData *> *)uiMsgs {
    return _uiMsgs_;
}
- (NSDictionary<NSString *, NSNumber *> *)heightCache {
    return _heightCache_;
}

- (void)setChangedRole:(V2TIMGroupMemberRole)changedRole {
    _changedRole = changedRole;
    if (self.groupRoleChanged) {
        self.groupRoleChanged(changedRole);
    }
}

#pragma mark - TUIKitNotification
- (void)registerTUIKitNotification {
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
    [[V2TIMManager sharedInstance] addGroupListener:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageStatusChanged:)
                                                 name:TUIKitNotification_onMessageStatusChanged
                                               object:nil];
}

- (void)onMessageStatusChanged:(NSNotification *)notification {
    V2TIMMessage *targetMsg = notification.object;
    NSString *msgId = targetMsg.msgID;
    TUIMessageCellData *uiMsg = nil;
    BOOL isMatch = NO;
    for (uiMsg in self.uiMsgs) {
        if ([uiMsg.msgID isEqualToString:msgId]) {
            [self.dataSource dataProviderDataSourceWillChange:self];
            NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
            [self.dataSource dataProviderDataSourceChange:self withType:TUIMessageBaseDataProviderDataSourceChangeTypeReload atIndex:index animation:YES];
            [self.dataSource dataProviderDataSourceDidChange:self];
            isMatch = YES;
            break;
        }
    }
    if (!isMatch) {
        // Need insert UI Message
        [self onRecvNewMessage:targetMsg];
    }
}

#pragma mark - V2TIMAdvancedMsgListener
- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    // immsg -> uimsg
    NSMutableArray *newUIMsgs = [self transUIMsgFromIMMsg:@[ msg ]];
    if (newUIMsgs.count == 0) {
        return;
    }

    TUIMessageCellData *newUIMsg = newUIMsgs.lastObject;
    newUIMsg.source = Msg_Source_OnlinePush;

    if ([newUIMsg isKindOfClass:TUITypingStatusCellData.class]) {
        if (![TUIChatConfig defaultConfig].enableTypingStatus) {
            return;
        }

        TUITypingStatusCellData *stastusData = (TUITypingStatusCellData *)newUIMsg;

        if (!NSThread.isMainThread) {
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
              @strongify(self);
              [self dealTypingByStatusCellData:stastusData];
            });
            return;
        } else {
            [self dealTypingByStatusCellData:stastusData];
        }

        return;
    }

    @weakify(self);
    [self preProcessMessage:newUIMsgs
                   callback:^{
                     @strongify(self);
                     [self.dataSource dataProviderDataSourceWillChange:self];
                     @autoreleasepool {
                         // Check if this is a TUIChatbotMessageCellData and remove AI typing placeholder if exists
                         if ([newUIMsg isKindOfClass:NSClassFromString(@"TUIChatbotMessageCellData")]) {
                             NSString *conversationID = self.conversationModel.conversationID;
                             TUIMessageCellData *currentAITypingMessage = [[TUIAIPlaceholderTypingMessageManager sharedInstance]
                                                                           getAIPlaceholderTypingMessageForConversation:conversationID];
                             if (currentAITypingMessage) {
                                 // Find the index of the AI typing message before removing it
                                 NSInteger aiTypingIndex = [self.uiMsgs_ indexOfObject:currentAITypingMessage];
                                 if (aiTypingIndex != NSNotFound) {
                                     // Remove the AI typing placeholder message
                                     [self removeUIMsg:currentAITypingMessage];
                                     // Notify data source about the deletion
                                     [self.dataSource dataProviderDataSourceChange:self
                                                                          withType:TUIMessageBaseDataProviderDataSourceChangeTypeDelete
                                                                           atIndex:aiTypingIndex
                                                                         animation:YES];
                                 }
                                 // Remove from global manager
                                 [[TUIAIPlaceholderTypingMessageManager sharedInstance] removeAIPlaceholderTypingMessageForConversation:conversationID];
                             }
                         }
                         
                         for (TUIMessageCellData *uiMsg in newUIMsgs) {
                             [self addUIMsg:uiMsg];
                             [self.dataSource dataProviderDataSourceChange:self
                                                                  withType:TUIMessageBaseDataProviderDataSourceChangeTypeInsert
                                                                   atIndex:(self.uiMsgs_.count - 1)
                                                                 animation:YES];
                         }
                     }
                     [self.dataSource dataProviderDataSourceDidChange:self];

                     if ([self.dataSource respondsToSelector:@selector(dataProvider:ReceiveNewUIMsg:)]) {
                         /**
                          * Note that firstObject cannot be taken here, firstObject may be SystemMessageCellData that displays system time
                          */
                         [self.dataSource dataProvider:self ReceiveNewUIMsg:newUIMsgs.lastObject];
                     }
                   }];
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs {
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = msgs.count - 1; k >= 0; --k) {
        V2TIMMessage *msg = msgs[k];
        /**
         * Messages that are not the current session, ignore them directly
         */
        if (![msg.userID isEqualToString:self.conversationModel.userID] && ![msg.groupID isEqualToString:self.conversationModel.groupID]) {
            continue;
        }

        TUIMessageCellData *cellData = nil;
        /**
         * Determine whether it is a custom message outside the component
         */
        if ([self.dataSource respondsToSelector:@selector(dataProvider:CustomCellDataFromNewIMMessage:)]) {
            cellData = [self.dataSource dataProvider:self CustomCellDataFromNewIMMessage:msg];
        }

        /**
         * Determine whether it is a component internal message
         */
        if (!cellData) {
            cellData = [self.class getCellData:msg];
        }
        if (cellData) {
            TUIMessageCellData *dateMsg = [self getSystemMsgFromDate:msg.timestamp];
            if (dateMsg) {
                if (self.mergeAdjacentMsgsFromTheSameSender) {
                    dateMsg.showName = NO;
                }
                self.msgForDate = msg;
                [uiMsgs addObject:dateMsg];
            }
            if (self.mergeAdjacentMsgsFromTheSameSender) {
                cellData.showName = NO;
            }
            [uiMsgs addObject:cellData];
        }
    }
    return uiMsgs;
}

/// Received message read receipts, both in group and c2c conversation.
- (void)onRecvMessageReadReceipts:(NSArray<V2TIMMessageReceipt *> *)receiptList {
    if (receiptList.count == 0) {
        NSLog(@"group receipt data is empty, ignore");
        return;
    }
    if (![self.dataSource respondsToSelector:@selector(dataProvider:ReceiveReadMsgWithGroupID:msgID:readCount:unreadCount:)]) {
        NSLog(@"data source can not respond to protocol, ignore");
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (V2TIMMessageReceipt *receipt in receiptList) {
        [dict setObject:receipt forKey:receipt.msgID];
    }
    // update TUIMessageCellData readCount/unreadCount
    for (TUIMessageCellData *data in self.uiMsgs) {
        if ([dict.allKeys containsObject:data.innerMessage.msgID]) {
            V2TIMMessageReceipt *receipt = dict[data.innerMessage.msgID];
            data.messageReceipt = receipt;
            if ([self.dataSource respondsToSelector:@selector(dataProvider:ReceiveReadMsgWithGroupID:msgID:readCount:unreadCount:)]) {
                [self.dataSource dataProvider:self
                    ReceiveReadMsgWithGroupID:receipt.groupID
                                        msgID:receipt.msgID
                                    readCount:receipt.readCount
                                  unreadCount:receipt.unreadCount];
            }
        }
    }
}
- (void)onRecvMessageRevoked:(NSString *)msgID operateUser:(V2TIMUserFullInfo *)operateUser reason:(NSString *)reason {
    @weakify(self);
    [TUITool dispatchMainAsync:^{
      @strongify(self);
      TUIMessageCellData *uiMsg = nil;
      for (uiMsg in self.uiMsgs) {
          if ([uiMsg.msgID isEqualToString:msgID]) {
              [self.dataSource dataProviderDataSourceWillChange:self];
              NSUInteger index = [self.uiMsgs indexOfObject:uiMsg];
              TUISystemMessageCellData *revokeCellData = (TUISystemMessageCellData *)[self.class getRevokeCellData:uiMsg.innerMessage];
              revokeCellData.content = [self.class getRevokeDispayString:uiMsg.innerMessage operateUser:operateUser reason:reason];
              if(![operateUser.userID isEqualToString:uiMsg.innerMessage.sender]) {
                  //Super User revoke
                  revokeCellData.supportReEdit = NO;
              }
              [self replaceUIMsg:revokeCellData atIndex:index];
              [self.dataSource dataProviderDataSourceChange:self withType:TUIMessageBaseDataProviderDataSourceChangeTypeReload atIndex:index animation:YES];
              [self.dataSource dataProviderDataSourceDidChange:self];
              break;
          }
      }

      if ([self.dataSource respondsToSelector:@selector(dataProvider:ReceiveRevokeUIMsg:)]) {
          [self.dataSource dataProvider:self ReceiveRevokeUIMsg:uiMsg];
      }
    }];
}

- (void)onRecvMessageModified:(V2TIMMessage *)msg {
    V2TIMMessage *imMsg = msg;
    if (imMsg == nil || ![imMsg isKindOfClass:V2TIMMessage.class]) {
        return;
    }

    @weakify(self);
    for (TUIMessageCellData *uiMsg in self.uiMsgs) {
        if ([uiMsg.msgID isEqualToString:imMsg.msgID]) {
            if ([uiMsg customReloadCellWithNewMsg:imMsg]) {
                return;
            }
            NSMutableArray *newUIMsgs = [self transUIMsgFromIMMsg:@[ imMsg ]];
            if (newUIMsgs.count == 0) {
                return;
            }
            /**
             * Note that firstObject cannot be taken here, firstObject may be SystemMessageCellData that displays system time
             */
            TUIMessageCellData *newUIMsg = newUIMsgs.lastObject;
            newUIMsg.messageReceipt = uiMsg.messageReceipt;
            [self preProcessMessage:@[newUIMsg] callback:^{
                @strongify(self);
                NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
                if (index < self.uiMsgs.count) {
                    [self.dataSource dataProviderDataSourceWillChange:self];
                    [self replaceUIMsg:newUIMsg atIndex:index];
                    [self.dataSource dataProviderDataSourceChange:self
                                                         withType:TUIMessageBaseDataProviderDataSourceChangeTypeReload
                                                          atIndex:index
                                                        animation:YES];
                    [self.dataSource dataProviderDataSourceDidChange:self];
                }
            }];
            return;
        }
    }
}

- (void)dealTypingByStatusCellData:(TUITypingStatusCellData *)stastusData {
    if (1 == stastusData.typingStatus) {
        // The timer is retimed upon receipt of the notification from the other party's input
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetTypingStatus) object:nil];

        self.conversationModel.otherSideTyping = YES;
        // If the other party does not continue typing, end the status every 5 seconds
        [self performSelector:@selector(resetTypingStatus) withObject:nil afterDelay:5.0];
    } else {
        self.conversationModel.otherSideTyping = NO;
    }
}

- (void)resetTypingStatus {
    self.conversationModel.otherSideTyping = NO;
}

#pragma mark - Msgs
- (void)loadMessageSucceedBlock:(void (^)(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TUIMessageCellData *> *newMsgs))succeedBlock
                      FailBlock:(V2TIMFail)failBlock {
    if (self.isLoadingData || self.isNoMoreMsg) {
        failBlock(ERR_SUCC, @"refreshing");
        return;
    }
    self.isLoadingData = YES;

    @weakify(self);
    if (self.conversationModel.userID.length > 0) {
        [[V2TIMManager sharedInstance] getC2CHistoryMessageList:self.conversationModel.userID
            count:self.pageCount
            lastMsg:self.lastMsg
            succ:^(NSArray<V2TIMMessage *> *msgs) {
              @strongify(self);
              if (msgs.count != 0) {
                  self.lastMsg = msgs[msgs.count - 1];
              }
              [self loadMessages:msgs SucceedBlock:succeedBlock];
            }
            fail:^(int code, NSString *desc) {
              @strongify(self);
              self.isLoadingData = NO;
              if (failBlock) {
                  failBlock(code, desc);
              }
            }];
    } else if (self.conversationModel.groupID.length > 0) {
        [[V2TIMManager sharedInstance] getGroupHistoryMessageList:self.conversationModel.groupID
            count:self.pageCount
            lastMsg:self.lastMsg
            succ:^(NSArray<V2TIMMessage *> *msgs) {
              @strongify(self);
              if (msgs.count != 0) {
                  self.lastMsg = msgs[msgs.count - 1];
              }
              [self loadMessages:msgs SucceedBlock:succeedBlock];
            }
            fail:^(int code, NSString *desc) {
              @strongify(self);
              self.isLoadingData = NO;
              if (failBlock) {
                  failBlock(code, desc);
              }
            }];
    }
}

- (void)loadMessages:(NSArray<V2TIMMessage *> *)msgs
        SucceedBlock:(void (^)(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TUIMessageCellData *> *newMsgs))succeedBlock {
    NSMutableArray<TUIMessageCellData *> *uiMsgs = [self transUIMsgFromIMMsg:msgs];
    if (uiMsgs.count == 0) {
        return;
    }
    @weakify(self);
    [self preProcessMessage:uiMsgs
                   callback:^{
                     @strongify(self);
                     if (msgs.count < self.pageCount) {
                         self.isNoMoreMsg = YES;
                     }
                     if (uiMsgs.count != 0) {
                         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
                         [self insertUIMsgs:uiMsgs atIndexes:indexSet];
                     }

                     self.isLoadingData = NO;
                     if (succeedBlock) {
                         succeedBlock(self.isFirstLoad, self.isNoMoreMsg, uiMsgs);
                     }
                     self.isFirstLoad = NO;
                   }];
}

- (void)preProcessMessage:(NSArray<TUIMessageCellData *> *)uiMsgs callback:(void (^)(void))callback {
    // Synchronous message processing: Messages can be preprocessed here, and complex and time-consuming operations are not recommended.
    [self processMessageSync:uiMsgs callback:callback];

    // Asynchronous processing of messages: Please handle complex time-consuming operations in this function and update them in the form of reload Cell.
    [self processMessageAsync:uiMsgs];
}

- (void)processMessageSync:(NSArray<TUIMessageCellData *> *)uiMsgs callback:(void (^)(void))callback {
    if (callback) {
        callback();
    }
}

- (void)processMessageAsync:(NSArray<TUIMessageCellData *> *)uiMsgs {
    __weak typeof(self) weakSelf = self;

    [self getReactFromMessage:uiMsgs];

    [self requestForAdditionalUserInfo:uiMsgs
                              callback:^{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                  [weakSelf.dataSource dataProviderDataSourceWillChange:weakSelf];
                                  for (TUIMessageCellData *uiMsg in uiMsgs) {
                                      NSArray *userIDList = [weakSelf getUserIDListForAdditionalUserInfo:@[ uiMsg ]];
                                      if (userIDList.count == 0) {
                                          continue;
                                      }
                                      NSUInteger index = [weakSelf.uiMsgs indexOfObject:uiMsg];
                                      if (index != NSNotFound) {
                                        [weakSelf.dataSource dataProvider:weakSelf onRemoveHeightCache:uiMsg];
                                        [weakSelf.dataSource dataProviderDataSourceChange:weakSelf
                                                                                 withType:TUIMessageBaseDataProviderDataSourceChangeTypeReload
                                                                                  atIndex:index
                                                                                animation:YES];                                          
                                      }
                                  }
                                  [weakSelf.dataSource dataProviderDataSourceDidChange:weakSelf];
                                });

                                [weakSelf processQuoteMessage:uiMsgs];
                              }];
}

- (void)getReactFromMessage:(NSArray<TUIMessageCellData *> *)uiMsgs {
    if (uiMsgs.count == 0) {
        return;
    }
    // fetch react
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TUIKitFetchReactNotification" object:uiMsgs];
}

- (void)requestForAdditionalUserInfo:(NSArray<TUIMessageCellData *> *)uiMsgs callback:(void (^)(void))callback {
    NSArray *userIDList = [self getUserIDListForAdditionalUserInfo:uiMsgs];
    if (userIDList.count == 0) {
        if (callback) {
            callback();
        }
        return;
    }

    [self requestForUserDetailsInfo:userIDList
                           callback:^(NSDictionary<NSString *, TUIRelationUserModel *> *result) {
                             for (TUIMessageCellData *cellData in uiMsgs) {
                                 NSMutableDictionary *additionalUserInfoResult = [NSMutableDictionary dictionary];
                                 NSArray *userIDList = [self getUserIDListForAdditionalUserInfo:@[ cellData ]];
                                 for (NSString *userID in userIDList) {
                                     TUIRelationUserModel *userInfo = [result objectForKey:userID];
                                     if (userID.length > 0 && userInfo) {
                                         additionalUserInfoResult[userID] = userInfo;
                                     }
                                 }
                                 cellData.additionalUserInfoResult = additionalUserInfoResult;
                             }
                             if (callback) {
                                 callback();
                             }
                           }];
}

- (void)requestForUserDetailsInfo:(NSArray *)userIDList callback:(void (^)(NSDictionary<NSString *, TUIRelationUserModel *> *))callback {
    if (callback == nil) {
        return;
    }

    NSMutableDictionary<NSString *, TUIRelationUserModel *> *result = [NSMutableDictionary dictionary];
    if (self.conversationModel.groupID.length > 0) {
        [[V2TIMManager sharedInstance] getGroupMembersInfo:self.conversationModel.groupID
            memberList:userIDList
            succ:^(NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
              [memberList enumerateObjectsUsingBlock:^(V2TIMGroupMemberFullInfo *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                if (obj.userID.length > 0) {
                    TUIRelationUserModel *userInfo = [[TUIRelationUserModel alloc] init];
                    userInfo.userID = obj.userID;
                    userInfo.nickName = obj.nickName;
                    userInfo.friendRemark = obj.friendRemark;
                    userInfo.nameCard = obj.nameCard;
                    userInfo.faceURL = obj.faceURL;
                    [result setObject:userInfo forKey:userInfo.userID];
                }
              }];
              callback(result);
            }
            fail:^(int code, NSString *desc) {
              callback(result);
            }];
    } else {
        [V2TIMManager.sharedInstance getFriendsInfo:userIDList
            succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
              for (V2TIMFriendInfoResult *item in resultList) {
                  if (item.friendInfo && item.friendInfo.userID.length > 0) {
                      TUIRelationUserModel *userInfo = [[TUIRelationUserModel alloc] init];
                      userInfo.userID = item.friendInfo.userID;
                      userInfo.nickName = item.friendInfo.userFullInfo.nickName;
                      userInfo.friendRemark = item.friendInfo.friendRemark;
                      userInfo.faceURL = item.friendInfo.userFullInfo.faceURL;
                      [result setObject:userInfo forKey:userInfo.userID];
                  }
              }
              callback(result);
            }
            fail:^(int code, NSString *desc) {
              callback(result);
            }];
    }
}

- (NSArray<NSString *> *)getUserIDListForAdditionalUserInfo:(NSArray<TUIMessageCellData *> *)uiMsgs {
    NSMutableSet *userIDSet = [NSMutableSet set];

    // Built-in
    for (TUIMessageCellData *cellData in uiMsgs) {
        if (![cellData.messageModifyReplies isKindOfClass:NSArray.class] || cellData.messageModifyReplies.count == 0) {
            continue;
        }
        [cellData.messageModifyReplies enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
          if (obj && [obj isKindOfClass:NSDictionary.class]) {
              NSDictionary *dic = (NSDictionary *)obj;
              if (IS_NOT_EMPTY_NSSTRING(dic[@"messageSender"])) {
                  [userIDSet addObject:dic[@"messageSender"]];
              }
          }
        }];
    }

    // Get userid from cellData which override the -requestForAdditionalUserInfo method
    for (TUIMessageCellData *cellData in uiMsgs) {
        if ([cellData respondsToSelector:@selector(requestForAdditionalUserInfo)]) {
            NSArray *array = [cellData requestForAdditionalUserInfo];
            if (array && array.count > 0) {
                [userIDSet addObjectsFromArray:array];
            }
        }
    }

    NSArray *userIDList = userIDSet.allObjects;
    return userIDList;
}

- (void)processQuoteMessage:(NSArray<TUIMessageCellData *> *)uiMsgs {
    // Subclasses implement this method
    return;
}

- (void)sendUIMsg:(TUIMessageCellData *)uiMsg
    toConversation:(TUIChatConversationModel *)conversationData
     willSendBlock:(void (^)(BOOL isReSend, TUIMessageCellData *dateUIMsg))willSendBlock
         SuccBlock:(nullable V2TIMSucc)succ
         FailBlock:(nullable V2TIMFail)fail {
    [self preProcessMessage:@[ uiMsg ]
                   callback:^{
                     [TUITool dispatchMainAsync:^{
                       V2TIMMessage *imMsg = uiMsg.innerMessage;
                       TUIMessageCellData *placeholderCellData = uiMsg.placeHolderCellData;
                       TUIMessageCellData *dateMsg = nil;
                       BOOL isReSent = NO;
                       if (uiMsg.status == Msg_Status_Init) {
                           // New message
                           dateMsg = [self getSystemMsgFromDate:imMsg.timestamp];
                       } else if (imMsg) {
                           // Re-sent
                           isReSent = YES;
                           dateMsg = [self getSystemMsgFromDate:[NSDate date]];
                       } else {
                           if (fail) {
                               fail(ERR_INVALID_PARAMETERS, @"Unknown message state");
                           }
                           return;
                       }

                       imMsg.isExcludedFromUnreadCount = [TUIConfig defaultConfig].isExcludedFromUnreadCount;
                       imMsg.isExcludedFromLastMessage = [TUIConfig defaultConfig].isExcludedFromLastMessage;

                       // Update sender
                       uiMsg.identifier = [TUILogin getUserID];

                       [self.dataSource dataProviderDataSourceWillChange:self];

                       // Handle data
                       if (isReSent) {
                           NSInteger row = [self.uiMsgs indexOfObject:uiMsg];
                           [self removeUImsgAtIndex:row];
                           [self.dataSource dataProviderDataSourceChange:self
                                                                withType:TUIMessageBaseDataProviderDataSourceChangeTypeDelete
                                                                 atIndex:row
                                                               animation:YES];
                       }
                      if (placeholderCellData) {
                          NSInteger row = [self.uiMsgs indexOfObject:placeholderCellData];
                          if (row != NSNotFound) {
                              [self replaceUIMsg:uiMsg atIndex:row];
                              [self.dataSource dataProviderDataSourceChange:self
                                                                   withType:TUIMessageBaseDataProviderDataSourceChangeTypeReload
                                                                    atIndex:row
                                                                  animation:NO];
                          }
                      }
                      else {
                          if (dateMsg) {
                              [self addUIMsg:dateMsg];
                              [self.dataSource dataProviderDataSourceChange:self
                                                                   withType:TUIMessageBaseDataProviderDataSourceChangeTypeInsert
                                                                    atIndex:(self.uiMsgs.count - 1)
                                                                  animation:YES];
                          }
                          [self addUIMsg:uiMsg];
                          [self.dataSource dataProviderDataSourceChange:self
                                                               withType:TUIMessageBaseDataProviderDataSourceChangeTypeInsert
                                                                atIndex:(self.uiMsgs.count - 1)
                                                              animation:YES];
                      }

                       [self.dataSource dataProviderDataSourceDidChange:self];

                       if (willSendBlock) {
                           willSendBlock(isReSent, dateMsg);
                       }

                       if (dateMsg) {
                           self.msgForDate = imMsg;
                       }

                       TUISendMessageAppendParams *appendParams = [[TUISendMessageAppendParams alloc] init];
                       appendParams.isSendPushInfo = YES;
                       appendParams.isOnlineUserOnly = NO;
                       appendParams.priority = V2TIM_PRIORITY_NORMAL;
                       uiMsg.msgID = [self.class sendMessage:imMsg
                           toConversation:conversationData
                           appendParams:appendParams
                           Progress:^(uint32_t progress) {
                             [TUIMessageProgressManager.shareManager appendUploadProgress:uiMsg.msgID progress:progress];
                           }

                           SuccBlock:^{
                           [TUIMessageProgressManager.shareManager appendUploadProgress:uiMsg.msgID progress:100];
                            if (succ) {
                                 succ();
                             }
                             [TUIMessageProgressManager.shareManager notifyMessageSendingResult:uiMsg.msgID result:TUIMessageSendingResultTypeSucc];
                           }
                           FailBlock:^(int code, NSString *desc) {
                             if (fail) {
                                 fail(code, desc);
                             }
                             [TUIMessageProgressManager.shareManager notifyMessageSendingResult:uiMsg.msgID result:TUIMessageSendingResultTypeFail];
                           }];
                     }];
                   }];
}

- (void)revokeUIMsg:(TUIMessageCellData *)uiMsg SuccBlock:(nullable V2TIMSucc)succ FailBlock:(nullable V2TIMFail)fail {
    V2TIMMessage *imMsg = uiMsg.innerMessage;
    if (imMsg == nil) {
        if (fail) {
            fail(ERR_INVALID_PARAMETERS, @"cellData.innerMessage is nil");
        }
        return;
    }
    NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
    if (index == NSNotFound) {
        if (fail) {
            fail(ERR_INVALID_PARAMETERS, @"not found cellData in uiMsgs");
        }
        return;
    }

    @weakify(self);
    [self.class revokeMessage:imMsg
                         succ:^{
                           @strongify(self);
                           if (succ) {
                               succ();
                           }
                         }
                         fail:fail];
}

- (void)deleteUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs SuccBlock:(nullable V2TIMSucc)succ FailBlock:(nullable V2TIMFail)fail {
}

- (void)addUIMsg:(TUIMessageCellData *)cellData {
    [self.uiMsgs_ addObject:cellData];
    if (self.mergeAdjacentMsgsFromTheSameSender) {
        [self.class updateUIMsgStatus:cellData uiMsgs:self.uiMsgs_];
    }
}

- (void)removeUIMsg:(TUIMessageCellData *)cellData {
    if (cellData) {
        [self.uiMsgs_ removeObject:cellData];
        if ([self.dataSource respondsToSelector:@selector(dataProvider:onRemoveHeightCache:)]) {
            [self.dataSource dataProvider:self onRemoveHeightCache:cellData];
        }
        if (self.mergeAdjacentMsgsFromTheSameSender) {
            [self.class updateUIMsgStatus:cellData uiMsgs:self.uiMsgs_];
        }
    }
}
- (void)sendPlaceHolderUIMessage:(TUIMessageCellData *)placeHolderCellData {
    V2TIMMessage *imMsg = placeHolderCellData.innerMessage;
    TUIMessageCellData *dateMsg = nil;
    if (placeHolderCellData.status == Msg_Status_Init) {
        // New message
        dateMsg = [self getSystemMsgFromDate:imMsg.timestamp];
    }

    [self.dataSource dataProviderDataSourceWillChange:self];

    if (dateMsg) {
        [self addUIMsg:dateMsg];
        [self.dataSource dataProviderDataSourceChange:self
                                             withType:TUIMessageBaseDataProviderDataSourceChangeTypeInsert
                                              atIndex:(self.uiMsgs.count - 1)
                                            animation:YES];
    }

    
    [self addUIMsg:placeHolderCellData];
    [self.dataSource dataProviderDataSourceChange:self
                                         withType:TUIMessageBaseDataProviderDataSourceChangeTypeInsert
                                          atIndex:(self.uiMsgs.count - 1)
                                        animation:YES];
    [self.dataSource dataProviderDataSourceDidChange:self];

}


- (void)insertUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs atIndexes:(NSIndexSet *)indexes {
    [self.uiMsgs_ insertObjects:uiMsgs atIndexes:indexes];
    if (self.mergeAdjacentMsgsFromTheSameSender) {
        for (TUIMessageCellData *cellData in uiMsgs) {
            [self.class updateUIMsgStatus:cellData uiMsgs:self.uiMsgs_];
        }
    }
}

- (void)addUIMsgs:(NSArray<TUIMessageCellData *> *)uiMsgs {
    [self.uiMsgs_ addObjectsFromArray:uiMsgs];
    if (self.mergeAdjacentMsgsFromTheSameSender) {
        for (TUIMessageCellData *cellData in uiMsgs) {
            [self.class updateUIMsgStatus:cellData uiMsgs:self.uiMsgs_];
        }
    }
}

- (void)removeUIMsgList:(NSArray<TUIMessageCellData *> *)cellDatas {
    for (TUIMessageCellData *uiMsg in cellDatas) {
        [self removeUIMsg:uiMsg];
    }
}

- (void)removeUImsgAtIndex:(NSUInteger)index {
    if (index < self.uiMsgs.count) {
        TUIMessageCellData *msg = self.uiMsgs[index];
        [self removeUIMsg:msg];
    }
}

- (void)clearUIMsgList {
    NSArray *clearArray = [NSArray arrayWithArray:self.uiMsgs];
    [self removeUIMsgList:clearArray];
    self.msgForDate = nil;
    self.uiMsgs_ = nil;
}

- (void)replaceUIMsg:(TUIMessageCellData *)cellData atIndex:(NSUInteger)index {
    if (index < self.uiMsgs.count) {
        TUIMessageCellData *oldMsg = self.uiMsgs[index];
        if ([self.dataSource respondsToSelector:@selector(dataProvider:onRemoveHeightCache:)]) {
            [self.dataSource dataProvider:self onRemoveHeightCache:oldMsg];
        }
        
        [self.uiMsgs_ replaceObjectAtIndex:index withObject:cellData];
        
        if (self.mergeAdjacentMsgsFromTheSameSender) {
            [self.class updateUIMsgStatus:cellData uiMsgs:self.uiMsgs_];
        }
    }
}

- (void)sendLatestMessageReadReceipt {
    [self sendMessageReadReceiptAtIndexes:@[ @(self.uiMsgs.count - 1) ]];
}

- (void)sendMessageReadReceiptAtIndexes:(NSArray *)indexes {
    if (indexes.count == 0) {
        NSLog(@"sendMessageReadReceipt, but indexes is empty, ignore");
        return;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (NSNumber *i in indexes) {
        if ([i intValue] < 0 || [i intValue] >= self.uiMsgs_.count) {
            continue;
        }
        TUIMessageCellData *data = self.uiMsgs_[[i intValue]];
        if (data.innerMessage.isSelf) {
            continue;
        }
        if (data.innerMessage == nil) {
            continue;
        }
        // Use Set to avoid sending duplicate element to SDK
        if (data.msgID.length > 0) {
            if ([self.sentReadGroupMsgSet containsObject:data.msgID]) {
                continue;
            } else {
                [self.sentReadGroupMsgSet addObject:data.msgID];
            }
        }
        // If needReadReceipt is NO, receiver won't send message read receipt
        if (!data.innerMessage.needReadReceipt) {
            continue;
        }
        [array addObject:data.innerMessage];
    }
    if (array.count == 0) {
        return;
    }
    [self.class sendMessageReadReceipts:array];
}

- (NSInteger)getIndexOfMessage:(NSString *)msgID {
    if (msgID.length == 0) {
        return -1;
    }
    for (int i = 0; i < self.uiMsgs.count; i++) {
        TUIMessageCellData *data = self.uiMsgs[i];
        if ([data.msgID isEqualToString:msgID]) {
            return i;
        }
    }
    return -1;
}

- (nullable TUIMessageCellData *)getSystemMsgFromDate:(NSDate *)date {
    if (self.msgForDate == nil || fabs([date timeIntervalSinceDate:self.msgForDate.timestamp]) > MaxDateMessageDelay) {
        TUIMessageCellData *system = [self.class getSystemMsgFromDate:date];
        return system;
    }
    return nil;
}

+ (void)updateUIMsgStatus:(TUIMessageCellData *)cellData uiMsgs:(NSArray *)uiMsgs {
    if (![uiMsgs containsObject:cellData]) {
        return;
    }
    NSInteger index = [uiMsgs indexOfObject:cellData];
    TUIMessageCellData *data = uiMsgs[index];

    TUIMessageCellData *lastData = nil;
    if (index >= 1) {
        lastData = uiMsgs[index - 1];
        if (![lastData isKindOfClass:[TUISystemMessageCellData class]]) {
            if ([lastData.identifier isEqualToString:data.identifier] &&
                ![data isKindOfClass:[TUISystemMessageCellData class]] &&(lastData.direction == data.direction)) {
                lastData.sameToNextMsgSender = YES;
                lastData.showAvatar = NO;
            } else {
                lastData.sameToNextMsgSender = NO;
                lastData.showAvatar = (lastData.direction == MsgDirectionIncoming ? YES : NO);
            }
        }
    }

    TUIMessageCellData *nextData = nil;
    if (index < uiMsgs.count - 1) {
        nextData = uiMsgs[index + 1];
        if ([data.identifier isEqualToString:nextData.identifier] &&(data.direction == nextData.direction)) {
            data.sameToNextMsgSender = YES;
            data.showAvatar = NO;
        } else {
            data.sameToNextMsgSender = NO;
            data.showAvatar = (data.direction == MsgDirectionIncoming ? YES : NO);
        }
    }

    if (index == uiMsgs.count - 1) {
        data.showAvatar = (data.direction == MsgDirectionIncoming ? YES : NO);
        data.sameToNextMsgSender = NO;
    }
}

- (void)getPinMessageList {
    if (self.conversationModel.groupID.length > 0) {
        __weak typeof(self) weakSelf = self;
        [V2TIMManager.sharedInstance getPinnedGroupMessageList:self.conversationModel.groupID succ:^(NSArray<V2TIMMessage *> *messageList) {
            weakSelf.groupPinList = [NSMutableArray arrayWithArray:messageList];
            if (weakSelf.pinGroupMessageChanged) {
                weakSelf.pinGroupMessageChanged(weakSelf.groupPinList);
            }
        } fail:^(int code, NSString *desc) {
            weakSelf.groupPinList = [NSMutableArray array];
            if (weakSelf.pinGroupMessageChanged) {
                weakSelf.pinGroupMessageChanged(weakSelf.groupPinList);
            }
        }];
    }

}
- (void)loadGroupInfo:(dispatch_block_t)callback {
    if (self.conversationModel.groupID.length == 0) {
        if (callback) {
            callback();
        }
        return;
    }
    __weak typeof(self) weakSelf = self;

    [[V2TIMManager sharedInstance] getGroupsInfo:@[ self.conversationModel.groupID ]
        succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
            if (groupResultList.count == 1) {
                V2TIMGroupInfo *info = groupResultList[0].info;
                weakSelf.groupInfo = info;
            }
            if (callback) {
                callback();
            }
        }
        fail:^(int code, NSString *msg) {
          [TUITool makeToastError:code msg:msg];
        }];
}
- (void)getSelfInfoInGroup:(dispatch_block_t)callback {
    NSString *loginUserID = [[V2TIMManager sharedInstance] getLoginUser];
    if (loginUserID.length == 0) {
        if (callback) {
            callback();
        }
        return;
    }
    if (!self.conversationModel.enableRoom) {
        if (callback) {
            callback();
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getGroupMembersInfo:self.conversationModel.groupID
        memberList:@[ loginUserID ]
        succ:^(NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
          for (V2TIMGroupMemberFullInfo *item in memberList) {
              if ([item.userID isEqualToString:loginUserID]) {
                  weakSelf.groupSelfInfo = item;
                  if ([weakSelf.groupInfo.owner isEqualToString:loginUserID]) {
                      weakSelf.changedRole = V2TIM_GROUP_MEMBER_ROLE_SUPER;
                  }
                  else {
                      weakSelf.changedRole = item.role;
                  }
                  break;
              }
          }
          if (callback) {
              callback();
          }
        }
        fail:^(int code, NSString *desc) {
          [TUITool makeToastError:code msg:desc];
          if (callback) {
              callback();
          }
        }];
}

- (BOOL)isCurrentUserRoleSuperAdminInGroup {
    if (self.changedRole != V2TIM_GROUP_MEMBER_UNDEFINED) {
        return (self.changedRole == V2TIM_GROUP_MEMBER_ROLE_ADMIN || self.changedRole == V2TIM_GROUP_MEMBER_ROLE_SUPER);
    }
    return ([self.groupInfo.owner isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]] ||self.groupSelfInfo.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN || self.groupSelfInfo.role == V2TIM_GROUP_MEMBER_ROLE_SUPER) ;
}

- (BOOL)isCurrentMessagePin:(NSString *)msgID {
    BOOL isPin = NO;
    for (V2TIMMessage *msg in self.groupPinList) {
        if ([msg.msgID isEqualToString:msgID]) {
            isPin = YES;
            break;
        }
    }
    return isPin;
}

- (void)pinGroupMessage:(NSString *)groupID
                message:(V2TIMMessage *)message
               isPinned:(BOOL)isPinned
                   succ:(V2TIMSucc)succ
                   fail:(V2TIMFail)fail {
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance pinGroupMessage:groupID message:message isPinned:isPinned succ:^{
        if (isPinned) {
            //del from changed

        }
        else {
            //add from changed
            
        }
        

        if (succ) {
            succ();
        }
    } fail:^(int code, NSString *desc) {
        if (fail) {
            fail(code,desc);
        }
    }];
}

- (void)onGroupMessagePinned:(NSString *)groupID message:(V2TIMMessage *)message isPinned:(BOOL)isPinned opUser:(V2TIMGroupMemberInfo *)opUser {
    if (![groupID isEqualToString:self.conversationModel.groupID]) {
        return;
    }
    if (isPinned) {
        //add
        [self.groupPinList addObject:message];
    }
    else {
        //del
        NSMutableArray *formatArray = [NSMutableArray arrayWithArray:self.groupPinList];
        for (V2TIMMessage *msg in formatArray) {
            if ([msg.msgID isEqualToString:message.msgID]) {
                [self.groupPinList removeObject:msg];
                break;
            }
        }

    }
    if (self.pinGroupMessageChanged) {
        self.pinGroupMessageChanged(self.groupPinList);
    }
}
- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray<V2TIMGroupChangeInfo *> *)changeInfoList {
    if (![groupID isEqualToString:self.conversationModel.groupID]) {
        return;
    }
    
    for (V2TIMGroupChangeInfo *changeInfo in changeInfoList) {
        if (changeInfo.type == V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER) {
            NSString *ownerID =  changeInfo.value;
           
            if ([ownerID isEqualToString:[TUILogin getUserID]]) {
                self.changedRole = V2TIM_GROUP_MEMBER_ROLE_SUPER;
            }
            else {
                if (self.changedRole ==V2TIM_GROUP_MEMBER_ROLE_SUPER) {
                    self.changedRole = V2TIM_GROUP_MEMBER_ROLE_MEMBER;
                }
            }
            return;
        }
    }
}
- (void)onGrantAdministrator:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray <V2TIMGroupMemberInfo *> *)memberList {
    if (![groupID isEqualToString:self.conversationModel.groupID]) {
        return;
    }
    for (V2TIMGroupMemberInfo *changeInfo in memberList) {
        if (changeInfo.userID == [TUILogin getUserID]) {
            self.changedRole = V2TIM_GROUP_MEMBER_ROLE_ADMIN;
            return;
        }
    }
}

- (void)onRevokeAdministrator:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray <V2TIMGroupMemberInfo *> *)memberList {
    if (![groupID isEqualToString:self.conversationModel.groupID]) {
        return;
    }
    for (V2TIMGroupMemberInfo *changeInfo in memberList) {
        if (changeInfo.userID == [TUILogin getUserID]) {
            self.changedRole = V2TIM_GROUP_MEMBER_ROLE_MEMBER;
            return;
        }
    }
}

@end

@implementation TUIMessageBaseDataProvider (IMSDK)

static const int kOfflinePushVersion = 1;

+ (NSString *)sendMessage:(V2TIMMessage *)message
           toConversation:(TUIChatConversationModel *)conversationData
             appendParams:(TUISendMessageAppendParams *)appendParams
                 Progress:(nullable V2TIMProgress)progress
                SuccBlock:(nullable V2TIMSucc)succ
                FailBlock:(nullable V2TIMFail)fail {
    NSString *userID = conversationData.userID;
    NSString *groupID = conversationData.groupID;
    NSAssert(userID || groupID, @"userID and groupID cannot be null at same time");
    NSString *conversationID = @"";
    if (!appendParams) {
        NSLog(@"appendParams cannot be nil");
    }
    BOOL isSendPushInfo = appendParams.isSendPushInfo;
    BOOL isOnlineUserOnly = appendParams.isOnlineUserOnly;
    V2TIMMessagePriority priority = appendParams.priority;
    if (IS_NOT_EMPTY_NSSTRING(userID)) {
        conversationID = [NSString stringWithFormat:@"c2c_%@", userID];
    }

    if (IS_NOT_EMPTY_NSSTRING(groupID)) {
        conversationID = [NSString stringWithFormat:@"group_%@", groupID];
    }

    if (IS_NOT_EMPTY_NSSTRING(conversationData.conversationID)) {
        conversationID = conversationData.conversationID;
    }

    NSParameterAssert(message);

    V2TIMOfflinePushInfo *pushInfo = nil;
    if (isSendPushInfo) {
        pushInfo = [[V2TIMOfflinePushInfo alloc] init];
        BOOL isGroup = groupID.length > 0;
        NSString *senderId = isGroup ? (groupID) : ([TUILogin getUserID]);
        senderId = senderId ?: @"";
        NSString *nickName = isGroup ? (conversationData.title) : ([TUILogin getNickName] ?: [TUILogin getUserID]);
        nickName = nickName ?: @"";
        NSString * content = [self getDisplayString:message] ?: @"";
        OfflinePushExtInfo *extInfo = [[OfflinePushExtInfo alloc] init];
        OfflinePushExtBusinessInfo * entity = extInfo.entity;
        entity.action = 1;
        entity.content = content;
        entity.sender = senderId;
        entity.nickname = nickName;
        entity.faceUrl = [TUILogin getFaceUrl] ?: @"";
        entity.chatType = [isGroup ? @(V2TIM_GROUP) : @(V2TIM_C2C) integerValue];
        entity.version = kOfflinePushVersion;
        pushInfo.ext = [extInfo toReportExtString];
        if (content.length > 0) {
            pushInfo.desc = content;
        }
        if (nickName.length > 0) {
            pushInfo.title = nickName;
        }
        pushInfo.AndroidOPPOChannelID = @"tuikit";
        pushInfo.AndroidSound = TUIConfig.defaultConfig.enableCustomRing ? @"private_ring" : nil;
        pushInfo.AndroidHuaWeiCategory = @"IM";
        pushInfo.AndroidVIVOCategory = @"IM";
        pushInfo.AndroidHonorImportance = @"NORMAL";
        pushInfo.AndroidMeizuNotifyType = 1;
        pushInfo.iOSInterruptionLevel = @"time-sensitive";
        pushInfo.enableIOSBackgroundNotification = NO;
    }

    if ([self isGroupCommunity:conversationData.groupType groupID:conversationData.groupID] ||
        [self isGroupAVChatRoom:conversationData.groupType]) {
        message.needReadReceipt = NO;
    }

    // Hidden conversation evokes the chat page from the address book entry - to send a message, the hidden flag needs to be cleared
    if (conversationID.length > 0) {
        [V2TIMManager.sharedInstance markConversation:@[ conversationID ] markType:@(V2TIM_CONVERSATION_MARK_TYPE_HIDE) enableMark:NO succ:nil fail:nil];
    }

    if (conversationData.userID.length > 0) {
        // C2C
        NSDictionary *cloudCustomDataDic = @{
            @"needTyping" : @1,
            @"version" : @1,
        };
        [message setCloudCustomData:cloudCustomDataDic forType:messageFeature];
    }

    return [V2TIMManager.sharedInstance sendMessage:message
        receiver:userID
        groupID:groupID
        priority:priority
        onlineUserOnly:isOnlineUserOnly
        offlinePushInfo:pushInfo
        progress:progress
        succ:^{
          succ();
        }
        fail:^(int code, NSString *desc) {
          if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
              [TUITool postUnsupportNotificationOfService:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceMessageRead)];
          }
          fail(code, desc);
        }];
}

- (void)getLastMessage:(BOOL)isFromLocal succ:(void (^)(V2TIMMessage *message))succ fail:(V2TIMFail)fail; {
    V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
    if (self.conversationModel.userID.length > 0) {
        option.userID = self.conversationModel.userID;
    }
    if (self.conversationModel.groupID.length > 0) {
        option.groupID = self.conversationModel.groupID;
    }
    option.getType = isFromLocal ? V2TIM_GET_LOCAL_OLDER_MSG : V2TIM_GET_CLOUD_OLDER_MSG;
    option.lastMsg = nil;
    option.count = 1;
    [[V2TIMManager sharedInstance] getHistoryMessageList:option succ:^(NSArray<V2TIMMessage *> *msgs) {
        if (succ) {
            succ(msgs.count > 0 ? msgs.firstObject : nil);
        }
    } fail:^(int code, NSString *desc) {
        if (fail) {
            fail(code, desc);
        }
    }];
}

+ (BOOL)isGroupCommunity:(NSString *)groupType groupID:(NSString *)groupID {
    return [groupType isEqualToString:@"Community"] || [groupID startsWith:@"@TGS#_"];
}

+ (BOOL)isGroupAVChatRoom:(NSString *)groupType {
    return [groupType isEqualToString:@"AVChatRoom"];
}

+ (void)markC2CMessageAsRead:(NSString *)userID succ:(nullable V2TIMSucc)succ fail:(nullable V2TIMFail)fail {
    NSString * conversationID = [NSString stringWithFormat:@"c2c_%@",userID];
    [[V2TIMManager sharedInstance] cleanConversationUnreadMessageCount:conversationID cleanTimestamp:0 cleanSequence:0 succ:succ fail:fail];
}

+ (void)markGroupMessageAsRead:(NSString *)groupID succ:(nullable V2TIMSucc)succ fail:(nullable V2TIMFail)fail {
    NSString * conversationID = [NSString stringWithFormat:@"group_%@",groupID];
    [[V2TIMManager sharedInstance] cleanConversationUnreadMessageCount:conversationID cleanTimestamp:0 cleanSequence:0 succ:succ fail:fail];
}

+ (void)markConversationAsUndead:(NSArray<NSString *> *)conversationIDList enableMark:(BOOL)enableMark {
    [V2TIMManager.sharedInstance markConversation:conversationIDList markType:@(V2TIM_CONVERSATION_MARK_TYPE_UNREAD) enableMark:enableMark succ:nil fail:nil];
}

+ (void)revokeMessage:(V2TIMMessage *)msg succ:(nullable V2TIMSucc)succ fail:(nullable V2TIMFail)fail {
    [[V2TIMManager sharedInstance] revokeMessage:msg succ:succ fail:fail];
}

+ (void)deleteMessages:(NSArray<V2TIMMessage *> *)msgList succ:(nullable V2TIMSucc)succ fail:(nullable V2TIMFail)fail {
    [[V2TIMManager sharedInstance] deleteMessages:msgList succ:succ fail:fail];
}

+ (void)modifyMessage:(V2TIMMessage *)msg completion:(V2TIMMessageModifyCompletion)completion {
    [[V2TIMManager sharedInstance] modifyMessage:msg completion:completion];
}

+ (void)sendMessageReadReceipts:(NSArray *)msgs {
    [[V2TIMManager sharedInstance] sendMessageReadReceipts:msgs
        succ:^{
          NSLog(@"sendMessageReadReceipts succeed");
        }
        fail:^(int code, NSString *desc) {
          if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
              [TUITool postUnsupportNotificationOfService:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceMessageRead)];
          }
        }];
}

+ (void)getReadMembersOfMessage:(V2TIMMessage *)msg
                         filter:(V2TIMGroupMessageReadMembersFilter)filter
                        nextSeq:(NSUInteger)nextSeq
                     completion:(void (^)(int code, NSString *desc, NSArray *members, NSUInteger nextSeq, BOOL isFinished))block {
    [[V2TIMManager sharedInstance] getGroupMessageReadMemberList:msg
        filter:filter
        nextSeq:nextSeq
        count:100
        succ:^(NSMutableArray<V2TIMGroupMemberInfo *> *members, uint64_t nextSeq, BOOL isFinished) {
          if (block) {
              block(0, nil, members, nextSeq, isFinished);
          }
        }
        fail:^(int code, NSString *desc) {
          if (block) {
              block(code, desc, nil, 0, NO);
          }
        }];
}

+ (void)getMessageReadReceipt:(NSArray *)messages succ:(nullable V2TIMMessageReadReceiptsSucc)succ fail:(nullable V2TIMFail)fail {
    if (messages.count == 0) {
        if (fail) {
            fail(-1, @"messages empty");
        }
        return;
    }
    [[V2TIMManager sharedInstance] getMessageReadReceipts:messages succ:succ fail:fail];
}

+ (TUIMessageCellData *__nullable)getCellData:(V2TIMMessage *)message {
    // subclass override required
    return nil;
}

+ (nullable TUIMessageCellData *)getSystemMsgFromDate:(NSDate *)date {
    // subclass override required
    return nil;
}

+ (TUIMessageCellData *)getRevokeCellData:(V2TIMMessage *)message {
    // subclass override required
    return nil;
}

+ (nullable NSString *)getDisplayString:(V2TIMMessage *)message {
    // subclass override required
    return nil;
}

+ (NSString *)getRevokeDispayString:(V2TIMMessage *)message {
    return [self getRevokeDispayString:message operateUser:nil reason:nil];
}

+ (NSString *)getRevokeDispayString:(V2TIMMessage *)message operateUser:(V2TIMUserFullInfo *)operateUser reason:(NSString *)reason {
    V2TIMUserFullInfo *revokerInfo = message.revokerInfo ? message.revokerInfo : operateUser;
    BOOL hasRiskContent = message.hasRiskContent;
    NSString *revoker = message.sender;
    NSString *messageSender = message.sender;
    if (revokerInfo) {
        revoker = revokerInfo.userID;
    }
    NSString *content = TIMCommonLocalizableString(TUIKitMessageTipsNormalRecallMessage);
    if ([revoker isEqualToString:messageSender]) {
        if (message.isSelf) {
            content = TIMCommonLocalizableString(TUIKitMessageTipsYouRecallMessage);
        } else {
            if (message.userID.length > 0) {
                // c2c
                content = TIMCommonLocalizableString(TUIKitMessageTipsOthersRecallMessage);
            } else if (message.groupID.length > 0) {
                NSString *userName = [self.class getShowName:message];
                content = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
            } else {
                // empty
            }
        }
    } else {
        NSString *userName = [self.class getShowName:message];
        if (revokerInfo) {
            userName = revokerInfo.showName;
        }
        content = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
    }
    return rtlString(content);
}

+ (NSString *)getGroupTipsDisplayString:(V2TIMMessage *)message {
    V2TIMGroupTipsElem *tips = message.groupTipsElem;
    NSString *opUser = [self getOpUserName:tips.opMember];
    NSMutableArray<NSString *> *userList = [self getUserNameList:tips.memberList];
    NSString *str = nil;
    switch (tips.type) {
        case V2TIM_GROUP_TIPS_TYPE_JOIN: {
            if (opUser.length > 0) {
                if ((userList.count == 0) || (userList.count == 1 && [opUser isEqualToString:userList.firstObject])) {
                    str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsJoinGroupFormat), opUser];
                } else {
                    NSString *users = [userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsInviteJoinGroupFormat), opUser, users];
                }
            }
        } break;
        case V2TIM_GROUP_TIPS_TYPE_INVITE: {
            if (userList.count > 0) {
                NSString *users = [userList componentsJoinedByString:@"、"];
                str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsInviteJoinGroupFormat), opUser, users];
            }
        } break;
        case V2TIM_GROUP_TIPS_TYPE_QUIT: {
            if (opUser.length > 0) {
                str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsLeaveGroupFormat), opUser];
            }
        } break;
        case V2TIM_GROUP_TIPS_TYPE_KICKED: {
            if (userList.count > 0) {
                NSString *users = [userList componentsJoinedByString:@"、"];
                str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsKickoffGroupFormat), opUser, users];
            }
        } break;
        case V2TIM_GROUP_TIPS_TYPE_SET_ADMIN: {
            if (userList.count > 0) {
                NSString *users = [userList componentsJoinedByString:@"、"];
                str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsSettAdminFormat), users];
            }
        } break;
        case V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN: {
            if (userList.count > 0) {
                NSString *users = [userList componentsJoinedByString:@"、"];
                str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsCancelAdminFormat), users];
            }
        } break;
        case V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE: {
            str = [self opGroupInfoChagedFormatStr:opUser ofUserList:userList ofTips:tips];
            if (str.length > 0) {
                str = [str substringToIndex:str.length - 1];
            }
        } break;
        case V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE: {
            for (V2TIMGroupChangeInfo *info in tips.memberChangeInfoList) {
                if ([info isKindOfClass:V2TIMGroupMemberChangeInfo.class]) {
                    NSString *userId = [(V2TIMGroupMemberChangeInfo *)info userID];
                    int32_t muteTime = [(V2TIMGroupMemberChangeInfo *)info muteTime];
                    NSString *myId = V2TIMManager.sharedInstance.getLoginUser;
                    NSString *showName = [self.class getUserName:tips with:userId];
                    str = [NSString stringWithFormat:@"%@ %@", [userId isEqualToString:myId] ? TIMCommonLocalizableString(You) : showName,
                                                     muteTime == 0 ? TIMCommonLocalizableString(TUIKitMessageTipsUnmute)
                                                                   : TIMCommonLocalizableString(TUIKitMessageTipsMute)];
                    break;
                }
            }
        } break;
        case V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_ADDED: {
            if (opUser.length > 0) {
                str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsGroupPinMessage), opUser];
            }
        }
            break;
        case V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_DELETED: {
            if (opUser.length > 0) {
                str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsGroupUnPinMessage), opUser];
            }
        }
            break;
        default:
            break;
    }
    return rtlString(str);
}

+ (V2TIMMessage *)getCustomMessageWithJsonData:(NSData *)data {
    return [[V2TIMManager sharedInstance] createCustomMessage:data];
}

+ (V2TIMMessage *)getCustomMessageWithJsonData:(NSData *)data desc:(NSString *)desc extension:(NSString *)extension {
    return [[V2TIMManager sharedInstance] createCustomMessage:data desc:desc extension:extension];
}

+ (NSString *)opGroupInfoChagedFormatStr:(NSString *)opUser ofUserList:(NSMutableArray<NSString *> *)userList ofTips:(V2TIMGroupTipsElem *)tips{
    NSString *str = nil;
    str = [NSString stringWithFormat:@"%@", opUser];
    for (V2TIMGroupChangeInfo *info in tips.groupChangeInfoList) {
        switch (info.type) {
            case V2TIM_GROUP_INFO_CHANGE_TYPE_NAME: {
                str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIkitMessageTipsEditGroupNameFormat), str, info.value];
            } break;
            case V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION: {
                str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsEditGroupIntroFormat), str, info.value];
            } break;
            case V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION: {
                if (info.value.length) {
                    str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsEditGroupAnnounceFormat), str, info.value];
                } else {
                    str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsDeleteGroupAnnounceFormat), str];
                }
            } break;
            case V2TIM_GROUP_INFO_CHANGE_TYPE_FACE: {
                str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsEditGroupAvatarFormat), str];
            } break;
            case V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER: {
                if (userList.count) {
                    str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsEditGroupOwnerFormat), str, userList.firstObject];
                } else {
                    str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsEditGroupOwnerFormat), str, info.value];
                }

            } break;
            case V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL: {
                if (info.boolValue) {
                    str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitSetShutupAllFormat), opUser];
                } else {
                    str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitCancelShutupAllFormat), opUser];
                }
            } break;
            case V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_ADD_OPT: {
                uint32_t addOpt = info.intValue;
                NSString *addOptDesc = @"unknown";
                if (addOpt == V2TIM_GROUP_ADD_FORBID) {
                    addOptDesc = TIMCommonLocalizableString(TUIKitGroupProfileJoinDisable);
                } else if (addOpt == V2TIM_GROUP_ADD_AUTH) {
                    addOptDesc = TIMCommonLocalizableString(TUIKitGroupProfileAdminApprove);
                } else if (addOpt == V2TIM_GROUP_ADD_ANY) {
                    addOptDesc = TIMCommonLocalizableString(TUIKitGroupProfileAutoApproval);
                }
                str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsEditGroupAddOptFormat), str, addOptDesc];
            } break;
            case V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_APPROVE_OPT: {
                uint32_t addOpt = info.intValue;
                NSString *addOptDesc = @"unknown";
                if (addOpt == V2TIM_GROUP_ADD_FORBID) {
                    addOptDesc = TIMCommonLocalizableString(TUIKitGroupProfileInviteDisable);
                } else if (addOpt == V2TIM_GROUP_ADD_AUTH) {
                    addOptDesc = TIMCommonLocalizableString(TUIKitGroupProfileAdminApprove);
                } else if (addOpt == V2TIM_GROUP_ADD_ANY) {
                    addOptDesc = TIMCommonLocalizableString(TUIKitGroupProfileAutoApproval);
                }
                str = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsEditGroupInviteOptFormat), str, addOptDesc];
            } break;
            default:
                break;
        }
    }
    return rtlString(str);
}
+ (NSString *)getOpUserName:(V2TIMGroupMemberInfo *)info {
    NSString *opUser;
    if (info.nameCard.length > 0) {
        opUser = info.nameCard;
    } else if (info.nickName.length > 0) {
        opUser = info.nickName;
    } else {
        opUser = info.userID;
    }
    return opUser;
}

+ (NSMutableArray *)getUserNameList:(NSArray<V2TIMGroupMemberInfo *> *)infoList {
    NSMutableArray<NSString *> *userNameList = [NSMutableArray array];
    for (V2TIMGroupMemberInfo *info in infoList) {
        if (info.nameCard.length > 0) {
            [userNameList addObject:info.nameCard];
        } else if (info.nickName.length > 0) {
            [userNameList addObject:info.nickName];
        } else {
            if (info.userID.length > 0) {
                [userNameList addObject:info.userID];
            }
        }
    }
    return userNameList;
}

+ (NSMutableArray *)getUserIDList:(NSArray<V2TIMGroupMemberInfo *> *)infoList {
    NSMutableArray<NSString *> *userIDList = [NSMutableArray array];
    for (V2TIMGroupMemberInfo *info in infoList) {
        if (info.userID.length > 0) {
            [userIDList addObject:info.userID];
        }
    }
    return userIDList;
}

+ (NSString *)getShowName:(V2TIMMessage *)message {
    NSString *showName = message.sender;
    if (message.nameCard.length > 0) {
        showName = message.nameCard;
    } else if (message.friendRemark.length > 0) {
        showName = message.friendRemark;
    } else if (message.nickName.length > 0) {
        showName = message.nickName;
    }
    return showName;
}

+ (NSString *)getUserName:(V2TIMGroupTipsElem *)tips with:(NSString *)userId {
    NSString *str = @"";
    for (V2TIMGroupMemberInfo *info in tips.memberList) {
        if ([info.userID isEqualToString:userId]) {
            if (info.nameCard.length > 0) {
                str = info.nameCard;
            } else if (info.friendRemark.length > 0) {
                str = info.friendRemark;
            } else if (info.nickName.length > 0) {
                str = info.nickName;
            } else {
                str = userId;
            }
            break;
        }
    }
    return str;
}

@end
