//
//  AppDelegate.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUITabBarController.h"
#import "LoginController.h"
#import "GenerateTestUserSig.h"
#import "TUILogin.h"
#import "TUIContactViewDataProvider.h"
#import "TCConstants.h"
#import "TUIStyleSelectViewController.h"

@class AppDelegate;
static AppDelegate *app = nil;

@interface AppDelegate : UIResponder <UIApplicationDelegate,TUIStyleSelectControllerDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) BOOL allowRotation;
@property (nonatomic, assign) NSUInteger unReadCount;
@property (nonatomic, strong, readonly) TUIContactViewDataProvider *contactDataProvider;
@property (nonatomic, assign) int lastLoginResultCode;

+ (id)sharedInstance;

- (UIViewController *)getLoginController;
- (UITabBarController *)getMainController;

- (void)applyPrivateBasicInfo;
- (void)preloadMainVCBeforeLogin:(NSString *)userID;
- (void)loginSDK:(NSString *)userID userSig:(NSString *)sig succ:(TSucc)succ fail:(TFail)fail;

@end

