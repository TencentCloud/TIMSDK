//
//  AppDelegate.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Key_UserInfo_Appid @"Key_UserInfo_Appid"
#define Key_UserInfo_User  @"Key_UserInfo_User"
#define Key_UserInfo_Pwd   @"Key_UserInfo_Pwd"
#define Key_UserInfo_Sig   @"Key_UserInfo_Sig"

//快速跑通 demo 请参考官网文档：https://cloud.tencent.com/document/product/269/32674
#define sdkAppid    123456789  //替换成您在控制台生成的 sdkAppid

#define identifier1 @"user1"
#define userSig1    @""

#define identifier2 @"user2"
#define userSig2    @""

#define identifier3 @"user3"
#define userSig3    @""

#define identifier4 @"user4"
#define userSig4    @""

#define sdkBusiId         12742
#define BUGLY_APP_ID      @"e965e5d928"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSData *deviceToken;
- (UIViewController *)getLoginController;
- (UITabBarController *)getMainController;
@end

