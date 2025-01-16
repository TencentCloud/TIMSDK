//
//  TUIGroupConfig.m
//  TUIGroup
//
//  Created by Tencent on 2024/9/6.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import "TUIGroupConfig.h"

@interface TUIGroupConfig()
@property (nonatomic, assign) BOOL hideGroupMembersItems;
@property (nonatomic, assign) BOOL hideGroupNoticeItem;
@property (nonatomic, assign) BOOL hideGroupManageItems;
@property (nonatomic, assign) BOOL hideGroupAliasItem;
@property (nonatomic, assign) BOOL hideGroupMuteAndPinItems;
@property (nonatomic, assign) BOOL hideGroupBackgroundItem;
@property (nonatomic, assign) BOOL hideGroupClearChatHistory;
@property (nonatomic, assign) BOOL hideGroupDeleteAndLeave;
@property (nonatomic, assign) BOOL hideGroupTransfer;
@property (nonatomic, assign) BOOL hideGroupDismiss;
@property (nonatomic, assign) BOOL hideGroupReport;
@end

@implementation TUIGroupConfig

+ (TUIGroupConfig *)sharedConfig {
    static dispatch_once_t onceToken;
    static TUIGroupConfig *config;
    dispatch_once(&onceToken, ^{
      config = [[TUIGroupConfig alloc] init];
    });
    return config;
}

- (void)hideItemsInGroupConfig:(TUIGroupConfigItem)items {
    self.hideGroupMuteAndPinItems = items & TUIGroupConfigItem_MuteAndPin;
    self.hideGroupManageItems = items & TUIGroupConfigItem_Manage;
    self.hideGroupAliasItem = items & TUIGroupConfigItem_Alias;
    self.hideGroupBackgroundItem = items & TUIGroupConfigItem_Background;
    self.hideGroupMembersItems = items & TUIGroupConfigItem_Members;
    self.hideGroupClearChatHistory = items & TUIGroupConfigItem_ClearChatHistory;
    self.hideGroupDeleteAndLeave = items & TUIGroupConfigItem_DeleteAndLeave;
    self.hideGroupTransfer = items & TUIGroupConfigItem_Transfer;
    self.hideGroupDismiss = items & TUIGroupConfigItem_Dismiss;
    self.hideGroupReport = items & TUIGroupConfigItem_Report;
}

- (BOOL)isItemHiddenInGroupConfig:(TUIGroupConfigItem)item {
    if (item & TUIGroupConfigItem_MuteAndPin) {
        return self.hideGroupMuteAndPinItems;
    } else if (item & TUIGroupConfigItem_Manage) {
        return self.hideGroupManageItems;
    } else if (item & TUIGroupConfigItem_Alias) {
        return self.hideGroupAliasItem;
    } else if (item & TUIGroupConfigItem_Background) {
        return self.hideGroupBackgroundItem;
    } else if (item & TUIGroupConfigItem_Members) {
        return self.hideGroupMembersItems;
    } else if (item & TUIGroupConfigItem_ClearChatHistory) {
        return self.hideGroupClearChatHistory;
    } else if (item & TUIGroupConfigItem_DeleteAndLeave) {
        return self.hideGroupDeleteAndLeave;
    } else if (item & TUIGroupConfigItem_Transfer) {
        return self.hideGroupTransfer;
    } else if (item & TUIGroupConfigItem_Dismiss) {
        return self.hideGroupDismiss;
    } else if (item & TUIGroupConfigItem_Report) {
        return self.hideGroupReport;
    } else {
        return NO;
    }
}

@end
