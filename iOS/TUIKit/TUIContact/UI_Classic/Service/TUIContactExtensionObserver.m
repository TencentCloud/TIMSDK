//
//  TUIContactExtensionObserver.m
//  TUIContact
//
//  Created by harvy on 2023/3/29.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactExtensionObserver.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TUICore/TUICore.h>
#import "TUIGroupManageController.h"
#import "TUIGroupMemberController.h"
#import "TUIGroupMembersCell.h"
#import "TUISelectGroupMemberViewController.h"

@interface TUIContactExtensionObserver () <TUIExtensionProtocol,TUIGroupMembersCellDelegate>
//TUICore_TUIChatExtension_GroupProfileMemberListExtension_ClassicExtensionID
//pargm start
@property(nonatomic, assign) NSInteger tag;
@property(nonatomic,strong) UINavigationController *pushVC;
@property(nonatomic,copy) NSString *groupId;
@property(nonatomic, strong) UIViewController *showContactSelectVC;
@property(nonatomic, strong) NSMutableArray<TUIGroupMemberCellData *> *membersData;
@property(nonatomic, strong) TUIGroupMembersCellData *groupMembersCellData;
//pargm end

@end

@implementation TUIContactExtensionObserver

+ (void)load {
    [TUICore registerExtension:TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID object:TUIContactExtensionObserver.shareInstance];
    
    [TUICore registerExtension:TUICore_TUIChatExtension_GroupProfileMemberListExtension_ClassicExtensionID
                        object:TUIContactExtensionObserver.shareInstance];
    
    [TUICore registerExtension:TUICore_TUIChatExtension_GroupProfileSettingsItemExtension_ClassicExtensionID
                        object:TUIContactExtensionObserver.shareInstance];
    
    [TUICore registerExtension:TUICore_TUIChatExtension_GroupProfileBottomItemExtension_ClassicExtensionID
                        object:TUIContactExtensionObserver.shareInstance];
    
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - TUIExtensionProtocol


- (BOOL)onRaiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param {
    if ([extensionID isEqualToString:TUICore_TUIChatExtension_GroupProfileMemberListExtension_ClassicExtensionID]) {
        TUIGroupMembersCellData * data  = [param objectForKey:@"data"];
        self.groupId = [param objectForKey:@"groupID"];
        self.pushVC = [param tui_objectForKey:@"pushVC" asClass:UINavigationController.class];
        self.membersData = [param tui_objectForKey:@"membersData" asClass:NSMutableArray.class];
        self.groupMembersCellData = [param tui_objectForKey:@"groupMembersCellData" asClass:TUIGroupMembersCellData.class];
        if (![parentView isKindOfClass:UIView.class]) {
            return NO;
        }
        TUIGroupMembersCell *cell = [[TUIGroupMembersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [parentView addSubview:cell];
        parentView.userInteractionEnabled = YES;
        [cell mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(parentView);
        }];
        cell.backgroundColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF");
        [cell setData:data];
        cell.delegate = (id)self;
        return YES;
    }
    return NO;
    
}
- (NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(NSDictionary *)param {
    if (![extensionID isKindOfClass:NSString.class]) {
        return nil;
    }
    if ([extensionID isEqualToString:TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID]) {
        return [self getNavigationMoreItemExtensionForClassicChat:param];
    }
    else if ([extensionID
              isEqualToString:TUICore_TUIChatExtension_GroupProfileSettingsItemExtension_ClassicExtensionID]) {
        return [self getGroupProfileSettingsItemExtensionForClassicChat:param];
    }
    else if ([extensionID isEqualToString:TUICore_TUIChatExtension_GroupProfileBottomItemExtension_ClassicExtensionID]) {
        return [self getGroupProfileBottomItemExtensionForClassicChat:param];
    }
    else {
        return nil;
    }
}

- (NSArray<TUIExtensionInfo *> *)getNavigationMoreItemExtensionForClassicChat:(NSDictionary *)param {
    if (![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    NSString *userID = [param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_UserID asClass:NSString.class];
    if (userID.length > 0) {
        TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
        info.icon = TIMCommonBundleThemeImage(@"chat_nav_more_menu_img", @"chat_nav_more_menu");
        info.weight = 100;
        info.onClicked = ^(NSDictionary *_Nonnull param) {
            UINavigationController *pushVC = [param tui_objectForKey:TUICore_TUIChatExtension_NavigationMoreItem_PushVC asClass:UINavigationController.class];
            if (pushVC) {
                NSDictionary *param = @{TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey : userID ?: @"",
                                        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey : ^(UIViewController *vc){
                                            [pushVC pushViewController:vc animated:YES];
                                        }
                                        , TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey : ^(int code, NSString *desc) {
                                        }
                };
                [TUICore createObject:TUICore_TUIContactObjectFactory key:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod param:param];
            }
        };
        return @[ info ];
    }
    else {
        return nil;
    }
}

- (NSArray<TUIExtensionInfo *> *)getGroupProfileSettingsItemExtensionForClassicChat:(NSDictionary *)param {
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
                TUIGroupManageController *vc = [[TUIGroupManageController alloc] init];
                vc.groupID = groupID;
                [pushVC pushViewController:vc animated:YES];
            }
        };
        return @[ info ];
    }
    
    
    return nil;
}
- (NSArray<TUIExtensionInfo *> *)getGroupProfileBottomItemExtensionForClassicChat:(NSDictionary *)param {
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
            TUISelectGroupMemberViewController *vc = [[TUISelectGroupMemberViewController alloc] init];
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

#pragma TUIGroupMembersCellDelegate
- (void)groupMembersCell:(TUIGroupMembersCell *)cell didSelectItemAtIndex:(NSInteger)index {
    TUIGroupMemberCellData *mem = self.groupMembersCellData.members[index];
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

    self.tag = mem.tag;
    if (self.tag == 1) {
        // add
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_TitleKey] = TIMCommonLocalizableString(GroupAddFirend);
        param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisableIdsKey] = ids;
        param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisplayNamesKey] = displayNames;
        param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey] = selectContactCompletion;
        self.showContactSelectVC = [TUICore createObject:TUICore_TUIContactObjectFactory
                                                     key:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod
                                                   param:param];
        [self.pushVC pushViewController:self.showContactSelectVC animated:YES];
    } else if (self.tag == 2) {
        // delete
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_TitleKey] = TIMCommonLocalizableString(GroupDeleteFriend);
        param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_SourceIdsKey] = ids;
        param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisplayNamesKey] = displayNames;
        param[TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey] = selectContactCompletion;
        self.showContactSelectVC = [TUICore createObject:TUICore_TUIContactObjectFactory
                                                     key:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod
                                                   param:param];
        [self.pushVC pushViewController:self.showContactSelectVC animated:YES];
    } else {
        [self didCurrentMemberAtCellData:mem];
    }
}
- (void)didCurrentMemberAtCellData:(TUIGroupMemberCellData *)mem {
    NSString *userID = mem.identifier;
    @weakify(self);
    [self getUserOrFriendProfileVCWithUserID:userID
                                   succBlock:^(UIViewController *vc) {
                                     @strongify(self);
                                     [self.pushVC pushViewController:vc animated:YES];
                                   }
                                   failBlock:^(int code, NSString *desc){

                                   }];
}

- (void)getUserOrFriendProfileVCWithUserID:(NSString *)userID succBlock:(void (^)(UIViewController *vc))succ failBlock:(nullable V2TIMFail)fail {
    NSDictionary *param = @{
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey: userID ? : @"",
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey: succ ? : ^(UIViewController *vc){},
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey: fail ? : ^(int code, NSString * desc){}
    };
    [TUICore createObject:TUICore_TUIContactObjectFactory key:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod param:param];
}

- (void)addGroupId:(NSString *)groupId memebers:(NSArray *)members {
    @weakify(self);
    [[V2TIMManager sharedInstance] inviteUserToGroup:_groupId
        userList:members
        succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
          @strongify(self);
//          [self updateData];
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
//          [self updateData];
          [TUITool makeToast:TIMCommonLocalizableString(delete_success)];
        }
        fail:^(int code, NSString *desc) {
          [TUITool makeToastError:code msg:desc];
        }];
}
@end
