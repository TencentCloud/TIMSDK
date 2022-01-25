
#import "TUIGroupService.h"
#import "TUIDefine.h"
#import "NSDictionary+TUISafe.h"
#import "TUIThemeManager.h"

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

- (TUISelectGroupMemberViewController *)createSelectGroupMemberViewController:(NSString *)groupID name:(NSString *)name optionalStyle:(TUISelectMemberOptionalStyle)optionalStyle {
    TUISelectGroupMemberViewController *vc = [[TUISelectGroupMemberViewController alloc] init];
    vc.groupId = groupID;
    vc.name = name;
    vc.optionalStyle = optionalStyle;
    return vc;
}

#pragma mark - TUIServiceProtocol
- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod]) {
        NSNumber *optionalStyleNum = [param tui_objectForKey:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_OptionalStyleKey asClass:NSNumber.class];
        return [self createSelectGroupMemberViewController:[param tui_objectForKey:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_GroupIDKey asClass:NSString.class] name:[param tui_objectForKey:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_NameKey asClass:NSString.class] optionalStyle:optionalStyleNum.integerValue];
    }
    return nil;
}
@end
