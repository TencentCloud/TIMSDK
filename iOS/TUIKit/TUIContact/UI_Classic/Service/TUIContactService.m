//
//  TUIContactService.m
//  lottie-ios
//
//  Created by kayev on 2021/8/18.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactService.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIGroupRequestViewController.h"
#import "TUISelectGroupMemberViewController.h"
@implementation TUIContactService

+ (void)load {
    TUIRegisterThemeResourcePath(TUIContactThemePath, TUIThemeModuleContact);
    [TUICore registerService:TUICore_TUIContactService object:[TUIContactService shareInstance]];
}

+ (TUIContactService *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIContactService *g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
      g_sharedInstance = [[TUIContactService alloc] init];
    });
    return g_sharedInstance;
}
- (void)createGroup:(NSString *)groupType
       createOption:(V2TIMGroupAddOpt)createOption
           contacts:(NSArray<TUICommonContactSelectCellData *> *)contacts
         completion:(void (^)(BOOL success, NSString *groupID, NSString *groupName))completion {
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance] getUsersInfo:@[ loginUser ]
        succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
          NSString *showName = loginUser;
          if (infoList.firstObject.nickName.length > 0) {
              showName = infoList.firstObject.nickName;
          }
          NSMutableString *groupName = [NSMutableString stringWithString:showName];
          NSMutableArray *members = [NSMutableArray array];
          for (TUICommonContactSelectCellData *item in contacts) {
              V2TIMCreateGroupMemberInfo *member = [[V2TIMCreateGroupMemberInfo alloc] init];
              member.userID = item.identifier;
              member.role = V2TIM_GROUP_MEMBER_ROLE_MEMBER;
              [groupName appendFormat:@"、%@", item.title];
              [members addObject:member];
          }

          if ([groupName length] > 10) {
              groupName = [groupName substringToIndex:10].mutableCopy;
          }

          V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
          info.groupName = groupName;
          info.groupType = groupType;
          if (![info.groupType isEqualToString:GroupType_Work]) {
              info.groupAddOpt = createOption;
          }

          [[V2TIMManager sharedInstance] createGroup:info
              memberList:members
              succ:^(NSString *groupID) {
                NSString *content = TIMCommonLocalizableString(TUIGroupCreateTipsMessage);
                if ([info.groupType isEqualToString:GroupType_Community]) {
                    content = TIMCommonLocalizableString(TUICommunityCreateTipsMessage);
                }
                NSDictionary *dic = @{
                    @"version" : @(GroupCreate_Version),
                    BussinessID : BussinessID_GroupCreate,
                    @"opUser" : showName,
                    @"content" : content,
                    @"cmd" : [info.groupType isEqualToString:GroupType_Community] ? @1 : @0
                };
                NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:data];
                [[V2TIMManager sharedInstance] sendMessage:msg
                                                  receiver:nil
                                                   groupID:groupID
                                                  priority:V2TIM_PRIORITY_DEFAULT
                                            onlineUserOnly:NO
                                           offlinePushInfo:nil
                                                  progress:nil
                                                      succ:nil
                                                      fail:nil];
                // wait for a second to ensure the group created message arrives first
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                  if (completion) {
                      completion(YES, groupID, groupName);
                  }
                });
              }
              fail:^(int code, NSString *msg) {
                if (completion) {
                    completion(NO, nil, nil);
                }
                if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
                    [TUITool postUnsupportNotificationOfService:TIMCommonLocalizableString(TUIKitErrorUnsupportIntefaceCommunity)
                                                    serviceDesc:TIMCommonLocalizableString(TUIKitErrorUnsupportIntefaceCommunityDesc)
                                                      debugOnly:YES];
                }
              }];
        }
        fail:^(int code, NSString *msg) {
          if (completion) {
              completion(NO, nil, nil);
          }
        }];
}

#pragma mark - TUIServiceProtocol
- (id)onCall:(NSString *)method param:(NSDictionary *)param {
    id returnObject = nil;
    if ([method isEqualToString:TUICore_TUIContactService_CreateGroupMethod]) {
        NSString *groupType = [param tui_objectForKey:TUICore_TUIContactService_CreateGroupMethod_GroupTypeKey asClass:NSString.class];
        NSNumber *option = [param tui_objectForKey:TUICore_TUIContactService_CreateGroupMethod_OptionKey asClass:NSNumber.class];
        NSArray *contacts = [param tui_objectForKey:TUICore_TUIContactService_CreateGroupMethod_ContactsKey asClass:NSArray.class];
        void (^completion)(BOOL, NSString *, NSString *) = [param objectForKey:TUICore_TUIContactService_CreateGroupMethod_CompletionKey];

        [self createGroup:groupType createOption:[option intValue] contacts:contacts completion:completion];
    }
    return returnObject;
}
@end
