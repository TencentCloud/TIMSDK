//
//  TUIMessageSearchDataProvider.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/7/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageSearchDataProvider : TUIMessageDataProvider

@property(nonatomic) BOOL isOlderNoMoreMsg;
@property(nonatomic) BOOL isNewerNoMoreMsg;
@property(nonatomic) V2TIMMessage *msgForOlderGet;
@property(nonatomic) V2TIMMessage *msgForNewerGet;

- (void)loadMessageWithSearchMsg:(V2TIMMessage *)searchMsg
                    SearchMsgSeq:(uint64_t)searchSeq
                ConversationInfo:(TUIChatConversationModel *)conversation
                    SucceedBlock:(void (^)(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, NSArray<TUIMessageCellData *> *newMsgs))succeedBlock
                       FailBlock:(V2TIMFail)failBlock;

- (void)loadMessageWithIsRequestOlderMsg:(BOOL)orderType
                        ConversationInfo:(TUIChatConversationModel *)conversation
                            SucceedBlock:(void (^)(BOOL isOlderNoMoreMsg, BOOL isNewerNoMoreMsg, BOOL isFirstLoad,
                                                   NSArray<TUIMessageCellData *> *newUIMsgs))succeedBlock
                               FailBlock:(V2TIMFail)failBlock;

- (void)removeAllSearchData;

- (void)findMessages:(NSArray<NSString *> *)msgIDs callback:(void (^)(BOOL success, NSString *desc, NSArray<V2TIMMessage *> *messages))callback;

- (void)preProcessMessage:(NSArray *)uiMsgs;
@end

NS_ASSUME_NONNULL_END
