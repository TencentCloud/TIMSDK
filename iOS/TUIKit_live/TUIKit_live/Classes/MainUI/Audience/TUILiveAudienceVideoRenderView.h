//
//  TUILiveAudienceVideoRenderView.h
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/10/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CloseEnumerateAction)(NSString *userID);

@class TUILiveStatusInfoView;
@interface TUILiveAudienceVideoRenderView : UIView

/// 设置渲染视图的父视图。观看过程中设置可以实现窗口转移
@property(nonatomic, weak, nullable)UIView *fatherView;

@property(nonatomic, strong, readonly)UIView *videoRenderView;

/// 通过UserID查找已被使用的小窗视图
/// @param userID 查找的UserID
- (TUILiveStatusInfoView * _Nullable)getStatusInfoViewByUserID:(NSString *)userID;

/// 获取当前空闲的视图
- (TUILiveStatusInfoView * _Nullable)getFreeStatusInfoView;

/// 切换PK状态和非PK状态下的主视图布局
- (void)switchPKStatus:(BOOL)isPKStatus useCDN:(BOOL)useCDN;
/// 将小窗状态刷新为PK状态的UI位置
- (void)switchStatusViewPKModel;
/// 将小窗状态刷新为连麦状态的UI位置
- (void)switchStatusViewJoinAnchorModel;
/// 重置连麦小窗视图位置（主要目的恢复PK时的改变）
- (void)linkFrameRestore;

/// 关闭并重置小窗，非异步block
- (void)stopAndResetAllStatusView:(CloseEnumerateAction)action;

- (BOOL)isNoAnchorInStatusInfoView;

@end

NS_ASSUME_NONNULL_END
