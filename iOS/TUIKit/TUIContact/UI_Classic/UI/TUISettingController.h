//
//  TUISettingController.h
//  TUIKitDemo
//
//  Created by lynxzhang on 2018/10/19.
//  Copyright © 2018 Tencent. All rights reserved.
//
/** IM Demo 

 *  Tencent Cloud Chat Demo settings main interface view
 *  - This file implements the setting interface, that is, the view corresponding to the "Me" button in the TabBar.
 *  - Here you can view and modify your personal information, or perform operations such as logging out.
 *  - This class depends on Tencent Cloud TUIKit and IMSDK
 */
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>

#define SHEET_COMMON 1
#define SHEET_AGREE 2
#define SHEET_SEX 3
#define SHEET_V2API 4

@protocol TUISettingControllerDelegate <NSObject>
@optional
- (void)onSwitchMsgReadStatus:(BOOL)isOn;
- (void)onSwitchOnlineStatus:(BOOL)isOn;
- (void)onSwitchCallsRecord:(BOOL)isOn;
- (void)onClickAboutIM;
- (void)onClickLogout;
- (void)onChangeStyle;
- (void)onChangeTheme;
@end

@interface TUISettingController : UITableViewController
@property(nonatomic, strong) NSString *lastLoginUser;
@property(nonatomic, weak) id<TUISettingControllerDelegate> delegate;

@property(nonatomic, assign) BOOL showPersonalCell;
@property(nonatomic, assign) BOOL showMessageReadStatusCell;
@property(nonatomic, assign) BOOL showDisplayOnlineStatusCell;
@property(nonatomic, assign) BOOL showSelectStyleCell;
@property(nonatomic, assign) BOOL showChangeThemeCell;
@property(nonatomic, assign) BOOL showCallsRecordCell;
@property(nonatomic, assign) BOOL showAboutIMCell;
@property(nonatomic, assign) BOOL showLoginOutCell;

@property(nonatomic, assign) BOOL msgNeedReadReceipt;
@property(nonatomic, assign) BOOL displayCallsRecord;

@property(nonatomic, strong) NSString *aboutIMCellText;
@end
