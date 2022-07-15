
#import "TUIGroupService.h"
#import "TUIDefine.h"
#import "NSDictionary+TUISafe.h"
#import "TUIThemeManager.h"
#import "TUIGlobalization.h"

@implementation TUIGroupService

+ (void)load {
    [TUICore registerService:TUICore_TUIGroupService object:[TUIGroupService shareInstance]];
    TUIRegisterThemeResourcePath(TUIGroupThemePath, TUIThemeModuleGroup);
}

+ (TUIGroupService *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIGroupService * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIGroupService alloc] init];
    });
    return g_sharedInstance;
}

- (TUIGroupInfoController *)createGroupInfoController:(NSString *)groupID
{
    TUIGroupInfoController *vc = [[TUIGroupInfoController alloc] init];
    vc.groupId = groupID;
    return vc;
}

- (TUISelectGroupMemberViewController *)createSelectGroupMemberViewController:(NSString *)groupID name:(NSString *)name optionalStyle:(TUISelectMemberOptionalStyle)optionalStyle {
    TUISelectGroupMemberViewController *vc = [[TUISelectGroupMemberViewController alloc] init];
    vc.groupId = groupID;
    vc.name = name;
    vc.optionalStyle = optionalStyle;
    return vc;
}

- (void)createGroup:(NSString *)groupType
       createOption:(V2TIMGroupAddOpt)createOption
           contacts:(NSArray<TUICommonContactSelectCellData *> *)contacts
         completion:(void (^)(BOOL success, NSString *groupID, NSString *groupName))completion {
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance] getUsersInfo:@[loginUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        NSString *showName = loginUser;
        if (infoList.firstObject.nickName.length > 0) {
            showName = infoList.firstObject.nickName;
        }
        NSMutableString *groupName = [NSMutableString stringWithString:showName];
        NSMutableArray *members = [NSMutableArray array];
        //遍历contacts，初始化群组成员信息、群组名称信息
        for (TUICommonContactSelectCellData *item in contacts) {
            V2TIMCreateGroupMemberInfo *member = [[V2TIMCreateGroupMemberInfo alloc] init];
            member.userID = item.identifier;
            member.role = V2TIM_GROUP_MEMBER_ROLE_MEMBER;
            [groupName appendFormat:@"、%@", item.title];
            [members addObject:member];
        }

        //群组名称默认长度不超过10，如有需求可在此更改，但可能会出现UI上的显示bug
        if ([groupName length] > 10) {
            groupName = [groupName substringToIndex:10].mutableCopy;
        }

        V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
        info.groupName = groupName;
        info.groupType = groupType;
        if(![info.groupType isEqualToString:GroupType_Work]){
            info.groupAddOpt = createOption;
        }

        //发送创建请求后的回调函数
        [[V2TIMManager sharedInstance] createGroup:info memberList:members succ:^(NSString *groupID) {
            //创建成功后，在群内推送创建成功的信息
            NSString *content = nil;
            if([info.groupType isEqualToString:GroupType_Work]) {
                content = TUIKitLocalizableString(ChatsCreatePrivateGroupTips); // @"创建讨论组";
            } else if([info.groupType isEqualToString:GroupType_Public]){
                content = TUIKitLocalizableString(ChatsCreateGroupTips); // @"创建群聊";
            } else if([info.groupType isEqualToString:GroupType_Meeting]) {
                content = TUIKitLocalizableString(ChatsCreateChatRoomTips); // @"创建聊天室";
            } else if([info.groupType isEqualToString:GroupType_Community]) {
                content = TUIKitLocalizableString(ChatsCreateCommunityTips); // @"创建社区";
            } else {
                content = TUIKitLocalizableString(ChatsCreateDefaultTips); // @"创建群组";
            }
            NSDictionary *dic = @{@"version": @(GroupCreate_Version),
                                  BussinessID: BussinessID_GroupCreate,
                                  @"opUser": showName,
                                  @"content": content
            };
            NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:data];
            [[V2TIMManager sharedInstance] sendMessage:msg receiver:nil groupID:groupID priority:V2TIM_PRIORITY_DEFAULT onlineUserOnly:NO offlinePushInfo:nil progress:nil succ:nil fail:nil];
            // wait for a second to ensure the group created message arrives first
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(YES, groupID, groupName);
                }
            });
        } fail:^(int code, NSString *msg) {
            if (completion) {
                completion(NO, nil, nil);
            }
            if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
                [TUITool postUnsupportNotificationOfService:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceCommunity) serviceDesc:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceCommunityDesc) debugOnly:YES];
            }
        }];
    } fail:^(int code, NSString *msg) {
        if (completion) {
            completion(NO, nil, nil);
        }
    }];
}

#pragma mark - TUIServiceProtocol
- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIGroupService_GetGroupInfoControllerMethod]) {
        return [self createGroupInfoController:[param tui_objectForKey:TUICore_TUIGroupService_GetGroupInfoControllerMethod_GroupIDKey asClass:NSString.class]];
    }
    else if ([method isEqualToString:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod]) {
        NSNumber *optionalStyleNum = [param tui_objectForKey:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_OptionalStyleKey asClass:NSNumber.class];
        return [self createSelectGroupMemberViewController:[param tui_objectForKey:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_GroupIDKey asClass:NSString.class] name:[param tui_objectForKey:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_NameKey asClass:NSString.class] optionalStyle:optionalStyleNum.integerValue];
    } else if ([method isEqualToString:TUICore_TUIGroupService_CreateGroupMethod]) {
        NSString *groupType = [param tui_objectForKey:TUICore_TUIGroupService_CreateGroupMethod_GroupTypeKey asClass:NSString.class];
        NSNumber *option = [param tui_objectForKey:TUICore_TUIGroupService_CreateGroupMethod_OptionKey asClass:NSNumber.class];
        NSArray *contacts = [param tui_objectForKey:TUICore_TUIGroupService_CreateGroupMethod_ContactsKey asClass:NSArray.class];
        void (^completion)(BOOL, NSString *, NSString *) = [param objectForKey:TUICore_TUIGroupService_CreateGroupMethod_CompletionKey];
        
        [self createGroup:groupType
             createOption:[option intValue]
                 contacts:contacts
               completion:completion];
    }
    return nil;
}
@end
