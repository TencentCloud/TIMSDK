//
//  TUIContactObjectFactory.m
//  TUIContact
//
//  Created by wyl on 2023/3/29.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactObjectFactory.h"
#import <TUICore/TUIThemeManager.h>
#import "TUIContactController.h"
#import "TUIContactSelectController.h"
#import "TUIFriendProfileController.h"
#import "TUIGroupCreateController.h"
#import "TUIUserProfileController.h"
#import "TUIGroupMemberController.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIGroupRequestViewController.h"
#import "TUISelectGroupMemberViewController.h"

@interface TUIContactObjectFactory () <TUIObjectProtocol>
@end

@implementation TUIContactObjectFactory
+ (void)load {
    [TUICore registerObjectFactory:TUICore_TUIContactObjectFactory objectFactory:[TUIContactObjectFactory shareInstance]];
}
+ (TUIContactObjectFactory *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIContactObjectFactory *g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
      g_sharedInstance = [[TUIContactObjectFactory alloc] init];
    });
    return g_sharedInstance;
}

#pragma mark - TUIObjectProtocol
- (id)onCreateObject:(NSString *)method param:(nullable NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIContactObjectFactory_GetContactControllerMethod]) {
        return [self createContactController];
    } else if ([method isEqualToString:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod]) {
        NSString *title = [param objectForKey:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_TitleKey];
        NSArray *sourceIds = [param objectForKey:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_SourceIdsKey];
        NSArray *disableIds = [param objectForKey:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisableIdsKey];
        NSDictionary *displayNames = [param objectForKey:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisplayNamesKey];
        NSNumber *maxSelectCount = [param objectForKey:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_MaxSelectCount];
        void (^completion)(NSArray<TUICommonContactSelectCellData *> *) =
            [param objectForKey:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey];
        return [self createContactSelectController:sourceIds
                                        disableIds:disableIds
                                             title:title
                                      displayNames:displayNames
                                    maxSelectCount:[maxSelectCount intValue]
                                        completion:completion];
    } else if ([method isEqualToString:TUICore_TUIContactObjectFactory_GetFriendProfileControllerMethod]) {
        V2TIMFriendInfo *friendInfo = [param objectForKey:TUICore_TUIContactObjectFactory_GetFriendProfileControllerMethod_FriendProfileKey];
        return [self createFriendProfileController:friendInfo];
    } else if ([method isEqualToString:TUICore_TUIContactObjectFactory_UserProfileController_Classic]) {
        V2TIMUserFullInfo *userInfo = [param objectForKey:TUICore_TUIContactObjectFactory_UserProfileController_UserProfile];
        TUICommonCellData *cellData = [param objectForKey:TUICore_TUIContactObjectFactory_UserProfileController_PendencyData];
        ProfileControllerAction action =
            (ProfileControllerAction)([[param objectForKey:TUICore_TUIContactObjectFactory_UserProfileController_ActionType] unsignedIntegerValue]);
        return [self createUserProfileController:userInfo pendencyData:cellData actionType:action];
    } else if ([method isEqualToString:TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod]) {
        NSString *title = [param tui_objectForKey:TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_TitleKey asClass:NSString.class];
        NSString *groupName = [param tui_objectForKey:TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_GroupNameKey asClass:NSString.class];
        NSString *groupType = [param tui_objectForKey:TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_GroupTypeKey asClass:NSString.class];
        NSArray *contactList = [param tui_objectForKey:TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_ContactListKey asClass:NSArray.class];
        void (^completion)(BOOL, V2TIMGroupInfo *) = [param objectForKey:TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_CompletionKey];
        return [self createGroupCreateController:title groupName:groupName groupType:groupType contactList:contactList completion:completion];

    } else if ([method isEqualToString:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod]) {
        NSString *userID = [param objectForKey:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey];
        void (^succ)(UIViewController *vc) = [param objectForKey:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey];
        V2TIMFail fail = [param objectForKey:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey];
        [self createUserOrFriendProfileVCWithUserID:userID succBlock:succ failBlock:fail];
    }
    else if ([method isEqualToString:TUICore_TUIContactObjectFactory_GetGroupMemberVCMethod]) {
        NSString *groupId = [param objectForKey:@"groupID"];
        V2TIMGroupInfo *groupInfo = [param objectForKey:@"groupInfo"];
        TUIGroupMemberController *membersController = [[TUIGroupMemberController alloc] init];
        membersController.groupId = groupId;
        membersController.groupInfo = groupInfo;
        return membersController;
    }
    else if ([method isEqualToString:TUICore_TUIContactObjectFactory_GetGroupRequestViewControllerMethod]) {
        return  [self createGroupRequestViewController:[param tui_objectForKey:TUICore_TUIContactObjectFactory_GetGroupRequestViewControllerMethod_GroupInfoKey
                                                                   asClass:V2TIMGroupInfo.class]];
    } else if ([method isEqualToString:TUICore_TUIContactObjectFactory_GetGroupInfoVC_Classic]) {
        return [self createGroupInfoController:[param tui_objectForKey:TUICore_TUIContactObjectFactory_GetGroupInfoVC_GroupID asClass:NSString.class]];
    } else if ([method isEqualToString:TUICore_TUIContactObjectFactory_SelectGroupMemberVC_Classic]) {
        NSString *groupID = [param tui_objectForKey:TUICore_TUIContactObjectFactory_SelectGroupMemberVC_GroupID asClass:NSString.class];
        NSString *title = [param tui_objectForKey:TUICore_TUIContactObjectFactory_SelectGroupMemberVC_Name asClass:NSString.class];
        NSNumber *optionalStyleNum = [param tui_objectForKey:TUICore_TUIContactObjectFactory_SelectGroupMemberVC_OptionalStyle asClass:NSNumber.class];
        NSArray *selectedUserIDList = [param tui_objectForKey:TUICore_TUIContactObjectFactory_SelectGroupMemberVC_SelectedUserIDList asClass:NSArray.class];

        return [self createSelectGroupMemberViewController:groupID
                                                              name:title
                                                     optionalStyle:[optionalStyleNum integerValue]
                                                selectedUserIDList:selectedUserIDList
                                                          userData:@""];
    }
    return nil;
}

- (UIViewController *)createContactController {
    return [[TUIContactController alloc] init];
}

- (UIViewController *)createContactSelectController:(NSArray *)sourceIds
                                         disableIds:(NSArray *)disableIds
                                              title:(NSString *)title
                                       displayNames:(NSDictionary *)displayNames
                                     maxSelectCount:(int)maxSelectCount
                                         completion:(void (^)(NSArray<TUICommonContactSelectCellData *> *selectArray))completion {
    TUIContactSelectController *vc = [[TUIContactSelectController alloc] init];
    vc.title = title;
    vc.displayNames = displayNames;
    vc.maxSelectCount = maxSelectCount;
    if (sourceIds.count > 0) {
        vc.sourceIds = sourceIds;
    } else if (disableIds.count > 0) {
        vc.viewModel.disableFilter = ^BOOL(TUICommonContactSelectCellData *data) {
          for (NSString *identifier in disableIds) {
              if ([identifier isEqualToString:data.identifier]) {
                  return YES;
              }
          }
          return NO;
        };
    }
    vc.finishBlock = ^(NSArray<TUICommonContactSelectCellData *> *_Nonnull selectArray) {
      if (completion) {
          completion(selectArray);
      }
    };
    return vc;
}

- (UIViewController *)createFriendProfileController:(V2TIMFriendInfo *)friendInfo {
    TUIFriendProfileController *vc = [[TUIFriendProfileController alloc] init];
    vc.friendProfile = friendInfo;
    return vc;
}

- (UIViewController *)createUserProfileController:(V2TIMUserFullInfo *)user actionType:(ProfileControllerAction)actionType {
    TUIUserProfileController *vc = [[TUIUserProfileController alloc] init];
    vc.userFullInfo = user;
    vc.actionType = actionType;
    return vc;
}

- (UIViewController *)createUserProfileController:(V2TIMUserFullInfo *)user
                                     pendencyData:(TUICommonCellData *)data
                                       actionType:(ProfileControllerAction)actionType {
    TUIUserProfileController *vc = [[TUIUserProfileController alloc] init];
    vc.userFullInfo = user;
    vc.actionType = actionType;
    if (actionType == PCA_GROUP_CONFIRM) {
        if ([data isKindOfClass:[TUIGroupPendencyCellData class]]) {
            vc.groupPendency = (TUIGroupPendencyCellData *)data;
        }
    } else if (actionType == PCA_PENDENDY_CONFIRM) {
        vc.pendency = (TUICommonPendencyCellData *)data;
    }
    return vc;
}

- (UIViewController *)createGroupCreateController:(NSString *)title
                                        groupName:(NSString *)groupName
                                        groupType:(NSString *)groupType
                                      contactList:(NSArray<TUICommonContactSelectCellData *> *)contactList
                                       completion:(void (^)(BOOL isSuccess, V2TIMGroupInfo *_Nonnull info))completion {
    TUIGroupCreateController *vc = [[TUIGroupCreateController alloc] init];
    vc.title = @"";

    V2TIMGroupInfo *createGroupInfo = [[V2TIMGroupInfo alloc] init];
    createGroupInfo.groupID = @"";
    createGroupInfo.groupName = groupName;
    createGroupInfo.groupType = groupType;
    vc.createGroupInfo = createGroupInfo;
    vc.createContactArray = [NSArray arrayWithArray:contactList];

    vc.submitCallback = ^(BOOL isSuccess, V2TIMGroupInfo *_Nonnull info) {
      if (completion) {
          completion(isSuccess, info);
      }
    };
    return vc;
}

- (void)createUserOrFriendProfileVCWithUserID:(NSString *)userID succBlock:(void (^)(UIViewController *vc))succ failBlock:(nullable V2TIMFail)fail {
    if (userID.length == 0) {
        if (fail) {
            fail(-1, @"invalid parameter, userID is nil");
        }
        return;
    }
    @weakify(self);
    [[V2TIMManager sharedInstance] getFriendsInfo:@[ userID ]
                                             succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
                                               @strongify(self);
                                               V2TIMFriendInfoResult *friend = resultList.firstObject;
                                               if (friend.relation & V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST) {
                                                   if (friend.friendInfo == nil) {
                                                       if (fail) {
                                                           fail(-1, @"invalid parameter, friend info is nil");
                                                       }
                                                       return;
                                                   }
                                                   UIViewController *vc = [self createFriendProfileController:friend.friendInfo];
                                                   if (succ) {
                                                       succ(vc);
                                                   }
                                               } else {
                                                   [[V2TIMManager sharedInstance]
                                                       getUsersInfo:@[ userID ]
                                                               succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                                                                 V2TIMUserFullInfo *user = infoList.firstObject;
                                                                 if (user == nil) {
                                                                     if (fail) {
                                                                         fail(-1, @"invalid parameter, user info is nil");
                                                                         return;
                                                                     }
                                                                 }
                                                                 NSUInteger actionType =
                                                                     [user.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]] ? 0 : 1;
                                                                 UIViewController *vc = [self createUserProfileController:user actionType:actionType];
                                                                 if (succ) {
                                                                     succ(vc);
                                                                 }
                                                               }
                                                               fail:fail];
                                               }
                                             }
                                             fail:fail];
}


#pragma mark - TUIObjectProtocol - groupInfo

- (UIViewController *)createGroupRequestViewController:(V2TIMGroupInfo *)groupInfo {
    TUIGroupRequestViewController *vc = [[TUIGroupRequestViewController alloc] init];
    vc.groupInfo = groupInfo;
    return vc;
}

- (UIViewController *)createGroupInfoController:(NSString *)groupID {

    return nil;
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
