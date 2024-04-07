//
//  TUIEmojiMessageReactPreLoadProvider.m
//  TUIEmojiPlugin
//
//  Created by cologne on 2023/12/26.
//

#import "TUIEmojiMessageReactPreLoadProvider.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIMessageCellData.h>
#import "TUIMessageCellData+Reaction.h"

@implementation TUIEmojiMessageReactPreLoadProvider

- (void)getMessageReactions:(NSArray<TUIMessageCellData *> *)cellDataList
   maxUserCountPerReaction:(uint32_t)maxUserCountPerReaction
                       succ:(V2TIMSucc)succ
                       fail:(V2TIMFail)fail {
    NSMutableArray <V2TIMMessage *> *messageList = [NSMutableArray array];
    NSMutableDictionary *cellDataMap = [NSMutableDictionary dictionary];
    for (TUIMessageCellData *cellData in cellDataList) {
        if (cellData.innerMessage) {
            if (cellData.innerMessage.status != V2TIM_MSG_STATUS_SEND_FAIL) {
                [messageList addObject:cellData.innerMessage];
            }
        }
        if (cellData.msgID) {
            [cellDataMap setObject:cellData forKey:cellData.msgID];
        }
    }
    
    __weak typeof(self)weakSelf = self;
    [[V2TIMManager sharedInstance] getMessageReactions:messageList maxUserCountPerReaction:maxUserCountPerReaction
        succ:^(NSArray<V2TIMMessageReactionResult *> *resultList) {
        // 
        for (V2TIMMessageReactionResult *result in resultList) {
            int32_t resultCode = result.resultCode;
            NSString *msgID     = result.msgID;
            NSString *resultInfo = result.resultInfo;
            NSArray *reactionList = result.reactionList;
            for (V2TIMMessageReaction *reaction in reactionList) {
                TUIReactModel * model = [TUIReactModel createTagsModelByReaction:reaction];
                if (model) {
                    if (msgID) {
                        TUIMessageCellData *cellData = cellDataMap[msgID];
                        if (!cellData.reactdataProvider) {
                            [cellData setupReactDataProvider];
                        }
                        cellData.reactdataProvider.isFirsLoad = YES;
                        [cellData.reactdataProvider.reactMap setObject:model forKey:model.emojiKey];
                        [cellData.reactdataProvider.reactArray addObject:model];
                    }
                }
            }
        }
        
        if(succ) {
            succ();
        }
        
    } fail:^(int code, NSString *desc) {
        fail(code,desc);
    }];
}

@end
