//
//  SettingController.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 设置主界面视图
 *  - 本文件实现了设置视图控制器，即TabBar内 "我" 按钮对应的视图
 *  - 您可以在此处查看、并修改您的个人信息，或是执行退出登录等操作
 *  - 本类依赖于腾讯云 TUIKit和IMSDK
 *
 *  Tencent Cloud Chat Demo settings main interface view
 *  - This file implements the setting interface, that is, the view corresponding to the "Me" button in the TabBar.
 *  - Here you can view and modify your personal information, or perform operations such as logging out.
 *  - This class depends on Tencent Cloud TUIKit and IMSDK
 */
#import <UIKit/UIKit.h>

@class TUISettingController_Minimalist;

extern NSString *kEnableMsgReadStatus_mini;
extern NSString *kEnableOnlineStatus_mini;
extern NSString *kEnableCallsRecord_mini;

@interface SettingController_Minimalist : UIViewController
@property(nonatomic, strong) TUISettingController_Minimalist *setting;
@property(nonatomic, strong) NSMutableArray<UIBarButtonItem *> *showLeftBarButtonItems;
@property(nonatomic, copy) void (^changeStyle)(void);
@property(nonatomic, copy) void (^changeTheme)(void);
@property(nonatomic, copy) void (^confirmLogout)(void);
@property(nonatomic, copy) void (^viewWillAppear)(BOOL isAppear);
@property(nonatomic, assign) BOOL showPersonalCell;
@property(nonatomic, assign) BOOL showSelectStyleCell;
@property(nonatomic, assign) BOOL showChangeThemeCell;
@property(nonatomic, assign) BOOL showAboutIMCell;
@property(nonatomic, assign) BOOL showLoginOutCell;
@property(nonatomic, assign) BOOL showCallsRecordCell;
@end
