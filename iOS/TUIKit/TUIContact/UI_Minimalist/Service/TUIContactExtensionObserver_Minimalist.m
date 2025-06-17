//
//  TUIContactExtensionObserver.m
//  TUIContact
//
//  Created by harvy on 2023/3/29.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactExtensionObserver_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TUICore/TUICore.h>
#import "TUIGroupManageController_Minimalist.h"
#import "TUIGroupMemberController_Minimalist.h"
#import "TUIGroupMemberTableViewCell_Minimalist.h"
#import "TUISelectGroupMemberViewController_Minimalist.h"
#import <TIMCommon/TUICommonGroupInfoCellData.h>

@interface TUIContactExtensionObserver_Minimalist () <TUIExtensionProtocol,TUINotificationProtocol>
//TUICore_TUIChatExtension_GroupProfileMemberListExtension_MinimalistExtensionID
//pargm start
@property(nonatomic, assign) NSInteger tag;
@property(nonatomic,strong) UINavigationController *pushVC;
@property(nonatomic,copy) NSString *groupId;
@property(nonatomic, strong) UIViewController *showContactSelectVC;
@property(nonatomic, strong) NSMutableArray<TUIGroupMemberCellData_Minimalist *> *membersData;
//pargm end
@end

@implementation TUIContactExtensionObserver_Minimalist

+ (void)load {

    
    [TUICore registerExtension:TUICore_TUIChatExtension_GroupProfileMemberListExtension_MinimalistExtensionID
                        object:TUIContactExtensionObserver_Minimalist.shareInstance];
    
    [TUICore registerExtension:TUICore_TUIChatExtension_GroupProfileSettingsItemExtension_MinimalistExtensionID
                        object:TUIContactExtensionObserver_Minimalist.shareInstance];
    
    [TUICore registerExtension:TUICore_TUIChatExtension_GroupProfileBottomItemExtension_MinimalistExtensionID
                        object:TUIContactExtensionObserver_Minimalist.shareInstance];
    
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self = [super init]) {
        [self configNotify];
    }
    return self;
}

- (void)configNotify {
    [TUICore registerEvent:TUICore_TUIContactNotify
                    subKey:TUICore_TUIContactNotify_OnAddMemebersClickSubKey object:self];
}

#pragma mark - TUINotificationProtocol
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(id)anObject param:(NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIContactNotify] && [subKey isEqualToString:TUICore_TUIContactNotify_OnAddMemebersClickSubKey]) {
        [self didAddMemebers];
    }
}
#pragma mark - TUIExtensionProtocol

- (BOOL)onRaiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param {
    if ([extensionID isEqualToString:TUICore_TUIChatExtension_GroupProfileMemberListExtension_MinimalistExtensionID]) {
        TUIGroupMemberCellData_Minimalist * data  = [param objectForKey:@"data"];
        self.groupId = [param objectForKey:@"groupID"];
        self.pushVC = [param tui_objectForKey:@"pushVC" asClass:UINavigationController.class];
        self.membersData = [param tui_objectForKey:@"membersData" asClass:NSMutableArray.class];
        if (![parentView isKindOfClass:UIView.class]) {
            return NO;
        }
        if (![parentView isKindOfClass:UIView.class]) {
            return NO;
        }
        TUIGroupMemberTableViewCell_Minimalist *cell = [[TUIGroupMemberTableViewCell_Minimalist alloc]
                                                        initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [parentView addSubview:cell];
        parentView.userInteractionEnabled = YES;
        cell.frame = parentView.frame;
        cell.backgroundColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF");
        [cell fillWithData:data];
        [cell setTapAction:^{
            [self didCurrentMemberAtCell:data];
        }];
        return YES;
    }
    return NO;
    
}
- (NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(NSDictionary *)param {
    if (![extensionID isKindOfClass:NSString.class]) {
        return nil;
    }
    if ([extensionID
              isEqualToString:TUICore_TUIChatExtension_GroupProfileSettingsItemExtension_MinimalistExtensionID]) {
        return [self getGroupProfileSettingsItemExtensionForMinimalistChat:param];
    }
    else if ([extensionID isEqualToString:TUICore_TUIChatExtension_GroupProfileBottomItemExtension_MinimalistExtensionID]) {
        return [self getGroupProfileBottomItemExtensionForMinimalist:param];
    }
    else {
        return nil;
    }
}

- (NSArray<TUIExtensionInfo *> *)getGroupProfileSettingsItemExtensionForMinimalistChat:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    NSString *groupID = [param tui_objectForKey:@"groupID" asClass:NSString.class];

    if (groupID.length > 0) {
        UINavigationController *pushVC = [param tui_objectForKey:@"pushVC" asClass:UINavigationController.class];
        TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
        info.icon = nil;
        info.weight = 100;
        info.text = TIMCommonLocalizableString(TUIKitGroupProfileManage);
        info.onClicked = ^(NSDictionary *_Nonnull clickParam) {
            if (pushVC) {
                TUIGroupManageController_Minimalist *vc = [[TUIGroupManageController_Minimalist alloc] init];
                vc.groupID = groupID;
                [pushVC pushViewController:vc animated:YES];
            }
        };
        return @[ info ];
    }

    
    return nil;
}
- (NSArray<TUIExtensionInfo *> *)getGroupProfileBottomItemExtensionForMinimalist:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    NSString *groupID = [param tui_objectForKey:@"groupID" asClass:NSString.class];
    if (groupID.length > 0) {
        void (^updateGroupInfoCallback)(void) = param[@"updateGroupInfoCallback"];
        UINavigationController *pushVC = [param tui_objectForKey:@"pushVC" asClass:UINavigationController.class];

        TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
        info.icon = nil;
        info.weight = 100;
        info.text = TIMCommonLocalizableString(TUIKitGroupTransferOwner);
        info.onClicked = ^(NSDictionary *_Nonnull clickparam) {
            TUISelectGroupMemberViewController_Minimalist *vc = [[TUISelectGroupMemberViewController_Minimalist alloc] init];
            vc.optionalStyle = TUISelectMemberOptionalStyleTransferOwner;
            vc.groupId = groupID;
            vc.name = TIMCommonLocalizableString(TUIKitGroupTransferOwner);
            @weakify(self);
            vc.selectedFinished = ^(NSMutableArray<TUIUserModel *> *_Nonnull modelList) {
              @strongify(self);
              TUIUserModel *userModel = modelList[0];
              NSString *groupId = groupID;
              NSString *member = userModel.userId;
              if (userModel && [userModel isKindOfClass:[TUIUserModel class]]) {
                  @weakify(self);
                  [self transferGroupOwner:groupId
                      member:member
                      succ:^{
                        @strongify(self);
                          if (updateGroupInfoCallback) {
                              updateGroupInfoCallback();
                          }
                        [TUITool makeToast:TIMCommonLocalizableString(TUIKitGroupTransferOwnerSuccess)];
                      }
                      fail:^(int code, NSString *desc) {
                        [TUITool makeToastError:code msg:desc];
                      }];
              }
            };
            [pushVC pushViewController:vc animated:YES];
        };
        return @[ info ];
       
    }

    return nil;
}

- (void)transferGroupOwner:(NSString *)groupID member:(NSString *)userID succ:(V2TIMSucc)succ fail:(V2TIMFail)fail {
    [V2TIMManager.sharedInstance transferGroupOwner:groupID
        member:userID
        succ:^{
          succ();
        }
        fail:^(int code, NSString *desc) {
          fail(code, desc);
        }];
}


#pragma mark Click

- (void)didAddMemebers {
    NSMutableArray *ids = [NSMutableArray array];
    NSMutableDictionary *displayNames = [NSMutableDictionary dictionary];
    for (TUIGroupMemberCellData *cd in self.membersData) {
        if (![cd.identifier isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
            [ids addObject:cd.identifier];
            [displayNames setObject:cd.name ?: @"" forKey:cd.identifier ?: @""];
        }
    }

    @weakify(self);
    void (^selectContactCompletion)(NSArray<TUICommonContactSelectCellData *> *) = ^(NSArray<TUICommonContactSelectCellData *> *array) {
      @strongify(self);
      if (self.tag == 1) {
          // add
          NSMutableArray *list = @[].mutableCopy;
          for (TUICommonContactSelectCellData *data in array) {
              [list addObject:data.identifier];
          }
          [self.pushVC popViewControllerAnimated:YES];
          [self addGroupId:self.groupId memebers:list];
      } else if (self.tag == 2) {
          // delete
          NSMutableArray *list = @[].mutableCopy;
          for (TUICommonContactSelectCellData *data in array) {
              [list addObject:data.identifier];
          }
          [self.pushVC popViewControllerAnimated:YES];
          [self deleteGroupId:self.groupId memebers:list];
      }
    };

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_TitleKey] = TIMCommonLocalizableString(GroupAddFirend);
    param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisableIdsKey] = ids;
    param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisplayNamesKey] = displayNames;
    param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey] = selectContactCompletion;
    UIViewController *vc = [TUICore createObject:TUICore_TUIContactObjectFactory_Minimalist
                                             key:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod
                                           param:param];
    if (vc && [vc isKindOfClass:UIViewController.class]) {
        [self.pushVC pushViewController:vc animated:YES];
    }
    self.tag = 1;
}

- (void)didCurrentMemberAtCell:(TUIGroupMemberCellData_Minimalist *)data {
    TUIGroupMemberCellData_Minimalist *mem = data;
    NSMutableArray *ids = [NSMutableArray array];
    NSMutableDictionary *displayNames = [NSMutableDictionary dictionary];
    for (TUIGroupMemberCellData *cd in self.membersData) {
        if (![cd.identifier isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
            [ids addObject:cd.identifier];
            [displayNames setObject:cd.name ?: @"" forKey:cd.identifier ?: @""];
        }
    }

    NSString *userID = mem.identifier;
    @weakify(self);
    [self getUserOrFriendProfileVCWithUserID:userID
                                   SuccBlock:^(UIViewController *vc) {
                                     @strongify(self);
                                      [self.pushVC pushViewController:vc animated:YES];
                                   }
                                   failBlock:^(int code, NSString *desc){

                                   }];
}

- (void)getUserOrFriendProfileVCWithUserID:(NSString *)userID SuccBlock:(void (^)(UIViewController *vc))succ failBlock:(nullable V2TIMFail)fail {
    NSDictionary *param = @{
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey: userID ? : @"",
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey: succ ? : ^(UIViewController *vc){},
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey: fail ? : ^(int code, NSString * desc){}
    };
    [TUICore createObject:TUICore_TUIContactObjectFactory_Minimalist key:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod param:param];
}

- (void)addGroupId:(NSString *)groupId memebers:(NSArray *)members {
    @weakify(self);
    [[V2TIMManager sharedInstance] inviteUserToGroup:_groupId
        userList:members
        succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
          [TUITool makeToast:TIMCommonLocalizableString(add_success)];
        }
        fail:^(int code, NSString *desc) {
          [TUITool makeToastError:code msg:desc];
        }];
}

- (void)deleteGroupId:(NSString *)groupId memebers:(NSArray *)members {
    @weakify(self);
    [[V2TIMManager sharedInstance] kickGroupMember:groupId
        memberList:members
        reason:@""
        succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
          @strongify(self);
          [TUITool makeToast:TIMCommonLocalizableString(delete_success)];
        }
        fail:^(int code, NSString *desc) {
          [TUITool makeToastError:code msg:desc];
        }];
}
@end
