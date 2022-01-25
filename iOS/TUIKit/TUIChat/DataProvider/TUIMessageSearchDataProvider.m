//
//  TUIMessageSearchDataProvider.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/7/8.
//

#import "TUIMessageSearchDataProvider.h"
#import "TUIMessageDataProvider+ProtectedAPI.h"

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
                    SucceedBlock:(void (^)(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, NSArray<TUIMessageCellData *> *newMsgs))SucceedBlock
                       FailBlock:(V2TIMFail)FailBlock {
    if(self.isLoadingData) {
        FailBlock(ERR_SUCC, @"正在刷新中");
        return;
    }
    self.isLoadingData = YES;
    self.isOlderNoMoreMsg = NO;
    self.isNewerNoMoreMsg = NO;
    
    dispatch_group_t group = dispatch_group_create();
    __block NSArray *olders = @[];
    __block NSArray *newers = @[];
    __block BOOL isOldLoadFail = NO;
    __block BOOL isNewLoadFail = NO;
    __block int failCode = 0;
    __block NSString *failDesc = nil;
    
    // 以定位消息为起点，加载最旧的10条消息
    {
        dispatch_group_enter(group);
        V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
        option.getType = V2TIM_GET_LOCAL_OLDER_MSG;
        option.count = self.pageCount;
        option.groupID = conversation.groupID;
        option.userID = conversation.userID;
        if (searchMsg) {
            option.lastMsg = searchMsg;
        } else {
            option.lastMsgSeq = searchSeq;
        }
        [V2TIMManager.sharedInstance getHistoryMessageList:option succ:^(NSArray<V2TIMMessage *> *msgs) {
            msgs = msgs.reverseObjectEnumerator.allObjects;
            olders = msgs?:@[];
            if (olders.count < self.pageCount) {
                self.isOlderNoMoreMsg = YES;
            }
            dispatch_group_leave(group);
        } fail:^(int code, NSString *desc) {
            isOldLoadFail = YES;
            failCode = code;
            failDesc = desc;
            dispatch_group_leave(group);
        }];
    }
    // 以定位消息为起点，加载最新的10条消息
    {
        dispatch_group_enter(group);
        V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
        option.getType = V2TIM_GET_LOCAL_NEWER_MSG;
        option.count = self.pageCount;
        option.groupID = conversation.groupID;
        option.userID = conversation.userID;
        if (searchMsg) {
            option.lastMsg = searchMsg;
        } else {
            option.lastMsgSeq = searchSeq;
        }
        [V2TIMManager.sharedInstance getHistoryMessageList:option succ:^(NSArray<V2TIMMessage *> *msgs) {
            newers = msgs?:@[];
            if (newers.count < self.pageCount) {
                self.isNewerNoMoreMsg = YES;
            }
            dispatch_group_leave(group);
        } fail:^(int code, NSString *desc) {
            isNewLoadFail = YES;
            failCode = code;
            failDesc = desc;
            dispatch_group_leave(group);
        }];
    }
    @weakify(self)
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @strongify(self)
        self.isLoadingData = NO;
        if (isOldLoadFail || isNewLoadFail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                FailBlock(failCode, failDesc);
            });
        }
        self.isFirstLoad = NO;
        
        NSMutableArray *results = [NSMutableArray array];
        [results addObjectsFromArray:olders];
        if (searchMsg) {
            // 通过 msg 拉取消息不会返回 msg 对象本身，这里需要把 msg 主动添加到 results 列表
            [results addObject:searchMsg];
        } else {
            // 通过 msg seq 拉取消息，拉取旧消息和新消息都会返回 msg 对象本身，这里需要在 results 对 msg 对象去重
            [results removeLastObject];
        }
        [results addObjectsFromArray:newers];
        self.msgForOlderGet = results.firstObject;
        self.msgForNewerGet = results.lastObject;
        
        @weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.heightCache_ removeAllObjects];
            [self.uiMsgs_ removeAllObjects];
            
            NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:results.reverseObjectEnumerator.allObjects];
            @weakify(self)
            [self preProcessReplyMessage:uiMsgs callback:^{
                @strongify(self)
                [self.uiMsgs_ addObjectsFromArray:uiMsgs];
                SucceedBlock(self.isOlderNoMoreMsg, self.isNewerNoMoreMsg, self.uiMsgs_);
            }];
            
        });
    });
}


- (void)loadMessageWithIsRequestOlderMsg:(BOOL)orderType
                        ConversationInfo:(TUIChatConversationModel *)conversation
                            SucceedBlock:(void (^)(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, BOOL isFirstLoad, NSArray<TUIMessageCellData *> *newUIMsgs))SucceedBlock
                               FailBlock:(V2TIMFail)FailBlock {
    
    self.isLoadingData = YES;
    
    int requestCount = self.pageCount;
    V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
    option.userID = conversation.userID;
    option.groupID = conversation.groupID;
    option.getType = orderType ? V2TIM_GET_CLOUD_OLDER_MSG : V2TIM_GET_CLOUD_NEWER_MSG;
    option.count = requestCount;
    option.lastMsg = orderType ? self.msgForOlderGet : self.msgForNewerGet;
    @weakify(self);
    [V2TIMManager.sharedInstance getHistoryMessageList:option succ:^(NSArray<V2TIMMessage *> *msgs) {
        @strongify(self);
        if (!orderType) {
            // 逆序
            msgs = msgs.reverseObjectEnumerator.allObjects;
        }
        
        // 更新lastMsg标志位
        // -- 当前是从最新的时间点开始往旧的方向拉取
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
        
        // 更新无数据标志
        if (msgs.count < requestCount) {
            if (orderType) {
                self.isOlderNoMoreMsg = YES;
            } else {
                self.isNewerNoMoreMsg = YES;
            }
        }
        
        if (isLastest) {
            // 当前是从最新的时间点往旧的方向拉取
            self.isNewerNoMoreMsg = YES;
        }
        
        // 转换数据
        @weakify(self)
        NSMutableArray<TUIMessageCellData *> *uiMsgs = [self transUIMsgFromIMMsg:msgs];
        [self preProcessReplyMessage:uiMsgs callback:^{
            @strongify(self)
            
            if (orderType) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
                [self.uiMsgs_ insertObjects:uiMsgs atIndexes:indexSet];
            } else {
                [self.uiMsgs_ addObjectsFromArray:uiMsgs];
            }
            
            // 回调
            SucceedBlock(self.isOlderNoMoreMsg, self.isNewerNoMoreMsg, self.isFirstLoad, uiMsgs);
            
            self.isLoadingData = NO;
            self.isFirstLoad = NO;
        }];
        

    } fail:^(int code, NSString *desc) {
        self.isLoadingData = NO;
    }];
}

- (void)removeAllSearchData {
    [self.uiMsgs_ removeAllObjects];
    self.isNewerNoMoreMsg = NO;
    self.isOlderNoMoreMsg = NO;
    self.isFirstLoad = YES;
    self.msgForNewerGet = nil;
    self.msgForOlderGet = nil;
}

- (void)findMessages:(NSArray<NSString *> *)msgIDs callback:(void(^)(BOOL success, NSString *desc, NSArray<V2TIMMessage *> *messages))callback
{
    
    [V2TIMManager.sharedInstance findMessages:msgIDs succ:^(NSArray<V2TIMMessage *> *msgs) {
        if (callback) {
            callback(YES, @"", msgs);
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(NO, desc, nil);
        }
    }];
}

#pragma mark - Override
- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    if (self.isNewerNoMoreMsg == NO) {
        // 如果当前历史列表还没有加载到最新的一条数据, 则不处理新消息.
        // 如果处理的话, 会导致新消息加到历史列表中, 出现位置错乱问题.
        return;
    }
    
    [super onRecvNewMessage:msg];
}

@end
