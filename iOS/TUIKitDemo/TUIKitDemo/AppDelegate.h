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

#define Key_UserInfo_Appid @"Key_UserInfo_Appid"
#define Key_UserInfo_User  @"Key_UserInfo_User"
#define Key_UserInfo_Pwd   @"Key_UserInfo_Pwd"
#define Key_UserInfo_Sig   @"Key_UserInfo_Sig"

#define sdkAppid          1400124969
#define sdkAccountType    @"36862"
#define BUGLY_APP_ID      @"e965e5d928"

#define sdkBusiId   12742

#define identifier1 @"fjsand"
#define userSig1    @"eJx1kE9PgzAYh*98CsJ1xrSFyuoNGZoNdW6oAS6kru3ozDr*VDY0fvdNZmIvvvndnid5kvfLsm3beb5PLulqtftQutB9xR372nZcD6Gxc-EnVJVkBdWF27BBgB4AEHnkihgWP1Sy4QUVmjdny0djAAxDMq60FPKXi01LFTN4y96LofV-pJXrAT5EWThdTPJsqdtyEo72GLsl3McHEqooFIQoFsRzLpYZ7WjwmaaLaRk8brsoqUf1UwJncP5yF8SxiPLXvFv32axPpZ-Ut5sSv93IwEhquT2-BWJMAPJPM2jHm1bu1CAgADFELvg5x-q2jtOXX*E_"

#define identifier2 @"user2"
#define userSig2    @""

#define identifier3 @"user3"
#define userSig3    @""

#define identifier4 @"user4"
#define userSig4    @""

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSData *deviceToken;
- (UIViewController *)getLoginController;
- (UITabBarController *)getMainController;
@end

