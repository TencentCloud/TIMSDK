//
//  TUILiveFloatWindow.h
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/10/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUILiveAudienceVideoRenderView;

typedef void(^TUILiveFloatWindowEventHandler)(void);

@interface TUILiveFloatWindow : UIWindow

@property(nonatomic, copy) TUILiveFloatWindowEventHandler backHandler;
@property(nonatomic, copy) TUILiveFloatWindowEventHandler closeHandler; // 默认关闭
/// 小窗播放渲染视图，弱引用，避免无法释放
@property(nonatomic, weak) TUILiveAudienceVideoRenderView *renderView;
/// 小窗视图主view
@property(nonatomic, readonly)UIView *rootView;
/// 点击返回的控制器
@property(nonatomic, strong, nullable)UIViewController *backController;
/// 是否正在显示
@property(nonatomic, readonly)BOOL isShowing;
/// 视图缩放比例
@property(nonatomic, readonly)CGFloat floatWindowScaling;

// 请使用 +sharedIntance 方法
+ (instancetype)new  __attribute__((unavailable("Use +sharedInstance instead")));
- (instancetype)init __attribute__((unavailable("Use +sharedInstance instead")));

+ (instancetype)sharedInstance;

/// 显示小窗
- (void)show;
/// 隐藏小窗
- (void)hide;

/// 切换到PK视图模式
/// @param isPKStatus 是否为PK视图模式
- (void)switchPKStatus:(BOOL)isPKStatus;

/// 切换到主播不在线模式
/// @param isNoAnchor 是否为主播不在线模式
- (void)switchNoAnchorStatus:(BOOL)isNoAnchor;

@end

NS_ASSUME_NONNULL_END
