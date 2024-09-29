//
//  TUIGroupConfig.h
//  TUIGroup
//
//  Created by Tencent on 2024/9/6.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, TUIGroupConfigItem) {
    TUIGroupConfigItem_None = 0,
    TUIGroupConfigItem_Members = 1 << 0,
    TUIGroupConfigItem_Notice = 1 << 1,
    TUIGroupConfigItem_Manage = 1 << 2,
    TUIGroupConfigItem_Alias = 1 << 3,
    TUIGroupConfigItem_MuteAndPin = 1 << 4,
    TUIGroupConfigItem_Background = 1 << 5,
    TUIGroupConfigItem_ClearChatHistory = 1 << 6,
    TUIGroupConfigItem_DeleteAndLeave = 1 << 7,
    TUIGroupConfigItem_Transfer = 1 << 8,
    TUIGroupConfigItem_Dismiss = 1 << 9,
    TUIGroupConfigItem_Report = 1 << 10,
};

@interface TUIGroupConfig : NSObject

+ (TUIGroupConfig *)sharedConfig;
/**
 * Hide items in group config interface.
 */
- (void)hideItemsInGroupConfig:(TUIGroupConfigItem)items;
/**
 * Get the hidden status of specified item.
 */
- (BOOL)isItemHiddenInGroupConfig:(TUIGroupConfigItem)item;

@end

NS_ASSUME_NONNULL_END
