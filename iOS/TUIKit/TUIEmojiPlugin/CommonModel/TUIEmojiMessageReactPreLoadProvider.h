//
//  TUIEmojiMessageReactPreLoadProvider.h
//  TUIEmojiPlugin
//
//  Created by cologne on 2023/12/26.
//

#import <Foundation/Foundation.h>
#import "TUIReactModel.h"
#import <TIMCommon/TUIMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN
@import ImSDK_Plus;

@interface TUIEmojiMessageReactPreLoadProvider : NSObject

- (void)getMessageReactions:(NSArray<TUIMessageCellData *> *)cellDataList
   maxUserCountPerReaction:(uint32_t)maxUserCountPerReaction
                       succ:(V2TIMSucc)succ
                       fail:(V2TIMFail)fail;
@end

NS_ASSUME_NONNULL_END
