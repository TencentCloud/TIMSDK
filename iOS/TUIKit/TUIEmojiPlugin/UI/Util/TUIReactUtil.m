//
//  TUIReactUtil.m
//  Masonry
//
//  Created by cologne on 2023/12/26.
//

#import "TUIReactUtil.h"
#import <TUICore/TUITool.h>
#import <TUICore/TUICommonModel.h>
#import <TUICore/TUIGlobalization.h>

static BOOL gEnableReact = NO;

@implementation TUIReactUtil

+ (TUIReactUtil *)sharedInstance {
    static dispatch_once_t onceToken;
    static TUIReactUtil * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIReactUtil alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - report
+ (void)reportTUIReactComponentUsage {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"UIComponentType"] = @(18);
    param[@"UIStyleType"] = @(0);
    NSData *dataParam = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strParam = [[NSString alloc] initWithData:dataParam encoding:NSUTF8StringEncoding];
    [[V2TIMManager sharedInstance] callExperimentalAPI:@"reportTUIComponentUsage"
                                                 param:strParam
                                                  succ:^(NSObject *result) {
        NSLog(@"success");
    }
                                                  fail:^(int code, NSString *desc){
    }];
}

+ (void)checkCommercialAbility {
    [TUITool checkCommercialAbility:TUIReactCommercialAbility succ:^(BOOL enabled) {
        gEnableReact = enabled;
        if (gEnableReact) {
            [self.class reportTUIReactComponentUsage];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:@"TUIReactionCommercialAbility"];
            [userDefaults synchronize];
        }
    } fail:^(int code, NSString *desc) {
        gEnableReact = NO;
    }];
    
}

+ (BOOL)isReactServiceSupported {
    return gEnableReact;
}

@end
