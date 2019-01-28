//
//  AppDelegate.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTabBarController.h"
#import "LoginController.h"

#define Key_UserInfo_User @"Key_UserInfo_User"
#define Key_UserInfo_Pwd @"Key_UserInfo_Pwd"
#define Key_UserInfo_Sig @"Key_UserInfo_Sig"

#define sdkAppid          123456789
#define sdkAccountType    @"36862"

#define identifier1 @"user1"
#define userSig1    @""

#define identifier2 @"user2"
#define userSig2    @""

#define identifier3 @"user3"
#define userSig3    @""

#define identifier4 @"user4"
#define userSig4    @""

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
- (UIViewController *)getLoginController;
- (UITabBarController *)getMainController;
@end

