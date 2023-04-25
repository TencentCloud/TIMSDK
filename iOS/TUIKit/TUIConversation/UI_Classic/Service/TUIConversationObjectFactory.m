//
//  TUIConversationObjectFactory.m
//  TUIConversation
//
//  Created by wyl on 2023/3/29.
//

#import "TUIConversationObjectFactory.h"
#import "TUIConversationListController.h"
#import "TUIConversationSelectController.h"
#import <TUICore/TUIThemeManager.h>

@interface TUIConversationObjectFactory() <TUIObjectProtocol>
@end

@implementation TUIConversationObjectFactory
+ (void)load {
    [TUICore registerObjectFactoryName:TUICore_TUIConversationObjectFactory objectFactory:[TUIConversationObjectFactory shareInstance]];
}
+ (TUIConversationObjectFactory *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIConversationObjectFactory * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIConversationObjectFactory alloc] init];
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
    return [[TUIConversationListController alloc] init];
}

- (UIViewController *)createConversationSelectController {
    return [[TUIConversationSelectController alloc] init];
}

@end
