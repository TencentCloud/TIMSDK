//
//  TUILiveAnchorToolView.h
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/9/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TUILiveAnchorToolViewAction) {
    TUILiveAnchorToolViewActionShowPKList= 0,
    TUILiveAnchorToolViewActionShowAudioPanel,
    TUILiveAnchorToolViewActionShowBeauty,
    TUILiveAnchorToolViewActionSwitchCamera,
    TUILiveAnchorToolViewActionCloseAction,
    TUILiveAnchorToolViewActionStopPK,
    TUILiveAnchorToolViewActionShowJoinAnchorList
};
@class TUILiveIMUserAble;
@class TUILiveTopToolBar;
@class TRTCLiveRoomInfo;
@class TUILiveAnchorToolView;
@class TUILiveMsgModel;
@class TRTCLiveUserInfo;
@protocol TUILiveAnchorToolViewDelegate <NSObject>

- (void)closeAction;
- (void)anchorToolView:(TUILiveAnchorToolView *)view clickAction:(TUILiveAnchorToolViewAction)action;
- (void)startPKWithRoom:(TRTCLiveRoomInfo *)roomInfo;
- (void)sendTextMsg:(NSString *)msg isDamma:(BOOL)isDama;
- (void)anchorToolViewOnTapCancelAction:(TUILiveAnchorToolView *)view;
- (void)onReceiveGiftMsg:(TUILiveMsgModel *)gift;
- (void)onRespondJoinAnchor:(TRTCLiveUserInfo *)user agree:(BOOL)agree;

@end

@interface TUILiveAnchorToolView : UIView

@property(nonatomic, assign)BOOL isLinkMic; // 是否正在连麦（包括连麦发起中 + 正在连麦）

@property(nonatomic, readonly)BOOL isPKRoomListShow;

@property(nonatomic, weak)id<TUILiveAnchorToolViewDelegate> delegate;

// 需要插入的视图，在外部设置好frame或者约束，这里只做addSubView操作
@property(nonatomic, strong)NSArray<UIView *> *insertControlViews;

/// 更改视图控制状态为PK状态
/// @param isPK 是否为PK状态
- (void)changePKState:(BOOL)isPK;

/// 展示房间列表
/// @param list 房间信息列表
- (void)showRoomList:(NSArray<TRTCLiveRoomInfo *> *)list;
// 隐藏房间列表
- (void)hideRoomList;

/// 添加连麦用户信息
/// @param list joinAnchor
- (void)updateJoinAnchorList:(NSArray<TRTCLiveUserInfo *> *)list needShow:(BOOL)needShow;


- (void)stopLive;

- (void)handleIMMessage:(TUILiveIMUserAble*)info msgText:(NSString*)msgText;

- (void)switchBeautyStatus:(BOOL)isBeauty; // 切换到美颜面板显示状态
- (void)switchAudioSettingStatus:(BOOL)isAudioPanelShow; // 切换到音效面板显示状态

- (void)enablePK:(BOOL)enable; // 移除视图PK控制按钮

@end

NS_ASSUME_NONNULL_END
