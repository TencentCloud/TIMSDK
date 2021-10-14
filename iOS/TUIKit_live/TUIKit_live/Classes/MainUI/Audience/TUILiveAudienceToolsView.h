//
//  TUILiveAudienceToolsView.h
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUILiveOnKeyboardInputView.h"
#import "TUILiveTopToolBar.h"
#import "TUILiveBottomToolBar.h"

NS_ASSUME_NONNULL_BEGIN

@class TUILiveUserProfile;
@class TUILiveIMUserAble;
@class TUILiveAudienceToolsView;
typedef void(^TUILiveAudienceToolsViewBlock)(TUILiveAudienceToolsView *view, id __nullable info);

@class TRTCLiveRoom;
@class TUILiveRoomAudienceViewController;
@interface TUILiveAudienceToolsView : UIView
@property(nonatomic, weak) TRTCLiveRoom *liveRoom;
@property(nonatomic, weak) TUILiveRoomAudienceViewController *controller;
@property(nonatomic, strong) TUILiveOnKeyboardInputView *inputView;
@property(nonatomic, strong) TUILiveBottomToolBar *bottomToolBar;
@property(nonatomic, strong) TUILiveTopToolBar *topToolBar;
@property(nonatomic, assign) BOOL isCdnPK;                        /// pk图片顶部偏移量
@property(nonatomic, strong) TUILiveAudienceToolsViewBlock onLinkMic;         /// 连麦
@property(nonatomic, strong) TUILiveAudienceToolsViewBlock onGiftClick;       /// 送礼按钮被点击，打开送礼面板
@property(nonatomic, strong) TUILiveAudienceToolsViewBlock onReceiveGiftMsg;  /// 接收到礼物消息
@property(nonatomic, strong) TUILiveAudienceToolsViewBlock onUserReport;      /// 举报

/// 更新pk图标
- (void)changePKState:(BOOL)isPK;
/// 底部栏摄像头切换按钮，连麦用
- (void)setSwitchCameraButtonHidden:(BOOL)hidden;
/// 底部栏连麦按钮
- (UIButton *)bottomLinkMicBtn;
/// 接受消息
- (void)handleIMMessage:(TUILiveIMUserAble*)info msgText:(NSString*)msgText;
/// 更新成员列表
- (void)updateAudienceList:(NSArray *)audienceList;

@end

NS_ASSUME_NONNULL_END
