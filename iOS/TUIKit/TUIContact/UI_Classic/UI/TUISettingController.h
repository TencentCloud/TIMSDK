//
//  TUISettingController.h
//  TUIKitDemo
//
//  Created by lynxzhang on 2018/10/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 设置主界面视图
 *  - 本文件实现了设置视图控制器，即TabBar内 "我" 按钮对应的视图
 *  - 您可以在此处查看、并修改您的个人信息，或是执行退出登录等操作
 *  - 本类依赖于腾讯云 TUIKit和IMSDK
 *
 *  Tencent Cloud IM Demo settings main interface view
 *  - This file implements the setting interface, that is, the view corresponding to the "Me" button in the TabBar.
 *  - Here you can view and modify your personal information, or perform operations such as logging out.
 *  - This class depends on Tencent Cloud TUIKit and IMSDK
 */
#import <UIKit/UIKit.h>
#import "TUICommonModel.h"

#define SHEET_COMMON 1
#define SHEET_AGREE  2
#define SHEET_SEX    3
#define SHEET_V2API  4

@protocol TUISettingControllerDelegate <NSObject>
@optional
- (void)onSwitchMsgReadStatus:(BOOL)isOn;
- (void)onSwitchOnlineStatus:(BOOL)isOn;
- (void)onClickAbout;
- (void)onClickLogout;
@end

@interface TUISettingController : UITableViewController
@property(nonatomic, weak) id<TUISettingControllerDelegate> delegate;

@property(nonatomic, assign) BOOL showMessageReadStatusCell;
@property(nonatomic, assign) BOOL showDisplayOnlineStatusCell;
@property(nonatomic, assign) BOOL showLoginOutCell;
@property(nonatomic, assign) BOOL msgNeedReadReceipt;
@property(nonatomic, strong) NSString *aboutCellText;
@end
