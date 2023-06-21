//
//  TUICallingExtensionObserver.m
//  TUICallKit
//
//  Created by harvy on 2023/3/30.
//  Copyright (c) 2023 Tencent. All rights reserved.

#import "TUICallingExtensionObserver.h"

#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import <TUICore/TUIThemeManager.h>

#import "TUICallingCommon.h"
#import "TUICallEngineHeader.h"
#import "TUICallKit.h"

@interface TUICallingExtensionObserver () <TUIExtensionProtocol>

@end

@implementation TUICallingExtensionObserver

+ (void)load {
    [TUICore registerExtension:TUICore_TUIChatExtension_NavigationMoreItem_MinimalistExtensionID
                        object:TUICallingExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID
                        object:TUICallingExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIContactExtension_FriendProfileActionMenu_ClassicExtensionID
                        object:TUICallingExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIContactExtension_FriendProfileActionMenu_MinimalistExtensionID
                        object:TUICallingExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_MinimalistExtensionID
                        object:TUICallingExtensionObserver.shareInstance];
}

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - TUIExtensionProtocol

- (NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(NSDictionary *)param {
    if (![extensionID isKindOfClass:NSString.class]) {
        return nil;
    }
    if ([extensionID isEqualToString:TUICore_TUIChatExtension_NavigationMoreItem_MinimalistExtensionID]) {
        return [self getNavigationMoreItemExtensionForMinimalistChat:param];
    } else if ([extensionID isEqualToString:TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID]) {
        return [self getInputViewMoreItemExtensionForClassicChat:param];
    } else if ([extensionID isEqualToString:TUICore_TUIContactExtension_FriendProfileActionMenu_ClassicExtensionID]) {
        return [self getFriendProfileActionMenuExtensionForClassicContact:param];
    } else if ([extensionID isEqualToString:TUICore_TUIContactExtension_FriendProfileActionMenu_MinimalistExtensionID]) {
        return [self getFriendProfileActionMenuExtensionForMinimalistContact:param];
    } else if ([extensionID isEqualToString:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_MinimalistExtensionID]) {
        return [self getGroupInfoCardActionMenuExtensionForMinimalistGroup:param];
    } else {
        return nil;
    }
}

- (NSArray<TUIExtensionInfo *> *)getNavigationMoreItemExtensionForMinimalistChat:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    __weak typeof(self) weakSelf = self;
    void(^onClicked)(NSDictionary *, TUICallMediaType) = ^(NSDictionary *param, TUICallMediaType type) {
        NSString *userID = [param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_UserID
                                           asClass:NSString.class];
        NSString *groupID = [param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_GroupID
                                            asClass:NSString.class];
        UINavigationController *pushVC = [param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_PushVC
                                                         asClass:UINavigationController.class];
        if (userID.length > 0) {
            // c2c video call
            [weakSelf startCall:nil userIDs:@[userID] callingType:type];
        } else if (groupID.length > 0 && pushVC) {
            // group video call
            [weakSelf launchCall:type inGroup:groupID withPushVC:pushVC isClassicUI:NO];
        }
    };
    
    NSMutableArray *result = [NSMutableArray array];
    BOOL filterVideoCall = [[param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_FilterVideoCall
                                            asClass:NSNumber.class] boolValue];
    if (!filterVideoCall) {
        TUIExtensionInfo *videoInfo = [[TUIExtensionInfo alloc] init];
        videoInfo.weight = 200;
        videoInfo.icon = [TUICallingCommon getBundleImageWithName:@"video_call"];
        videoInfo.onClicked = ^(NSDictionary * _Nonnull param) {
            onClicked(param, TUICallMediaTypeVideo);
        };
        [result addObject:videoInfo];
    }
    
    BOOL filterAudioCall = [[param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_FilterAudioCall
                                            asClass:NSNumber.class] boolValue];
    if (!filterAudioCall) {
        TUIExtensionInfo *audioInfo = [[TUIExtensionInfo alloc] init];
        audioInfo.weight = 100;
        audioInfo.icon = [TUICallingCommon getBundleImageWithName:@"audio_call"];
        audioInfo.onClicked = ^(NSDictionary * _Nonnull param) {
            onClicked(param, TUICallMediaTypeAudio);
        };
        [result addObject:audioInfo];
    }
    return result;
}

- (NSArray<TUIExtensionInfo *> *)getInputViewMoreItemExtensionForClassicChat:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    NSMutableArray *result = [NSMutableArray array];
    BOOL filterVideoCall = [[param tui_objectForKey:TUICore_TUIChatExtension_InputViewMoreItem_FilterVideoCall
                                            asClass:NSNumber.class] boolValue];
    if (!filterVideoCall) {
        TUIExtensionInfo *videoInfo = [[TUIExtensionInfo alloc] init];
        videoInfo.weight = 600;
        videoInfo.text = TUIKitLocalizableString(TUIKitMoreVideoCall);
        videoInfo.icon = TUICoreBundleThemeImage(@"service_more_video_call_img", @"more_video_call");
        videoInfo.onClicked = ^(NSDictionary * _Nonnull param) {
            [weakSelf doResponseInputViewExtension:param type:TUICallMediaTypeVideo isClassicUI:YES];
        };
        [result addObject:videoInfo];
    }
    
    BOOL filterAudioCall = [[param tui_objectForKey:TUICore_TUIChatExtension_InputViewMoreItem_FilterAudioCall
                                            asClass:NSNumber.class] boolValue];
    if (!filterAudioCall) {
        TUIExtensionInfo *audioInfo = [[TUIExtensionInfo alloc] init];
        audioInfo.weight = 500;
        audioInfo.text = TUIKitLocalizableString(TUIKitMoreVoiceCall);
        audioInfo.icon = TUICoreBundleThemeImage(@"service_more_voice_call_img", @"more_voice_call");
        audioInfo.onClicked = ^(NSDictionary * _Nonnull param) {
            [weakSelf doResponseInputViewExtension:param type:TUICallMediaTypeAudio isClassicUI:YES];
        };
        [result addObject:audioInfo];
    }
    
    return result;
}

- (NSArray<TUIExtensionInfo *> *)getFriendProfileActionMenuExtensionForClassicContact:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    __weak typeof(self) weakSelf = self;
    NSMutableArray *result = [NSMutableArray array];
    BOOL filterVideoCall = [[param tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_FilterVideoCall
                                            asClass:NSNumber.class] boolValue];
    if (!filterVideoCall) {
        TUIExtensionInfo *videoInfo = [[TUIExtensionInfo alloc] init];
        videoInfo.weight = 200;
        videoInfo.text = TUIKitLocalizableString(TUIKitMoreVideoCall);
        videoInfo.onClicked = ^(NSDictionary * _Nonnull param) {
            NSString *userID = [param tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_UserID
                                               asClass:NSString.class];
            if (userID.length > 0) {
                [weakSelf startCall:nil userIDs:@[userID] callingType:TUICallMediaTypeVideo];
            }
        };
        [result addObject:videoInfo];
    }
    
    BOOL filterAudioCall = [[param tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_FilterAudioCall
                                            asClass:NSNumber.class] boolValue];
    if (!filterAudioCall) {
        TUIExtensionInfo *audioInfo = [[TUIExtensionInfo alloc] init];
        audioInfo.weight = 100;
        audioInfo.text = TUIKitLocalizableString(TUIKitMoreVoiceCall);
        audioInfo.onClicked = ^(NSDictionary * _Nonnull param) {
            NSString *userID = [param tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_UserID
                                               asClass:NSString.class];
            if (userID.length > 0) {
                [weakSelf startCall:nil userIDs:@[userID] callingType:TUICallMediaTypeAudio];
            }
        };
        [result addObject:audioInfo];
    }
    
    return result;
}

- (NSArray<TUIExtensionInfo *> *)getFriendProfileActionMenuExtensionForMinimalistContact:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    __weak typeof(self) weakSelf = self;
    NSMutableArray *result = [NSMutableArray array];
    BOOL filterVideoCall = [[param tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_FilterVideoCall
                                            asClass:NSNumber.class] boolValue];
    if (!filterVideoCall) {
        TUIExtensionInfo *videoInfo = [[TUIExtensionInfo alloc] init];
        videoInfo.weight = 100;
        videoInfo.icon = TUIDynamicImage(@"",
                                         TUIThemeModuleContact_Minimalist,
                                         [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_video")]);
        videoInfo.text = TIMCommonLocalizableString(TUIKitVideo);
        videoInfo.onClicked = ^(NSDictionary * _Nonnull param) {
            NSString *userID = [param tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_UserID
                                               asClass:NSString.class];
            if (userID.length > 0) {
                [weakSelf startCall:nil userIDs:@[userID] callingType:TUICallMediaTypeVideo];
            }
        };
        [result addObject:videoInfo];
    }
    
    BOOL filterAudioCall = [[param tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_FilterAudioCall
                                            asClass:NSNumber.class] boolValue];
    if (!filterAudioCall) {
        TUIExtensionInfo *audioInfo = [[TUIExtensionInfo alloc] init];
        audioInfo.weight = 200;
        audioInfo.icon = TUIDynamicImage(@"",
                                         TUIThemeModuleContact_Minimalist,
                                         [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_audio")]);
        audioInfo.text = TIMCommonLocalizableString(TUIKitAudio);
        audioInfo.onClicked = ^(NSDictionary * _Nonnull param) {
            NSString *userID = [param tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_UserID
                                               asClass:NSString.class];
            if (userID.length > 0) {
                [weakSelf startCall:nil userIDs:@[userID] callingType:TUICallMediaTypeAudio];
            }
        };
        [result addObject:audioInfo];
    }
    
    return result;
}

- (NSArray<TUIExtensionInfo *> *)getGroupInfoCardActionMenuExtensionForMinimalistGroup:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    __weak typeof(self) weakSelf = self;
    NSMutableArray *result = [NSMutableArray array];
    BOOL filterVideoCall = [[param tui_objectForKey:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_FilterVideoCall
                                            asClass:NSNumber.class] boolValue];
    if (!filterVideoCall) {
        TUIExtensionInfo *videoInfo = [[TUIExtensionInfo alloc] init];
        videoInfo.weight = 100;
        videoInfo.icon = TUIDynamicImage(@"",
                                         TUIThemeModuleContact_Minimalist,
                                         [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_video")]);
        videoInfo.text = TIMCommonLocalizableString(TUIKitVideo);
        videoInfo.onClicked = ^(NSDictionary * _Nonnull param) {
            UINavigationController *pushVC = [param tui_objectForKey:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_PushVC
                                                             asClass:UINavigationController.class];
            NSString *groupID = [param tui_objectForKey:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_GroupID
                                                asClass:NSString.class];
            if (pushVC && groupID.length > 0) {
                [weakSelf launchCall:TUICallMediaTypeVideo inGroup:groupID withPushVC:pushVC isClassicUI:NO];
            }
        };
        [result addObject:videoInfo];
    }
    
    BOOL filterAudioCall = [[param tui_objectForKey:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_FilterAudioCall
                                            asClass:NSNumber.class] boolValue];
    if (!filterAudioCall) {
        TUIExtensionInfo *audioInfo = [[TUIExtensionInfo alloc] init];
        audioInfo.weight = 200;
        audioInfo.icon = TUIDynamicImage(@"",
                                         TUIThemeModuleContact_Minimalist,
                                         [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_audio")]);
        audioInfo.text = TIMCommonLocalizableString(TUIKitAudio);
        audioInfo.onClicked = ^(NSDictionary * _Nonnull param) {
            UINavigationController *pushVC = [param tui_objectForKey:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_PushVC
                                                             asClass:UINavigationController.class];
            NSString *groupID = [param tui_objectForKey:TUICore_TUIGroupExtension_GroupInfoCardActionMenu_GroupID
                                                asClass:NSString.class];
            if (pushVC && groupID.length > 0) {
                [weakSelf launchCall:TUICallMediaTypeAudio inGroup:groupID withPushVC:pushVC isClassicUI:NO];
            }
        };
        [result addObject:audioInfo];
    }
    
    return result;
}

#pragma mark - Utils

- (void)doResponseInputViewExtension:(NSDictionary *)param type:(TUICallMediaType)type isClassicUI:(BOOL)isClassic {
    NSString *userID = [param tui_objectForKey:TUICore_TUIChatExtension_InputViewMoreItem_UserID
                                       asClass:NSString.class];
    NSString *groupID = [param tui_objectForKey:TUICore_TUIChatExtension_InputViewMoreItem_GroupID
                                        asClass:NSString.class];
    UINavigationController *pushVC = [param tui_objectForKey:TUICore_TUIChatExtension_InputViewMoreItem_PushVC
                                                     asClass:UINavigationController.class];
    if (userID.length > 0) {
        // c2c video call
        [self startCall:nil userIDs:@[userID] callingType:type];
    } else if (groupID.length > 0 && pushVC) {
        // group video call
        [self launchCall:type inGroup:groupID withPushVC:pushVC isClassicUI:isClassic];
    }
}

- (void)launchCall:(TUICallMediaType)type
           inGroup:(NSString *)groupID
        withPushVC:(UINavigationController *)pushVC
       isClassicUI:(BOOL)isClassic {
    if (groupID.length > 0 && pushVC) {
        // group audio call
        NSMutableDictionary *requestParam = [NSMutableDictionary dictionary];
        requestParam[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_GroupID] = groupID;
        requestParam[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Name] = TIMCommonLocalizableString(Make-a-call);
        NSString *viewControllerKey = isClassic ?
                                      TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Classic :
                                      TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Minimalist;
        __weak typeof(self) weakSelf = self;
        [pushVC pushViewController:viewControllerKey param:requestParam forResult:^(NSDictionary * _Nonnull responseData) {
            NSArray<TUIUserModel *> *modelList = [responseData tui_objectForKey:TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_ResultUserList
                                                                        asClass:NSArray.class];
            NSMutableArray *userIDs = [NSMutableArray arrayWithCapacity:modelList.count];
            for (TUIUserModel *user in modelList) {
                NSParameterAssert(user.userId);
                [userIDs addObject:user.userId];
            }
            [weakSelf startCall:groupID userIDs:userIDs callingType:type];
        }];
    }
}

- (void)startCall:(NSString *)groupID userIDs:(NSArray *)userIDs callingType:(TUICallMediaType)callingType {
    if ([[TUICallEngine createInstance] respondsToSelector:@selector(setOnlineUserOnly:)]) {
        [[TUICallEngine createInstance] performSelector:@selector(setOnlineUserOnly:) withObject:@(0)];
    }
    
    if (groupID && [groupID isKindOfClass:NSString.class]) {
        [[TUICallKit createInstance] groupCall:groupID userIdList:userIDs callMediaType:callingType];
    } else {
        [[TUICallKit createInstance] call:[userIDs firstObject] callMediaType:callingType];
    }
}

@end
