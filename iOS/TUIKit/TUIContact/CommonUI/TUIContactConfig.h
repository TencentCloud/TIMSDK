//
//  TUIContactConfig.h
//  TUIContact
//
//  Created by Tencent on 2024/9/23.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, TUIContactConfigItem) {
    TUIContactConfigItem_None = 0,
    TUIContactConfigItem_Alias = 1 << 0,
    TUIContactConfigItem_MuteAndPin = 1 << 1,
    TUIContactConfigItem_Background = 1 << 2,
    TUIContactConfigItem_Block = 1 << 3,
    TUIContactConfigItem_ClearChatHistory = 1 << 4,
    TUIContactConfigItem_Delete = 1 << 5,
    TUIContactConfigItem_AddFriend = 1 << 6,
};

@interface TUIContactConfig : NSObject

+ (TUIContactConfig *)sharedConfig;
/**
 * Hide items in contact config interface.
 */
- (void)hideItemsInContactConfig:(TUIContactConfigItem)items;
/**
 * Get the hidden status of specified item.
 */
- (BOOL)isItemHiddenInContactConfig:(TUIContactConfigItem)item;

@end

NS_ASSUME_NONNULL_END
