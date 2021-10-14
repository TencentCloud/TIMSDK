//
//  AppDelegate.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUITabBarController.h"
#import "LoginController.h"
#import "TUIKit.h"
#import "GenerateTestUserSig.h"
#import "TUILogin.h"
//sdkappid 请查看 GenerateTestUserSig.h

//apns
#ifdef DEBUG
#define sdkBusiId 15108
#else
#define sdkBusiId 16205
#endif

//bugly
#define BUGLY_APP_ID @"0a3cbc2dfe"

#define installApp     @"_installApp_"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (id)sharedInstance;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSData *deviceToken;

- (UIViewController *)getLoginController;
- (UITabBarController *)getMainController;

- (void)login:(NSString *)identifier userSig:(NSString *)sig succ:(TSucc)succ fail:(TFail)fail;
@end

