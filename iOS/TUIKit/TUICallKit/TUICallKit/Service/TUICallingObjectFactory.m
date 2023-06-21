//
//  TUICallingObjectFactory.m
//  TUICallKit
//
//  Created by harvy on 2023/3/30.
//  Copyright (c) 2023 Tencent. All rights reserved.

#import "TUICallingObjectFactory.h"
#import "TUICore.h"
#import "TUIDefine.h"
#import "TUICallRecordCallsViewController.h"

@interface TUICallingObjectFactory () <TUIObjectProtocol>

@end

@implementation TUICallingObjectFactory

+ (void)load {
    [TUICore registerObjectFactory:TUICore_TUICallingObjectFactory objectFactory:TUICallingObjectFactory.shareInstance];
}

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - TUIObjectProtocol
- (id)onCreateObject:(NSString *)method param:(NSDictionary *)param {
    if (![method isKindOfClass:NSString.class] || ![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    if ([method isEqualToString:TUICore_TUICallingObjectFactory_RecordCallsVC]) {
        return [self createRecordCallsVC:[param tui_objectForKey:TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle asClass:NSString.class]];
    } else {
        return nil;
    }
}

- (UIViewController *)createRecordCallsVC:(NSString *)uiStyle {
    TUICallKitRecordCallsUIStyle recordCallsUIStyle = TUICallKitRecordCallsUIStyleMinimalist;
    
    if ([uiStyle isEqualToString:TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle_Classic]) {
        recordCallsUIStyle = TUICallKitRecordCallsUIStyleClassic;
    }
    
    TUICallRecordCallsViewController *vc = [[TUICallRecordCallsViewController alloc] initWithRecordCallsUIStyle:recordCallsUIStyle];
    return vc;
}

@end
