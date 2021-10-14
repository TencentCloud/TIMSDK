//
//  TUILiveAudienceVideoRenderView.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/10/23.
//

#import "TUILiveAudienceVideoRenderView.h"
#import "TUILiveStatusInfoView.h"
#import "TUILiveFloatWindow.h"
#import "Masonry.h"

#define VIDEO_VIEW_WIDTH            100
#define VIDEO_VIEW_HEIGHT           150
#define VIDEO_VIEW_MARGIN_BOTTOM    56
#define VIDEO_VIEW_MARGIN_RIGHT     8
#define VIDEO_VIEW_MARGIN_SPACE     5

#define FULL_SCREEN_PLAY_VIDEO_VIEW     10000

@interface TUILiveAudienceVideoRenderView ()

@property(nonatomic, strong, readwrite)UIView *videoRenderView;
@property(nonatomic, strong) NSMutableArray<TUILiveStatusInfoView *> *statusInfoViewArray;

/// 是否为PK状态
@property(nonatomic, assign) BOOL isPKStatus;
/// 悬浮窗缩放比例
/// - describe
/// 用来控制连麦视图在悬浮小窗的宽高缩放比例。默认值 1.0
@property(nonatomic, assign, readonly)CGFloat floatViewScaling;

@property(nonatomic, assign, readonly)BOOL isFloatViewShow;

@end

@implementation TUILiveAudienceVideoRenderView{
    BOOL _isViewReady;
}

#pragma mark - getter 懒加载||只读属性
- (UIView *)videoRenderView {
    if (!_videoRenderView) {
        _videoRenderView = [[UIView alloc] initWithFrame:CGRectZero];
        _videoRenderView.tag = FULL_SCREEN_PLAY_VIDEO_VIEW;
    }
    return _videoRenderView;
}

- (NSMutableArray<TUILiveStatusInfoView *> *)statusInfoViewArray {
    if (!_statusInfoViewArray) {
        _statusInfoViewArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _statusInfoViewArray;
}

-(CGFloat)floatViewScaling {
    return [TUILiveFloatWindow sharedInstance].floatWindowScaling;
}

- (BOOL)isFloatViewShow {
    return [TUILiveFloatWindow sharedInstance].isShowing;
}

#pragma mark - 视图生命周期
- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (_isViewReady) {
        return;
    }
    _isViewReady = YES;
    [self constructViewHierarchy];
    [self activeViewConstraint];
}

- (void)constructViewHierarchy {
    [self addSubview:self.videoRenderView];
    //初始化连麦播放小窗口
    if (self.statusInfoViewArray.count == 0) {
        for (int i = 1; i <= 3; i+=1) {
            TUILiveStatusInfoView *view = [self createStatusInfoView:i];
            [self.statusInfoViewArray addObject:view];
            [self addSubview:view.videoView];
        }
    }
}

- (void)activeViewConstraint {
    [self.videoRenderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsZero);
    }];
    CGFloat bottomMargin = VIDEO_VIEW_MARGIN_BOTTOM;
    if (@available(iOS 11.0, *)) {
        bottomMargin = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom + VIDEO_VIEW_MARGIN_BOTTOM;
    }
    [self.statusInfoViewArray enumerateObjectsUsingBlock:^(TUILiveStatusInfoView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(VIDEO_VIEW_HEIGHT * self.floatViewScaling);
            make.width.mas_equalTo(VIDEO_VIEW_WIDTH * self.floatViewScaling);
            make.bottom.equalTo(self.mas_bottom).offset((- bottomMargin - VIDEO_VIEW_HEIGHT * idx - VIDEO_VIEW_MARGIN_SPACE * idx) * self.floatViewScaling);
            make.right.equalTo(self.mas_right).offset((-VIDEO_VIEW_MARGIN_RIGHT) * self.floatViewScaling);
        }];
    }];
}

- (TUILiveStatusInfoView *)createStatusInfoView: (int)index {
    TUILiveStatusInfoView* statusInfoView = [[TUILiveStatusInfoView alloc] init];
    statusInfoView.videoView = [[UIView alloc] initWithFrame:CGRectZero];
    return statusInfoView;
}

- (void)stopAndResetAllStatusView:(CloseEnumerateAction)action {
    for (TUILiveStatusInfoView *statusInfoView in self.statusInfoViewArray) {
        [statusInfoView stopLoading];
        [statusInfoView stopPlay];
        if (statusInfoView.userID.length && action) {
            action(statusInfoView.userID);
        }
        [statusInfoView emptyPlayInfo];
    }
}

- (BOOL)isNoAnchorInStatusInfoView {
    for (TUILiveStatusInfoView* statusInfoView in self.statusInfoViewArray) {
        if ([statusInfoView.userID length] > 0) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - setter
- (void)setFatherView:(UIView *)fatherView {
    if (fatherView != _fatherView) {
        [self addRenderViewToFatherView:fatherView];
    }
    _fatherView = fatherView;
}

#pragma mark - public function
- (TUILiveStatusInfoView *)getStatusInfoViewByUserID:(NSString *)userID {
    if (userID) {
        for (TUILiveStatusInfoView* statusInfoView in self.statusInfoViewArray) {
            if ([userID isEqualToString:statusInfoView.userID]) {
                return statusInfoView;
            }
        }
    }
    return nil;
}

- (TUILiveStatusInfoView *)getFreeStatusInfoView {
    TUILiveStatusInfoView *result = nil;
    for (TUILiveStatusInfoView* statusInfoView in self.statusInfoViewArray) {
        if (statusInfoView.userID == nil || statusInfoView.userID.length == 0) {
            result = statusInfoView;
            break;
        }
    }
    return result;
}

- (void)switchPKStatus:(BOOL)isPKStatus useCDN:(BOOL)useCDN {
    self.isPKStatus = isPKStatus;
    if (isPKStatus) {
        [UIView animateWithDuration:0.1 animations:^{
            CGFloat topOffset = 0;
            if (@available(iOS 11, *)) {
                topOffset = UIApplication.sharedApplication.keyWindow.safeAreaInsets.top;
            }
            CGFloat topMargin = useCDN ? (topOffset + 35) * self.floatViewScaling : (topOffset + 80) * self.floatViewScaling;
            CGFloat heightScaling = 0.5;
            if (self.isFloatViewShow) {
                topMargin = 0;
                heightScaling = 1.0;
            }
            if (useCDN) {
                [self.videoRenderView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.bottom.equalTo(self);
                    make.top.equalTo(self.mas_top).offset(topMargin);
                }];
            } else {
                [self.videoRenderView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.mas_top).offset(topMargin);
                    make.width.equalTo(self.mas_width).multipliedBy(0.5);
                    make.height.equalTo(self.mas_height).multipliedBy(heightScaling);
                    make.left.equalTo(self.mas_left);
                }];
            }
            [self layoutIfNeeded];
            [self linkFrameRestore];
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            [self.videoRenderView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_offset(UIEdgeInsetsZero);
            }];
            [self layoutIfNeeded];
        }];
    }
}

- (void)switchStatusViewPKModel {
    CGFloat topOffset = 0;
    if (@available(iOS 11, *)) {
        topOffset = UIApplication.sharedApplication.keyWindow.safeAreaInsets.top;
    }
    for (TUILiveStatusInfoView *statusView in self.statusInfoViewArray) {
        if (statusView.userID.length > 0) {
            CGFloat heightScaling = 0.5;
            if (self.isFloatViewShow) {
                heightScaling = 1.0;
            }
            [UIView animateWithDuration:0.1 animations:^{
                [statusView.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.mas_width).multipliedBy(0.5);
                    make.height.equalTo(self.mas_height).multipliedBy(heightScaling);
                    make.top.equalTo(self.videoRenderView.mas_top);
                    make.right.equalTo(self.mas_right);
                }];
                [self layoutIfNeeded];
            }];
            break;
        }
    }
}

- (void)switchStatusViewJoinAnchorModel {
    CGFloat bottomMargin = VIDEO_VIEW_MARGIN_BOTTOM;
    if (@available(iOS 11.0, *)) {
        bottomMargin = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom + VIDEO_VIEW_MARGIN_BOTTOM;
    }
    // 连麦状态刷新
    [self.statusInfoViewArray enumerateObjectsUsingBlock:^(TUILiveStatusInfoView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(VIDEO_VIEW_HEIGHT * self.floatViewScaling);
            make.width.mas_equalTo(VIDEO_VIEW_WIDTH * self.floatViewScaling);
            make.bottom.equalTo(self.mas_bottom).offset((- bottomMargin - VIDEO_VIEW_HEIGHT * idx - VIDEO_VIEW_MARGIN_SPACE * idx) * self.floatViewScaling);
            make.right.equalTo(self.mas_right).offset((-VIDEO_VIEW_MARGIN_RIGHT) * self.floatViewScaling);
        }];
    }];
}

- (void)linkFrameRestore {
    CGFloat bottomMargin = VIDEO_VIEW_MARGIN_BOTTOM;
    if (@available(iOS 11.0, *)) {
        bottomMargin = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom + VIDEO_VIEW_MARGIN_BOTTOM;
    }
    [self.statusInfoViewArray enumerateObjectsUsingBlock:^(TUILiveStatusInfoView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.userID.length > 0) {
            [obj.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(VIDEO_VIEW_HEIGHT * self.floatViewScaling);
                make.width.mas_equalTo(VIDEO_VIEW_WIDTH * self.floatViewScaling);
                make.bottom.equalTo(self.mas_bottom).offset((- bottomMargin - VIDEO_VIEW_HEIGHT * idx - VIDEO_VIEW_MARGIN_SPACE * idx) * self.floatViewScaling);
                make.right.equalTo(self.mas_right).offset((-VIDEO_VIEW_MARGIN_RIGHT) * self.floatViewScaling);
            }];
        }
    }];
    [self layoutIfNeeded];
}

- (void)refreshConstraint {
    [self activeViewConstraint];
}

#pragma mark - private function

/**
 *  直播播放视图添加到fatherView上
 */
- (void)addRenderViewToFatherView:(UIView *)view {
    [self removeFromSuperview];
    if (view) {
        [view addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsZero);
        }];
        // 首先对主视图布局刷新
        if (!self->_isViewReady) {
            return;
        }
        [self switchPKStatus:self.isPKStatus useCDN:NO];
        if (self.isPKStatus) {
            [self switchStatusViewPKModel];
        } else {
            [self switchStatusViewJoinAnchorModel];
        }
        [self layoutIfNeeded];
    }
}

@end
