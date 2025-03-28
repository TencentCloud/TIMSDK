//
//  TUIEmojiReactDataProvider.m
//  TUIEmojiPlugin
//
//  Created by cologne on 2023/11/23.
//

#import "TUIEmojiReactDataProvider.h"
#import <TIMCommon/TIMDefine.h>
@interface TUIEmojiReactDataProvider() <V2TIMAdvancedMsgListener>

@end
@implementation TUIEmojiReactDataProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupNotify];
    }
    return self;
}

- (void)setupNotify {
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
}

- (NSMutableArray *)reactArray {
    if (!_reactArray) {
        _reactArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _reactArray;
}

- (NSMutableDictionary *)reactMap {
    if (!_reactMap) {
        _reactMap = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _reactMap;
}
- (void)addMessageReaction:(V2TIMMessage *)v2Message
                reactionID:(NSString *)reactionID
                      succ:(V2TIMSucc)succ
                      fail:(V2TIMFail)fail {
    [[V2TIMManager sharedInstance] addMessageReaction:v2Message reactionID:reactionID succ:^{
        if (succ){
            succ();
        }
    } fail:^(int code, NSString *desc) {
        if (fail){
            fail(code,desc);
        }
    }];
}

- (void)removeMessageReaction:(V2TIMMessage *)v2Message
                   reactionID:(NSString *)reactionID
                         succ:(V2TIMSucc)succ
                         fail:(V2TIMFail)fail {
    [[V2TIMManager sharedInstance] removeMessageReaction:v2Message reactionID:reactionID succ:^{
        if (succ){
            succ();
        }
    } fail:^(int code, NSString *desc) {
        if (fail){
            fail(code,desc);
        }
    }];
}

- (void)getMessageReactions:(NSArray<V2TIMMessage *> *)messageList
   maxUserCountPerReaction:(uint32_t)maxUserCountPerReaction
                       succ:(TUIEmojiReactGetMessageReactionsSucc)succ
                       fail:(V2TIMFail)fail {
    __block NSMutableDictionary *modifyUserMap = nil;
    __block NSMutableArray *reactArray = nil;
    __weak typeof(self)weakSelf = self;
    self.isFirsLoad = YES;
    [[V2TIMManager sharedInstance] getMessageReactions:messageList maxUserCountPerReaction:maxUserCountPerReaction
        succ:^(NSArray<V2TIMMessageReactionResult *> *resultList) {
        
        modifyUserMap = [NSMutableDictionary dictionaryWithCapacity:3];
        reactArray = [NSMutableArray arrayWithCapacity:3];
        // Batch pull message response information successful
        for (V2TIMMessageReactionResult *result in resultList) {
            int32_t resultCode = result.resultCode;
            NSString *resultInfo = result.resultInfo;
            NSArray *reactionList = result.reactionList;
            for (V2TIMMessageReaction *reaction in reactionList) {
                TUIReactModel * model = [TUIReactModel createTagsModelByReaction:reaction];
                if (model) {
                    [modifyUserMap setObject:model forKey:model.emojiKey];
                    [reactArray addObject:model];
                }
            }
        }
        weakSelf.reactMap = [NSMutableDictionary dictionaryWithDictionary:modifyUserMap];
        weakSelf.reactArray = [NSMutableArray arrayWithArray:reactArray];
        if(succ) {
            succ(reactArray,modifyUserMap);
        }
        
    } fail:^(int code, NSString *desc) {
        fail(code,desc);
    }];
}

- (void)onRecvMessageReactionsChanged:(NSArray<V2TIMMessageReactionChangeInfo *> *)changeList {
    __block NSMutableDictionary *changedReactMap = nil;
    __block NSMutableArray *changedReactArray = nil;
    changedReactMap = [NSMutableDictionary dictionaryWithCapacity:3];
    changedReactArray = [NSMutableArray arrayWithCapacity:3];
    __weak typeof(self)weakSelf = self;
    //Response to the update callback after receiving the message
    for (V2TIMMessageReactionChangeInfo *changeInfo in changeList) {
        NSString *msgID = changeInfo.msgID;
        if (![msgID isEqualToString:self.msgId] ) {
            // Not the current message
            return;
        }
        //Changed reaction list
        NSArray *reactionList = changeInfo.reactionList;
        for (V2TIMMessageReaction *reaction in reactionList) {
            TUIReactModel * model = [TUIReactModel createTagsModelByReaction:reaction];
            if (model) {
                [changedReactMap setObject:model forKey:model.emojiKey];
                [changedReactArray addObject:model];
            }
        }
    }
    
    __block NSMutableDictionary *sortedReactMap = [NSMutableDictionary dictionaryWithDictionary:self.reactMap];
    __block NSMutableArray *sortedReactArray = [NSMutableArray arrayWithArray:self.reactArray];

    //deal change
    [changedReactMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, TUIReactModel*  _Nonnull changedObj, BOOL * _Nonnull stop) {
        
        __block BOOL inOrigin = NO;
        [weakSelf.reactArray enumerateObjectsUsingBlock:^(TUIReactModel*  _Nonnull originObj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([originObj.emojiKey isEqualToString:changedObj.emojiKey] ) {
                inOrigin = YES;
                if (changedObj.totalUserCount != 0) {
                    sortedReactMap[originObj.emojiKey] = changedObj;
                    [sortedReactArray removeObject:originObj];
                    [sortedReactArray addObject:changedObj];
                }
                else {
                    [sortedReactMap removeObjectForKey:originObj.emojiKey];
                    [sortedReactArray removeObject:originObj];
                }
            }
        }];
        
        if (!inOrigin) {
            [sortedReactArray addObject:changedObj];
            [sortedReactMap setObject:changedObj forKey:changedObj.emojiKey];
        }

    }];
 

    self.reactArray = [NSMutableArray arrayWithArray:sortedReactArray];
    self.reactMap = [NSMutableDictionary dictionaryWithDictionary:sortedReactMap];

    if (self.changed) {
        self.changed(sortedReactArray, sortedReactMap);
    }
}

- (TUIReactModel *)getCurrentReactionIDInMap:(NSString *)reactionID {
    if ([self.reactMap objectForKey:reactionID]) {
        return self.reactMap[reactionID];
    }
    return nil;
}
@end
