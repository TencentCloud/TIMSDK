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




#define sdkBusiId         12742
#define BUGLY_APP_ID      @"e965e5d928"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSData *deviceToken;
@property (nonatomic, assign) NSInteger  sdkAppid;
@property (nonatomic, strong) NSString * identifier1;
@property (nonatomic, strong) NSString * userSig1;
@property (nonatomic, strong) NSString * identifier2;
@property (nonatomic, strong) NSString * userSig2;
@property (nonatomic, strong) NSString * identifier3;
@property (nonatomic, strong) NSString * userSig3;
@property (nonatomic, strong) NSString * identifier4;
@property (nonatomic, strong) NSString * userSig4;
- (UIViewController *)getLoginController;
- (UITabBarController *)getMainController;
@end

