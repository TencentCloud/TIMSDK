//
//  TUIGroupObjectFactory.m
//  TUIGroup
//
//  Created by wyl on 2023/3/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGroupObjectFactory.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIGroupInfoController.h"
#import "TUIGroupRequestViewController.h"
#import "TUISelectGroupMemberViewController.h"

@interface TUIGroupObjectFactory () <TUIObjectProtocol>
@end

@implementation TUIGroupObjectFactory
+ (void)load {
    [TUICore registerObjectFactory:TUICore_TUIGroupObjectFactory objectFactory:[TUIGroupObjectFactory shareInstance]];
}
+ (TUIGroupObjectFactory *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIGroupObjectFactory *g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
      g_sharedInstance = [[TUIGroupObjectFactory alloc] init];
    });
    return g_sharedInstance;
}

#pragma mark - TUIObjectProtocol
- (id)onCreateObject:(NSString *)method param:(nullable NSDictionary *)param {
    id returnObject = nil;

    if ([method isEqualToString:TUICore_TUIGroupObjectFactory_GetGroupRequestViewControllerMethod]) {
        returnObject =
            [self createGroupRequestViewController:[param tui_objectForKey:TUICore_TUIGroupObjectFactory_GetGroupRequestViewControllerMethod_GroupInfoKey
                                                                   asClass:V2TIMGroupInfo.class]];

    } else if ([method isEqualToString:TUICore_TUIGroupObjectFactory_GetGroupInfoVC_Classic]) {
        returnObject = [self createGroupInfoController:[param tui_objectForKey:TUICore_TUIGroupObjectFactory_GetGroupInfoVC_GroupID asClass:NSString.class]];

    } else if ([method isEqualToString:TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Classic]) {
        NSString *groupID = [param tui_objectForKey:TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_GroupID asClass:NSString.class];
        NSString *title = [param tui_objectForKey:TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Name asClass:NSString.class];
        NSNumber *optionalStyleNum = [param tui_objectForKey:TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_OptionalStyle asClass:NSNumber.class];
        NSArray *selectedUserIDList = [param tui_objectForKey:TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_SelectedUserIDList asClass:NSArray.class];

        returnObject = [self createSelectGroupMemberViewController:groupID
                                                              name:title
                                                     optionalStyle:[optionalStyleNum integerValue]
                                                selectedUserIDList:selectedUserIDList
                                                          userData:@""];
    }
    return returnObject;
}

- (UIViewController *)createGroupRequestViewController:(V2TIMGroupInfo *)groupInfo {
    TUIGroupRequestViewController *vc = [[TUIGroupRequestViewController alloc] init];
    vc.groupInfo = groupInfo;
    return vc;
}

- (UIViewController *)createGroupInfoController:(NSString *)groupID {
    TUIGroupInfoController *vc = [[TUIGroupInfoController alloc] init];
    vc.groupId = groupID;
    return vc;
}

- (UIViewController *)createSelectGroupMemberViewController:(NSString *)groupID
                                                       name:(NSString *)name
                                              optionalStyle:(TUISelectMemberOptionalStyle)optionalStyle {
    return [self createSelectGroupMemberViewController:groupID name:name optionalStyle:optionalStyle selectedUserIDList:@[]];
}

- (UIViewController *)createSelectGroupMemberViewController:(NSString *)groupID
                                                       name:(NSString *)name
                                              optionalStyle:(TUISelectMemberOptionalStyle)optionalStyle
                                         selectedUserIDList:(NSArray *)userIDList {
    return [self createSelectGroupMemberViewController:groupID name:name optionalStyle:optionalStyle selectedUserIDList:@[] userData:@""];
}

- (UIViewController *)createSelectGroupMemberViewController:(NSString *)groupID
                                                       name:(NSString *)name
                                              optionalStyle:(TUISelectMemberOptionalStyle)optionalStyle
                                         selectedUserIDList:(NSArray *)userIDList
                                                   userData:(NSString *)userData {
    TUISelectGroupMemberViewController *vc = [[TUISelectGroupMemberViewController alloc] init];
    vc.groupId = groupID;
    vc.name = name;
    vc.optionalStyle = optionalStyle;
    vc.selectedUserIDList = userIDList;
    vc.userData = userData;
    return vc;
}
@end
