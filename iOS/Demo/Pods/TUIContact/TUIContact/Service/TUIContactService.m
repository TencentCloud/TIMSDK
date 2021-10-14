//
//  TUIContactService.m
//  lottie-ios
//
//  Created by kayev on 2021/8/18.
//

#import "TUIContactService.h"

@implementation TUIContactService

+ (void)load {
    [TUICore registerService:TUICore_TUIContactService object:[TUIContactService shareInstance]];
}

+ (TUIContactService *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIContactService * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIContactService alloc] init];
    });
    return g_sharedInstance;
}

#pragma mark -
- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIContactService_GetContactControllerMethod]) {
        return [self createContactController];
    } else if ([method isEqualToString:TUICore_TUIContactService_GetContactSelectControllerMethod]) {
        return [self createContactSelectController];
    }
    return nil;
}

- (TUIContactController *)createContactController {
    return [[TUIContactController alloc] init];
}

- (TUIContactSelectController *)createContactSelectController {
    return [[TUIContactSelectController alloc] init];
}
@end
