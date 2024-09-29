//
//  TUIContactConfig.m
//  TUIContact
//
//  Created by Tencent on 2024/9/23.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import "TUIContactConfig.h"

@interface TUIContactConfig()

@property (nonatomic, assign) BOOL hideContactAlias;
@property (nonatomic, assign) BOOL hideContactMuteAndPinItems;
@property (nonatomic, assign) BOOL hideContactBackgroundItem;
@property (nonatomic, assign) BOOL hideContactBlock;
@property (nonatomic, assign) BOOL hideContactClearChatHistory;
@property (nonatomic, assign) BOOL hideContactDelete;
@property (nonatomic, assign) BOOL hideContactAddFriend;

@end

@implementation TUIContactConfig

+ (TUIContactConfig *)sharedConfig {
    static dispatch_once_t onceToken;
    static TUIContactConfig *config;
    dispatch_once(&onceToken, ^{
        config = [[TUIContactConfig alloc] init];
    });
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hideContactAlias = NO;
        self.hideContactMuteAndPinItems = NO;
        self.hideContactBackgroundItem = NO;
        self.hideContactBlock = NO;
        self.hideContactClearChatHistory = NO;
        self.hideContactDelete = NO;
        self.hideContactAddFriend = NO;
    }
    return self;
}

- (void)hideItemsInContactConfig:(TUIContactConfigItem)items {
    self.hideContactAlias = items & TUIContactConfigItem_Alias;
    self.hideContactMuteAndPinItems = items & TUIContactConfigItem_MuteAndPin;
    self.hideContactBackgroundItem = items & TUIContactConfigItem_Background;
    self.hideContactBlock = items & TUIContactConfigItem_Block;
    self.hideContactClearChatHistory = items & TUIContactConfigItem_ClearChatHistory;
    self.hideContactDelete = items & TUIContactConfigItem_Delete;
    self.hideContactAddFriend = items & TUIContactConfigItem_AddFriend;
}

- (BOOL)isItemHiddenInContactConfig:(TUIContactConfigItem)item {
    if (item & TUIContactConfigItem_Alias) {
        return self.hideContactAlias;
    } else if (item & TUIContactConfigItem_MuteAndPin) {
        return self.hideContactMuteAndPinItems;
    } else if (item & TUIContactConfigItem_Background) {
        return self.hideContactBackgroundItem;
    } else if (item & TUIContactConfigItem_Block) {
        return self.hideContactBlock;
    } else if (item & TUIContactConfigItem_ClearChatHistory) {
        return self.hideContactClearChatHistory;
    } else if (item & TUIContactConfigItem_Delete) {
        return self.hideContactDelete;
    } else if (item & TUIContactConfigItem_AddFriend) {
        return self.hideContactAddFriend;
    } else {
        return NO;
    }
}


@end
