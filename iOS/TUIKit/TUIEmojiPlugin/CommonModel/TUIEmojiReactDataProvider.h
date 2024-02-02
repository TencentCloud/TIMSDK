//
//  TUIEmojiReactDataProvider.h
//  TUIEmojiPlugin
//
//  Created by cologne on 2023/11/23.
//

#import <Foundation/Foundation.h>
#import "TUIReactModel.h"

@import ImSDK_Plus;
NS_ASSUME_NONNULL_BEGIN
typedef void (^TUIEmojiReactGetMessageReactionsSucc)(NSArray<TUIReactModel *> *tagsArray,NSMutableDictionary *tagsMap);
typedef void (^TUIEmojiReactMessageReactionsChanged)(NSArray<TUIReactModel *> *tagsArray,NSMutableDictionary *tagsMap);

@interface TUIEmojiReactDataProvider : NSObject
@property (nonatomic,copy) NSString * msgId;
@property (nonatomic,copy) TUIEmojiReactMessageReactionsChanged changed;
@property (nonatomic,strong) NSMutableDictionary *reactMap;
@property (nonatomic,strong) NSMutableArray *reactArray;
@property (nonatomic,assign) BOOL isFirsLoad;

- (TUIReactModel *)getCurrentReactionIDInMap:(NSString *)reactionID;

- (void)addMessageReaction:(V2TIMMessage *)v2Message
                reactionID:(NSString *)reactionID
                      succ:(V2TIMSucc)succ
                      fail:(V2TIMFail)fail;
- (void)removeMessageReaction:(V2TIMMessage *)v2Message
                   reactionID:(NSString *)reactionID
                         succ:(V2TIMSucc)succ
                         fail:(V2TIMFail)fail;
- (void)getMessageReactions:(NSArray<V2TIMMessage *> *)messageList
   maxUserCountPerReaction:(uint32_t)maxUserCountPerReaction
                       succ:(TUIEmojiReactGetMessageReactionsSucc)succ
                       fail:(V2TIMFail)fail;
@end

NS_ASSUME_NONNULL_END
