//
//  UIWindow+TUICalling.m
//  TUICalling
//
//  Created by noah on 2022/1/17.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "UIWindow+TUICalling.h"

@implementation UIWindow (TUICalling)

- (void)t_makeKeyAndVisible {
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive
                || windowScene.activationState == UISceneActivationStateBackground) {
                self.windowScene = windowScene;
                break;
            }
        }
    }
    [self makeKeyAndVisible];
}

@end
