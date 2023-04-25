//
//  TUIConversationObjectFactory_Minimalist.m
//  TUIConversation
//
//  Created by wyl on 2023/3/29.
//

#import "TUIConversationObjectFactory_Minimalist.h"
#import "TUIConversationListController_Minimalist.h"
#import "TUIConversationSelectController_Minimalist.h"
#import <TUICore/TUIThemeManager.h>

@interface TUIConversationObjectFactory_Minimalist() <TUIObjectProtocol>
@end

@implementation TUIConversationObjectFactory_Minimalist
+ (void)load {
    [TUICore registerObjectFactoryName:TUICore_TUIConversationObjectFactory_Minimalist objectFactory:[TUIConversationObjectFactory_Minimalist shareInstance]];
}
+ (TUIConversationObjectFactory_Minimalist *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIConversationObjectFactory_Minimalist * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIConversationObjectFactory_Minimalist alloc] init];
    });
    return g_sharedInstance;
}

#pragma mark - TUIObjectProtocol
- (id)onCreateObject:(NSString *)method param:(nullable NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIConversationObjectFactory_GetConversationControllerMethod]) {
        return [self createConversationController];
    } else if ([method isEqualToString:TUICore_TUIConversationObjectFactory_GetConversationSelectControllerMethod]) {
        return [self createConversationSelectController];
    }
    return nil;
}

- (UIViewController *)createConversationController {
    return [[TUIConversationListController_Minimalist alloc] init];
}

- (UIViewController *)createConversationSelectController {
    return [[TUIConversationSelectController_Minimalist alloc] init];
}

@end
