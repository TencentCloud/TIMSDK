//
//  TUIMessageSearchDataProvider.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/7/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageSearchDataProvider.h"
#import "TUIMessageBaseDataProvider+ProtectedAPI.h"

typedef void (^LoadSearchMsgSucceedBlock)(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, NSArray<TUIMessageCellData *> *newMsgs);
typedef void (^LoadMsgSucceedBlock)(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, BOOL isFirstLoad, NSArray<TUIMessageCellData *> *newUIMsgs);

@interface TUIMessageSearchDataProvider ()

@property(nonatomic, copy) LoadSearchMsgSucceedBlock loadSearchMsgSucceedBlock;
@property(nonatomic, copy) LoadMsgSucceedBlock loadMsgSucceedBlock;

@end

@implementation TUIMessageSearchDataProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        _isOlderNoMoreMsg = NO;
        _isNewerNoMoreMsg = NO;
    }
    return self;
}

- (void)loadMessageWithSearchMsg:(V2TIMMessage *)searchMsg
                    SearchMsgSeq:(uint64_t)searchSeq
                ConversationInfo:(TUIChatConversationModel *)conversation
                    SucceedBlock:(void (^)(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, NSArray<TUIMessageCellData *> *newMsgs))succeedBlock
                       FailBlock:(V2TIMFail)failBlock {
    if (self.isLoadingData) {
        failBlock(ERR_SUCC, @"refreshing");
        return;
    }
    self.isLoadingData = YES;
    self.isOlderNoMoreMsg = NO;
    self.isNewerNoMoreMsg = NO;
    self.loadSearchMsgSucceedBlock = succeedBlock;

    dispatch_group_t group = dispatch_group_create();
    __block NSArray *olders = @[];
    __block NSArray *newers = @[];
    __block BOOL isOldLoadFail = NO;
    __block BOOL isNewLoadFail = NO;
    __block int failCode = 0;
    __block NSString *failDesc = nil;

    /**
     * Load the oldest pageCount messages starting from locating message
     */
    {
        dispatch_group_enter(group);
        V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
        option.getType = V2TIM_GET_CLOUD_OLDER_MSG;
        option.count = self.pageCount;
        option.groupID = conversation.groupID;
        option.userID = conversation.userID;
        if (searchMsg) {
            option.lastMsg = searchMsg;
        } else {
            option.lastMsgSeq = searchSeq;
        }
        [V2TIMManager.sharedInstance getHistoryMessageList:option
            succ:^(NSArray<V2TIMMessage *> *msgs) {
              msgs = msgs.reverseObjectEnumerator.allObjects;
              olders = msgs ?: @[];
              if (olders.count < self.pageCount) {
                  self.isOlderNoMoreMsg = YES;
              }
              dispatch_group_leave(group);
            }
            fail:^(int code, NSString *desc) {
              isOldLoadFail = YES;
              failCode = code;
              failDesc = desc;
              dispatch_group_leave(group);
            }];
    }
    /**
     * Load the latest pageCount messages starting from the locating message
     */
    {
        dispatch_group_enter(group);
        V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
        option.getType = V2TIM_GET_CLOUD_NEWER_MSG;
        option.count = self.pageCount;
        option.groupID = conversation.groupID;
        option.userID = conversation.userID;
        if (searchMsg) {
            option.lastMsg = searchMsg;
        } else {
            option.lastMsgSeq = searchSeq;
        }
        [V2TIMManager.sharedInstance getHistoryMessageList:option
            succ:^(NSArray<V2TIMMessage *> *msgs) {
              newers = msgs ?: @[];
              if (newers.count < self.pageCount) {
                  self.isNewerNoMoreMsg = YES;
              }
              dispatch_group_leave(group);
            }
            fail:^(int code, NSString *desc) {
              isNewLoadFail = YES;
              failCode = code;
              failDesc = desc;
              dispatch_group_leave(group);
            }];
    }
    @weakify(self);

    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
      @strongify(self);
      self.isLoadingData = NO;
      if (isOldLoadFail || isNewLoadFail) {
          dispatch_async(dispatch_get_main_queue(), ^{
            failBlock(failCode, failDesc);
          });
      }
      self.isFirstLoad = NO;

      NSMutableArray *results = [NSMutableArray array];
      [results addObjectsFromArray:olders];
      if (searchMsg) {
          /**
           * Pulling messages through the msg will not return the msg object itself, here you need to actively add the msg to the results list
           */
          [results addObject:searchMsg];
      } else {
          /**
           * Pulling messages through the msg seq, pulling old messages and new messages will return the msg object itself, here you need to deduplicate the msg
           * object in results
           */
          [results removeLastObject];
      }
      [results addObjectsFromArray:newers];
      self.msgForOlderGet = results.firstObject;
      self.msgForNewerGet = results.lastObject;

      @weakify(self);
      dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.heightCache_ removeAllObjects];
        [self.uiMsgs_ removeAllObjects];

        NSArray *msgs = results.reverseObjectEnumerator.allObjects;
        NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:msgs];
        if (uiMsgs.count == 0) {
            return;
        }
        [self getGroupMessageReceipts:msgs
            uiMsgs:uiMsgs
            succ:^{
              [self preProcessMessage:uiMsgs];
            }
            fail:^{
              [self preProcessMessage:uiMsgs];
            }];
      });
    });
}

- (void)loadMessageWithIsRequestOlderMsg:(BOOL)orderType
                        ConversationInfo:(TUIChatConversationModel *)conversation
                            SucceedBlock:(void (^)(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, BOOL isFirstLoad,
                                                   NSArray<TUIMessageCellData *> *newUIMsgs))succeedBlock
                               FailBlock:(V2TIMFail)failBlock {
    self.isLoadingData = YES;
    self.loadMsgSucceedBlock = succeedBlock;

    int requestCount = self.pageCount;
    V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
    option.userID = conversation.userID;
    option.groupID = conversation.groupID;
    option.getType = orderType ? V2TIM_GET_CLOUD_OLDER_MSG : V2TIM_GET_CLOUD_NEWER_MSG;
    option.count = requestCount;
    option.lastMsg = orderType ? self.msgForOlderGet : self.msgForNewerGet;
    @weakify(self);
    [V2TIMManager.sharedInstance getHistoryMessageList:option
        succ:^(NSArray<V2TIMMessage *> *msgs) {
          @strongify(self);
          if (!orderType) {
              msgs = msgs.reverseObjectEnumerator.allObjects;
          }

          /**
           * Update the lastMsg flag
           * -- The current pull operation is to pull from the latest time point to the past
           */
          BOOL isLastest = (self.msgForNewerGet == nil) && (self.msgForOlderGet == nil) && orderType;
          if (msgs.count != 0) {
              if (orderType) {
                  self.msgForOlderGet = msgs.lastObject;
                  if (self.msgForNewerGet == nil) {
                      self.msgForNewerGet = msgs.firstObject;
                  }
              } else {
                  if (self.msgForOlderGet == nil) {
                      self.msgForOlderGet = msgs.lastObject;
                  }
                  self.msgForNewerGet = msgs.firstObject;
              }
          }

          /**
           * Update no data flag
           */
          if (msgs.count < requestCount) {
              if (orderType) {
                  self.isOlderNoMoreMsg = YES;
              } else {
                  self.isNewerNoMoreMsg = YES;
              }
          }

          if (isLastest) {
              /**
               * The current pull operation is to pull from the latest time point to the past
               */
              self.isNewerNoMoreMsg = YES;
          }

          NSMutableArray<TUIMessageCellData *> *uiMsgs = [self transUIMsgFromIMMsg:msgs];
          if (uiMsgs.count == 0) {
              if (self.loadMsgSucceedBlock) {
                  self.loadMsgSucceedBlock(self.isOlderNoMoreMsg, self.isNewerNoMoreMsg, self.isFirstLoad, uiMsgs);
              }
              return;
          }
          [self getGroupMessageReceipts:msgs
              uiMsgs:uiMsgs
              succ:^{
                [self preProcessMessage:uiMsgs orderType:orderType];
              }
              fail:^{
                [self preProcessMessage:uiMsgs orderType:orderType];
              }];
        }
        fail:^(int code, NSString *desc) {
          self.isLoadingData = NO;
        }];
}

- (void)getGroupMessageReceipts:(NSArray *)msgs uiMsgs:(NSArray *)uiMsgs succ:(void (^)(void))succBlock fail:(void (^)(void))failBlock {
    [[V2TIMManager sharedInstance] getMessageReadReceipts:msgs
        succ:^(NSArray<V2TIMMessageReceipt *> *receiptList) {
          NSLog(@"getGroupMessageReceipts succeed, receiptList: %@", receiptList);
          NSMutableDictionary *dict = [NSMutableDictionary dictionary];
          for (V2TIMMessageReceipt *receipt in receiptList) {
              [dict setObject:receipt forKey:receipt.msgID];
          }
          for (TUIMessageCellData *data in uiMsgs) {
              V2TIMMessageReceipt *receipt = dict[data.msgID];
              data.messageReceipt = receipt;
          }

          if (succBlock) {
              succBlock();
          }
        }
        fail:^(int code, NSString *desc) {
          NSLog(@"getGroupMessageReceipts failed, code: %d, desc: %@", code, desc);
          if (failBlock) {
              failBlock();
          }
        }];
}

- (void)preProcessMessage:(NSArray *)uiMsgs {
    @weakify(self);
    [self preProcessMessage:uiMsgs
                   callback:^{
                     @strongify(self);
                     [self addUIMsgs:uiMsgs];
                     self.loadSearchMsgSucceedBlock(self.isOlderNoMoreMsg, self.isNewerNoMoreMsg, self.uiMsgs_);
                   }];
}

- (void)preProcessMessage:(NSArray *)uiMsgs orderType:(BOOL)orderType {
    @weakify(self);
    [self preProcessMessage:uiMsgs
                   callback:^{
                     @strongify(self);

                     if (orderType) {
                         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
                         [self insertUIMsgs:uiMsgs atIndexes:indexSet];
                     } else {
                         [self addUIMsgs:uiMsgs];
                     }

                     if (self.loadMsgSucceedBlock) {
                         self.loadMsgSucceedBlock(self.isOlderNoMoreMsg, self.isNewerNoMoreMsg, self.isFirstLoad, uiMsgs);
                     }

                     self.isLoadingData = NO;
                     self.isFirstLoad = NO;
                   }];
}

- (void)removeAllSearchData {
    [self.uiMsgs_ removeAllObjects];
    self.isNewerNoMoreMsg = NO;
    self.isOlderNoMoreMsg = NO;
    self.isFirstLoad = YES;
    self.msgForNewerGet = nil;
    self.msgForOlderGet = nil;
    self.loadSearchMsgSucceedBlock = nil;
}

- (void)findMessages:(NSArray<NSString *> *)msgIDs callback:(void (^)(BOOL success, NSString *desc, NSArray<V2TIMMessage *> *messages))callback {
    [V2TIMManager.sharedInstance findMessages:msgIDs
        succ:^(NSArray<V2TIMMessage *> *msgs) {
          if (callback) {
              callback(YES, @"", msgs);
          }
        }
        fail:^(int code, NSString *desc) {
          if (callback) {
              callback(NO, desc, nil);
          }
        }];
}

#pragma mark - Override
- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    if (self.isNewerNoMoreMsg == NO) {
        /**
         * If the current message list has not pulled the last message, ignore the new message;
         * If it is processed at this time, it will cause new messages to be added to the history list, resulting in the problem of position confusion.
         */
        return;
    }

    [super onRecvNewMessage:msg];
}

@end
