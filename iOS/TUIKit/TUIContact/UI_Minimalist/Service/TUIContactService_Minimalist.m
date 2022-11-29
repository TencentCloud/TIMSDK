//
//  TUIContactService_Minimalist.m
//  lottie-ios
//
//  Created by kayev on 2021/8/18.
//

#import "TUIContactService_Minimalist.h"
#import "TUIContactController_Minimalist.h"
#import "TUIContactSelectController_Minimalist.h"
#import "TUIFriendProfileController_Minimalist.h"
#import "TUIUserProfileController_Minimalist.h"

@implementation TUIContactService_Minimalist

+ (void)load {
    [TUICore registerService:TUICore_TUIContactService_Minimalist object:[TUIContactService_Minimalist shareInstance]];
}

+ (TUIContactService_Minimalist *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIContactService_Minimalist * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIContactService_Minimalist alloc] init];
    });
    return g_sharedInstance;
}

#pragma mark - TUIServiceProtocol
- (id)onCall:(NSString *)method param:(NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIContactService_GetContactControllerMethod]) {
        return [self createContactController];
    } else if ([method isEqualToString:TUICore_TUIContactService_GetContactSelectControllerMethod]) {
        NSString *title = [param objectForKey:TUICore_TUIContactService_GetContactSelectControllerMethod_TitleKey];
        NSArray *sourceIds = [param objectForKey:TUICore_TUIContactService_GetContactSelectControllerMethod_SourceIdsKey];
        NSArray *disableIds = [param objectForKey:TUICore_TUIContactService_GetContactSelectControllerMethod_DisableIdsKey];
        NSDictionary *displayNames = [param objectForKey:TUICore_TUIContactService_GetContactSelectControllerMethod_DisplayNamesKey];
        return [self createContactSelectController:sourceIds disableIds:disableIds title:title displayNames:displayNames];
    } else if ([method isEqualToString:TUICore_TUIContactService_GetFriendProfileControllerMethod]) {
        V2TIMFriendInfo *friendInfo = [param objectForKey:TUICore_TUIContactService_GetFriendProfileControllerMethod_FriendProfileKey];
        return [self createFriendProfileController:friendInfo];
    } else if ([method isEqualToString:TUICore_TUIContactService_GetUserProfileControllerMethod]) {
        V2TIMUserFullInfo *userInfo = [param objectForKey:TUICore_TUIContactService_GetUserProfileControllerMethod_UserProfileKey];
        TUICommonCellData * cellData = [param objectForKey:TUICore_TUIContactService_GetUserProfileControllerMethod_PendencyDataKey];
        ProfileControllerAction_Minimalist action = (ProfileControllerAction_Minimalist)([[param objectForKey:TUICore_TUIContactService_GetUserProfileControllerMethod_ActionTypeKey] unsignedIntegerValue]);
        return [self createUserProfileController:userInfo pendencyData:cellData actionType:action];
    } else if ([method isEqualToString:TUICore_TUIContactService_GetUserOrFriendProfileVCMethod]) {
        NSString *userID = [param objectForKey:TUICore_TUIContactService_GetUserOrFriendProfileVCMethod_UserIDKey];
        void(^succ)(UIViewController *vc) = [param objectForKey:TUICore_TUIContactService_GetUserOrFriendProfileVCMethod_SuccKey];
        V2TIMFail fail = [param objectForKey:TUICore_TUIContactService_GetUserOrFriendProfileVCMethod_FailKey];
        [self createUserOrFriendProfileVCWithUserID:userID succBlock:succ failBlock:fail];
    }
    return nil;
}

- (UIViewController *)createContactController {
    return [[TUIContactController_Minimalist alloc] init];
}

- (UIViewController *)createContactSelectController:(NSArray *)sourceIds
                                                   disableIds:(NSArray *)disableIds {
    return [self createContactSelectController:sourceIds disableIds:disableIds title:nil displayNames:nil];
}

- (UIViewController *)createContactSelectController:(NSArray *)sourceIds
                                                   disableIds:(NSArray *)disableIds
                                                        title:(NSString *)title
                                                 displayNames:(NSDictionary *)displayNames {
    TUIContactSelectController_Minimalist *vc = [[TUIContactSelectController_Minimalist alloc] init];
    vc.displayNames = displayNames;
    vc.title = title;
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
    return vc;
}

- (UIViewController *)createFriendProfileController:(V2TIMFriendInfo *)friendInfo {
    TUIFriendProfileController_Minimalist *vc = [[TUIFriendProfileController_Minimalist alloc] init];
    vc.friendProfile = friendInfo;
    return vc;
}

- (UIViewController *)createUserProfileController:(V2TIMUserFullInfo *)user
                                       actionType:(ProfileControllerAction_Minimalist)actionType {
    TUIUserProfileController_Minimalist *vc = [[TUIUserProfileController_Minimalist alloc] init];
    vc.userFullInfo = user;
    vc.actionType = actionType;
    return vc;
}

- (UIViewController *)createUserProfileController:(V2TIMUserFullInfo *)user
                                     pendencyData:(TUICommonCellData *)data
                                       actionType:(ProfileControllerAction_Minimalist)actionType {
    TUIUserProfileController_Minimalist *vc = [[TUIUserProfileController_Minimalist alloc] init];
    vc.userFullInfo = user;
    vc.actionType = actionType;
    if (actionType == PCA_GROUP_CONFIRM_MINI) {
        if ([data isKindOfClass:[TUIGroupPendencyCellData class]]) {
            vc.groupPendency =  (TUIGroupPendencyCellData *)data;
        }
    }
    else if (actionType == PCA_PENDENDY_CONFIRM_MINI){
        vc.pendency =  (TUICommonPendencyCellData *)data;
    }
    return vc;
}
- (void)createUserOrFriendProfileVCWithUserID:(NSString *)userID
                                    succBlock:(void(^)(UIViewController *vc))succ
                                    failBlock:(nullable V2TIMFail)fail {
    if (userID.length == 0) {
        if (fail) {
            fail(-1, @"invalid parameter, userID is nil");
        }
        return;
    }
    @weakify(self);
    [[V2TIMManager sharedInstance] getFriendsInfo:@[userID]
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
            [[V2TIMManager sharedInstance] getUsersInfo:@[userID]
                                                   succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                V2TIMUserFullInfo *user = infoList.firstObject;
                if (user == nil) {
                    if (fail) {
                        fail(-1, @"invalid parameter, user info is nil");
                        return;
                    }
                }
                NSUInteger actionType = [user.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]] ? 0 : 1;
                UIViewController *vc = [self createUserProfileController:user actionType:actionType];
                if (succ) {
                    succ(vc);
                }
            } fail:fail];
        }
    } fail:fail];
}

@end
